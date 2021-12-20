#!/usr/bin/env bash

SOURCE_DIRECTORY="${1}"
TARGET_BUCKET_PATH="${2}"

[ -z "${SOURCE_DIRECTORY}" ] && echo missing SOURCE_DIRECTORY && exit 1
[ -z "${TARGET_BUCKET_PATH}" ] && echo missing TARGET_BUCKET_PATH && exit 1

echo SOURCE_DIRECTORY=$SOURCE_DIRECTORY
echo TARGET_BUCKET_PATH=$TARGET_BUCKET_PATH

NOW="$(date +%Y-%m-%dT%H-%M-%S)"
echo NOW=$NOW

TEMPDIR=`mktemp -d` &&\
cd "${SOURCE_DIRECTORY}" &&\
tar -czf "${TEMPDIR}/${NOW}.tar.gz" . &&\
cd "${TEMPDIR}" &&\
ls -lah &&\
aws s3 cp "${NOW}.tar.gz" "s3://${TARGET_BUCKET_PATH}/"
