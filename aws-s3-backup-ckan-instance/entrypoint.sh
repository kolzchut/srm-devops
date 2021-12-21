#!/usr/bin/env bash

[ -z "${TARGET_BUCKET_PATH}" ] && echo missing TARGET_BUCKET_PATH && exit 1
[ -z "${CKAN_NAMESPACE}" ] && echo missing CKAN_NAMESPACE && exit 1

echo TARGET_BUCKET_PATH=$TARGET_BUCKET_PATH
echo CKAN_NAMESPACE=$CKAN_NAMESPACE
NOW="$(date +%Y-%m-%dT%H-%M-%S)"
echo NOW=$NOW

cd `mktemp -d` &&\
kubectl -n $CKAN_NAMESPACE exec deployment/ckan -- cat /etc/ckan/production.ini > "./production-${NOW}.ini" &&\
gzip "./production-${NOW}.ini" &&\
aws s3 cp "./production-${NOW}.ini.gz" s3://${TARGET_BUCKET_PATH}/