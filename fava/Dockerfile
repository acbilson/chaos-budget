FROM python:3.9.2-slim-buster AS build
ENV BEANCOUNT_VERSION "2.3.3"
ENV BEANDEPS "libxml2-dev libxslt1-dev gcc musl-dev git"

# Installs beancount
RUN apt-get update && pip install --upgrade pip
RUN apt-get install -y ${BEANDEPS}
RUN pip install beancount
RUN pip install fava

COPY journals/journal.beancount .
EXPOSE 5000
ENTRYPOINT ["fava", "--host", "0.0.0.0", "journal.beancount"]
