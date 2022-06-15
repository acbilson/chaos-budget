FROM python:3.9.2-slim-buster AS build
ENV BEANCOUNT_VERSION "2.3.3"
WORKDIR /src

# Installs beancount and fava dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
      python3-dev \
      python3-lxml \
      libxslt1-dev \
      zlib1g-dev \
      gcc \
      musl-dev \
      git

# Installs python packages to the users local folder
COPY template/requirements.txt .
RUN pip install --user -r requirements.txt

FROM python:3.9.2-slim-buster AS base
COPY --from=build /root/.local /root/.local

# Adds importers
COPY importers /importers

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

# Adds docs folder
RUN mkdir -p /docs

ENTRYPOINT ["/root/.local/bin/fava", "--host", "0.0.0.0", "journal.beancount"]

#############
# PROD
#############
FROM base as prod
WORKDIR /journals

# Adds docs folder
RUN mkdir -p /docs

ENTRYPOINT ["/root/.local/bin/fava", "--host", "0.0.0.0", "journal.beancount"]
