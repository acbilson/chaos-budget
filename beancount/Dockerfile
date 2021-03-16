FROM python:3.9.2-slim-buster AS build
ENV BEANCOUNT_VERSION "2.3.3"
ENV BEANDEPS "libxml2-dev libxslt1-dev gcc musl-dev git"

# Installs beancount and deps
RUN apt-get update && pip install --upgrade pip
RUN apt-get install -y ${BEANDEPS}
COPY beancount/requirements.txt .
RUN pip install -r requirements.txt

WORKDIR /journals
