#!/bin/bash
. .env

ENVIRONMENT=$1

case $ENVIRONMENT in

dev)
  echo "copies files to distribute..."
  mkdir -p dist && cp template/requirements.txt dist/

  echo "builds development image..."
  docker build -f Dockerfile \
    --target=dev \
    --build-arg EXPOSED_PORT=${EXPOSED_PORT} \
    -t acbilson/budget-dev:buster-slim .
;;

uat)
  echo "copies files to distribute..."
  mkdir -p dist/dist && cp Dockerfile dist/ && cp template/requirements.txt dist/dist/

  echo "copies importers to distribute..."
  cp -r importers dist/

  echo "distributes dist/ folder..."
  scp -r dist ${UAT_HOST}:/mnt/msata/build/uat

  echo "builds image on UAT"
  ssh -t ${UAT_HOST} \
    sudo podman build \
      -f /mnt/msata/build/uat/Dockerfile \
      --target=uat \
      -t acbilson/budget-uat:buster-slim \
      /mnt/msata/build/uat
;;

prod)
  echo "creates files from template..."
  mkdir -p dist && \
    envsubst < template/container-budget.service > dist/container-budget.service

  echo "copies files to distribute..."
  cp Dockerfile dist/

  echo "copies importers to distribute..."
  cp -r importers dist/

  echo "distributes dist/ folder..."
  scp -r dist ${PROD_HOST}:/mnt/msata/build/prod

  echo "builds image on production"
  ssh -t ${PROD_HOST} \
    sudo podman build \
      -f /mnt/msata/build/prod/Dockerfile \
      --target=prod \
      -t acbilson/budget:buster-slim \
      /mnt/msata/build/prod
;;

*)
  echo "please provide one of the following as the first argument: dev, uat, prod."
  exit 1

esac
