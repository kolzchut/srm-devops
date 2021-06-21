#!/usr/bin/env bash

ENVIRONMENT_CHART_DIR="${1}"
HELM_ARGS="${@:2}"

[ -z "${ENVIRONMENT_CHART_DIR}" ] && echo missing ENVIRONMENT_CHART_DIR && exit 1

echo Deploying environment chart "${ENVIRONMENT_CHART_DIR}"

ENVIRONMENT_NAME="$(echo "${ENVIRONMENT_CHART_DIR}" | cut -d"/" -f2)"
CHART_NAME="$(echo "${ENVIRONMENT_CHART_DIR}" | cut -d"/" -f4)"
if [ -f "${ENVIRONMENT_CHART_DIR}/chart_name.txt" ]; then
  ! [ -f "${ENVIRONMENT_CHART_DIR}/release_name.txt" ] && echo release_name.txt is required if specifying chart_name.txt && exit 1
  CHART_NAME="$(cat ${ENVIRONMENT_CHART_DIR}/chart_name.txt)"
  RELEASE_NAME="$(cat ${ENVIRONMENT_CHART_DIR}/release_name.txt)"
else
  RELEASE_NAME="${CHART_NAME}"
fi

echo CHART_NAME="${CHART_NAME}" ENVIRONMENT_NAME="${ENVIRONMENT_NAME}"

if [ -f "${ENVIRONMENT_CHART_DIR}/chart_version.txt" ]; then
  CHART_VERSION="$(cat "${ENVIRONMENT_CHART_DIR}/chart_version.txt")"
elif [ -f "helm/${CHART_NAME}/latest-chart-version.txt" ]; then
  CHART_VERSION="$(cat "helm/${CHART_NAME}/latest-chart-version.txt")"
else
  echo failed to find chart version
  exit 1
fi

echo CHART_VERSION="${CHART_VERSION}"

[ -f "helm/${CHART_NAME}/values.auto-updated.yaml" ] && HELM_ARGS="${HELM_ARGS} -f helm/${CHART_NAME}/values.auto-updated.yaml"
[ -f "${ENVIRONMENT_CHART_DIR}/values.yaml" ] && HELM_ARGS="${HELM_ARGS} -f ${ENVIRONMENT_CHART_DIR}/values.yaml"
[ -f "${ENVIRONMENT_CHART_DIR}/values.auto-updated.yaml" ] && HELM_ARGS="${HELM_ARGS} -f ${ENVIRONMENT_CHART_DIR}/values.auto-updated.yaml"

if [ "${FROM_PATH}" == "yes" ]; then
  HELM_ARGS="--install ${RELEASE_NAME} ./helm/${CHART_NAME} ${HELM_ARGS}"
else
  HELM_ARGS="--install ${RELEASE_NAME} --version ${CHART_VERSION} --repo https://raw.githubusercontent.com/whiletrue-industries/srm-devops/helm-charts/${CHART_NAME} ${CHART_NAME} ${HELM_ARGS}"
fi

echo HELM_ARGS="${HELM_ARGS}"

source bin/connect_environment.sh "${ENVIRONMENT_NAME}"
helm upgrade $HELM_ARGS
[ "$?" != "0" ] && echo Failed && exit 1
echo Great Success
exit 0
