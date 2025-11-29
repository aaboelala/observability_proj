FROM python:3.11-slim


WORKDIR /app

COPY requirements.txt .
RUN python -m pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

COPY flask-todo/app.py .

COPY flask-todo/templates ./templates/

CMD ["python", "app.py"]