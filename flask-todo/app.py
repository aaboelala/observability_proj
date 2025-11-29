from flask import Flask, render_template, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
import logging

# ===== OpenTelemetry Imports =====
from opentelemetry import trace, metrics
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter
from opentelemetry.sdk.metrics import MeterProvider

# OTLP Exporters
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.exporter.otlp.proto.grpc._log_exporter import OTLPLogExporter  # experimental

# Logs SDK
from opentelemetry.sdk._logs import LoggerProvider, LoggingHandler

# ===== Flask App =====
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///db.sqlite'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# ===== OpenTelemetry Resource =====
resource = Resource.create(attributes={"service.name": "flask-todo-app"})

# ===== Tracing =====
tracer_provider = TracerProvider(resource=resource)
span_exporter = OTLPSpanExporter(endpoint="otel-collector:4317", insecure=True)
tracer_provider.add_span_processor(BatchSpanProcessor(span_exporter))
tracer_provider.add_span_processor(BatchSpanProcessor(ConsoleSpanExporter()))  # dev
trace.set_tracer_provider(tracer_provider)
tracer = trace.get_tracer(__name__)

# ===== Metrics =====
meter_provider = MeterProvider()
metrics.set_meter_provider(meter_provider)
meter = metrics.get_meter("flask-todo-metrics")
metric_exporter = OTLPMetricExporter(endpoint="otel-collector:4317", insecure=True)

# ===== Logging =====
logger_provider = LoggerProvider(resource=resource)
log_exporter = OTLPLogExporter(endpoint="otel-collector:4317", insecure=True)
logging_handler = LoggingHandler(level=logging.INFO, logger_provider=logger_provider)
logging.getLogger().addHandler(logging_handler)

# ===== Todo Model =====
class Todo(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100))
    complete = db.Column(db.Boolean)

# ===== Flask Routes =====
@app.route("/")
def home():
    todos = Todo.query.all()
    logging.info("Fetched todos")
    return render_template("base.html", todo_list=todos)

@app.route("/add", methods=["POST"])
def add():
    title = request.form.get("title")
    todo = Todo(title=title, complete=False)
    db.session.add(todo)
    db.session.commit()
    logging.info(f"Added todo: {title}")
    return redirect(url_for("home"))

@app.route("/update/<int:todo_id>")
def update(todo_id):
    todo = Todo.query.get(todo_id)
    todo.complete = not todo.complete
    db.session.commit()
    logging.info(f"Updated todo {todo_id} to {todo.complete}")
    return redirect(url_for("home"))

@app.route("/delete/<int:todo_id>")
def delete(todo_id):
    todo = Todo.query.get(todo_id)
    db.session.delete(todo)
    db.session.commit()
    logging.info(f"Deleted todo {todo_id}")
    return redirect(url_for("home"))

# ===== Main =====
if __name__ == "__main__":
    # ===== Instrumentation و db.create_all داخل Application Context =====
    with app.app_context():
        db.create_all()
        FlaskInstrumentor().instrument_app(app)
        SQLAlchemyInstrumentor().instrument(engine=db.engine)

    app.run(host="0.0.0.0", port=5000, debug=True)
