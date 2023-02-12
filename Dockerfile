# syntax=docker/dockerfile:1
# imagen Base
FROM python:3  

# Variables de entorno
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /code
COPY requirements_clase.txt /code/
RUN pip install -r requirements_clase.txt
COPY . /code/