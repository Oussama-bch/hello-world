# Use an official Python image.
# https://hub.docker.com/_/python
FROM python:3.6-buster

WORKDIR /app

COPY app.py /app/app.py
COPY database.ini /app/database.ini
COPY lib.py /app/lib.py
COPY unit_tests.py /app/unit_tests.py 
COPY requirements.txt /app/requirements.txt

RUN pip install -r /app/requirements.txt

ENV PORT 80
ENV PYTHONUNBUFFERED TRUE

CMD exec gunicorn --bind 0.0.0.0:$PORT --workers 2 --threads 4 --worker-class gthread app:app