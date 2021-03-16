FROM python:3.9.2-slim-buster AS build
ENV BEANCOUNT_VERSION "2.3.3"
ENV BEANDEPS "libxml2-dev libxslt1-dev gcc musl-dev git"

# Installs beancount
RUN apt-get update && pip install --upgrade pip
RUN apt-get install -y ${BEANDEPS}
COPY fava/requirements.txt .
RUN pip install -r requirements.txt

WORKDIR /journals
EXPOSE 5000
ENTRYPOINT ["fava", "--host", "0.0.0.0", "journal.beancount"]
