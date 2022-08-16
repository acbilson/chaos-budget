FROM python:3.10.6-slim-bullseye
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
COPY requirements.txt .
RUN pip install -r requirements.txt

# Adds importers
COPY importers /importers

WORKDIR /journals

# Adds docs folder
RUN mkdir -p /docs

CMD ["fava", "--host", "0.0.0.0", "journal.beancount"]
