FROM python:3.8-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY flask-todo/app.py .
COPY flask-todo/templates .

CMD ["python", "app.py"]