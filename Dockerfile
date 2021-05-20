FROM python:3.9.2-slim-buster AS build
ENV BEANCOUNT_VERSION "2.3.3"
#ENV BEANDEPS "python3-dev python3-lxml lib32z1-dev libxslt1-dev gcc musl-dev git"
WORKDIR /src
ENTRYPOINT ["tail", "-f", "/dev/null"]

FROM python:3.9.2-slim-buster AS fake

# Installs beancount and fava dependencies
RUN apt-get update && \
  pip install --upgrade pip && \
  apt-get install -y ${BEANDEPS}

# Installs python packages to the users local folder
COPY dist/requirements.txt .
RUN pip install --user -r requirements.txt

FROM python:3.9.2-slim-buster AS base
COPY --from=build /root/.local /root/.local

#############
# Development
#############
FROM base as dev
WORKDIR /journals
ENTRYPOINT ["/root/.local/bin/fava", "--host", "0.0.0.0", "journal.beancount"]

#############
# UAT
#############
FROM base as uat
WORKDIR /journals

# Adds importers
COPY dist/importers /importers

ENTRYPOINT ["/root/.local/bin/fava", "--host", "0.0.0.0", "journal.beancount"]
