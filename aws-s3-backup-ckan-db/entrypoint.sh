#!/usr/bin/env bash

[ -z "${POSTGRES_HOST}" ] && echo missing POSTGRES_HOST && exit 1
[ -z "${POSTGRES_PASSWORD}" ] && echo missing POSTGRES_PASSWORD && exit 1
[ -z "${POSTGRES_USER}" ] && echo missing POSTGRES_USER && exit 1
[ -z "${POSTGRES_DB_NAME}" ] && echo missing POSTGRES_DB_NAME && exit 1
[ -z "${DATASTORE_POSTGRES_USER}" ] && echo missing DATASTORE_POSTGRES_USER && exit 1
[ -z "${DATASTORE_POSTGRES_PASSWORD}" ] && echo missing DATASTORE_POSTGRES_PASSWORD && exit 1
[ -z "${TARGET_BUCKET_PATH}" ] && echo missing TARGET_BUCKET_PATH && exit 1

echo TARGET_BUCKET_PATH=$TARGET_BUCKET_PATH
NOW="$(date +%Y-%m-%dT%H-%M-%S)"
echo NOW=$NOW

cd `mktemp -d` &&\
PGPASSWORD="${POSTGRES_PASSWORD}" pg_dump --inserts -d "${POSTGRES_DB_NAME}" -h "${POSTGRES_HOST}" -U "${POSTGRES_USER}" \
  -n public -f "./main-${NOW}.sql" &&\
gzip "./main-${NOW}.sql" &&\
aws s3 cp "./main-${NOW}.sql.gz" s3://${TARGET_BUCKET_PATH}/ &&\
rm -f "./main-${NOW}.sql.gz" &&\
PGPASSWORD="${DATASTORE_POSTGRES_PASSWORD}" pg_dump --inserts -d "${DATASTORE_POSTGRES_USER}" -h "${POSTGRES_HOST}" -U "${DATASTORE_POSTGRES_USER}" \
  -n public -f "./datastore-${NOW}.sql" &&\
gzip "./datastore-${NOW}.sql" &&\
aws s3 cp "./datastore-${NOW}.sql.gz" s3://${TARGET_BUCKET_PATH}/ &&\
rm -f "./datastore-${NOW}.sql.gz"
