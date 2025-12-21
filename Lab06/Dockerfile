FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY app /app

CMD sh -c "python manage.py makemigrations && python manage.py migrate && python manage.py collectstatic --noinput && uvicorn blogsite.asgi:application --host 0.0.0.0 --port 8000"
