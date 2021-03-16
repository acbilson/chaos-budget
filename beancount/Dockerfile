FROM python:3.9.2-slim-buster AS build
ENV BEANCOUNT_VERSION "2.3.3"
ENV BEANDEPS "libxml2-dev libxslt1-dev gcc musl-dev git"

# Installs beancount
RUN apt-get update && pip install --upgrade pip
RUN apt-get install -y ${BEANDEPS}
RUN pip install beancount

# Installs importers
COPY importers/csv/ /importers
RUN cd /importers && pip install -r requirements.txt && python setup.py install

WORKDIR /journals
