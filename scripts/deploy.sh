#!/bin/bash
. .env

ENVIRONMENT=$1

case $ENVIRONMENT in

uat)
  echo "runs container in uat..."
  ssh -t ${UAT_HOST} \
    sudo podman run --rm -d \
      --expose ${UAT_EXPOSED_PORT} -p ${UAT_EXPOSED_PORT}:5000 \
      -v ${PRD_CONTENT_PATH}/journals:/journals \
      --name budget-uat \
      acbilson/budget-uat:buster-slim
;;

prod)
  echo "enabling micropub service..."
  ssh -t ${PROD_HOST} sudo systemctl daemon-reload
  ssh -t ${PROD_HOST} sudo systemctl enable --now container-budget.service
;;

*)
  echo "please provide one of the following as the first argument: uat, prod."
  exit 1

esac
