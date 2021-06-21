#!/usr/bin/env bash

ENVIRONMENT_NAME="${1}"

source "environments/${ENVIRONMENT_NAME}/env.sh"
[ -f "environments/${ENVIRONMENT_NAME}/.env" ] && source "environments/${ENVIRONMENT_NAME}/.env"
source bin/connect_cluster.sh "${CLUSTER_NAME}"
kubectl config set-context --current --namespace=$NAMESPACE_NAME &&\
echo Connected to environment "${ENVIRONMENT_NAME}"
