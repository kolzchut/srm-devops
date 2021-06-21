#!/usr/bin/env bash

CLUSTER_NAME="${1}"

source "clusters/${CLUSTER_NAME}/env.sh"
[ -f "clusters/${CLUSTER_NAME}/.env" ] && source "clusters/${CLUSTER_NAME}/.env"
kubectl config use-context "${CLUSTER_CONTEXT_NAME}" &&\
echo Connected to cluster "${CLUSTER_NAME}"