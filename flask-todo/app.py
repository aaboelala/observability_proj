from flask import Flask, render_template, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
import logging
import time

# =====================
# OpenTelemetry Core
# =====================
from opentelemetry import trace, metrics
from opentelemetry.sdk.resources import Resource

# ===== Tracing =====
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

# ===== Metrics =====
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter

# ===== Logging =====
from opentelemetry.sdk._logs import LoggerProvider, LoggingHandler
from opentelemetry.sdk._logs.export import BatchLogRecordProcessor
from opentelemetry.exporter.otlp.proto.grpc._log_exporter import OTLPLogExporter
from opentelemetry.instrumentation.logging import LoggingInstrumentor

# ===== Instrumentation =====
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor


# =====================
# Flask App
# =====================
app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///db.sqlite"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
db = SQLAlchemy(app)

# =====================
# Resource (IMPORTANT)
# =====================
resource = Resource.create(
    {
        "service.name": "flask-todo-app",
        "service.version": "1.0.0",
        "deployment.environment": "dev",
    }
)

OTEL_ENDPOINT = "otel-collector.observability-ns.svc.cluster.local:4317"

# =====================
# Tracing
# =====================
tracer_provider = TracerProvider(resource=resource)
trace_exporter = OTLPSpanExporter(
    endpoint=OTEL_ENDPOINT,
    insecure=True,
)
tracer_provider.add_span_processor(BatchSpanProcessor(trace_exporter))
trace.set_tracer_provider(tracer_provider)
tracer = trace.get_tracer(__name__)

# =====================
# Metrics
# =====================
metric_exporter = OTLPMetricExporter(
    endpoint=OTEL_ENDPOINT,
    insecure=True,
)

metric_reader = PeriodicExportingMetricReader(
    metric_exporter,
    export_interval_millis=5000,
)

meter_provider = MeterProvider(
    resource=resource,
    metric_readers=[metric_reader],
)
metrics.set_meter_provider(meter_provider)
meter = metrics.get_meter("flask-todo-metrics")

# ---- Metrics definitions (RED + DB) ----
http_requests_total = meter.create_counter(
    "http_requests_total",
    description="Total HTTP requests",
)

http_request_errors_total = meter.create_counter(
    "http_request_errors_total",
    description="Total HTTP error responses",
)

http_request_duration = meter.create_histogram(
    "http_request_duration_seconds",
    description="HTTP request latency",
    unit="s",
)

db_operations_total = meter.create_counter(
    "db_operations_total",
    description="Total database operations",
)

# =====================
# Logging
# =====================
logger_provider = LoggerProvider(resource=resource)

log_exporter = OTLPLogExporter(
    endpoint=OTEL_ENDPOINT,
    insecure=True,
)

logger_provider.add_log_record_processor(
    BatchLogRecordProcessor(log_exporter)
)

handler = LoggingHandler(
    level=logging.INFO,
    logger_provider=logger_provider,
)

logging.basicConfig(level=logging.INFO)
logging.getLogger().addHandler(handler)

# IMPORTANT: before app.run
LoggingInstrumentor().instrument(set_logging_format=True)

# =====================
# Models
# =====================
class Todo(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100))
    complete = db.Column(db.Boolean, default=False)

# =====================
# Routes
# =====================
@app.route("/")
def home():
    start = time.time()
    try:
        http_requests_total.add(1, {"http.method": "GET", "http.route": "/"})

        todos = Todo.query.all()
        db_operations_total.add(1, {"db.operation": "select"})

        logging.info("Fetched todos")

        return render_template("base.html", todo_list=todos)

    except Exception as e:
        http_request_errors_total.add(1, {"http.route": "/"})
        logging.exception("Error fetching todos")
        raise
    finally:
        http_request_duration.record(
            time.time() - start,
            {"http.route": "/"},
        )


@app.route("/add", methods=["POST"])
def add():
    start = time.time()
    http_requests_total.add(1, {"http.method": "POST", "http.route": "/add"})

    with tracer.start_as_current_span("add-todo"):
        try:
            title = request.form.get("title")

            todo = Todo(title=title)
            db.session.add(todo)
            db.session.commit()

            db_operations_total.add(1, {"db.operation": "insert"})

            logging.info("Added todo", extra={"todo.title": title})

        except Exception:
            http_request_errors_total.add(1, {"http.route": "/add"})
            logging.exception("Failed to add todo")
            raise
        finally:
            http_request_duration.record(
                time.time() - start,
                {"http.route": "/add"},
            )

    return redirect(url_for("home"))


@app.route("/update/<int:todo_id>")
def update(todo_id):
    http_requests_total.add(1, {"http.method": "GET", "http.route": "/update"})

    with tracer.start_as_current_span("update-todo"):
        todo = Todo.query.get(todo_id)
        todo.complete = not todo.complete
        db.session.commit()

        db_operations_total.add(1, {"db.operation": "update"})
        logging.info("Updated todo", extra={"todo.id": todo_id})

    return redirect(url_for("home"))


@app.route("/delete/<int:todo_id>")
def delete(todo_id):
    http_requests_total.add(1, {"http.method": "GET", "http.route": "/delete"})

    with tracer.start_as_current_span("delete-todo"):
        todo = Todo.query.get(todo_id)
        db.session.delete(todo)
        db.session.commit()

        db_operations_total.add(1, {"db.operation": "delete"})
        logging.info("Deleted todo", extra={"todo.id": todo_id})

    return redirect(url_for("home"))

# =====================
# Main
# =====================
if __name__ == "__main__":
    with app.app_context():
        db.create_all()

        FlaskInstrumentor().instrument_app(app)
        SQLAlchemyInstrumentor().instrument(engine=db.engine)

    app.run(host="0.0.0.0", port=5000)
