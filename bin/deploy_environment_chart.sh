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

if [ -f "environments/${ENVIRONMENT_NAME}/environment_label.txt" ]; then
  ENVIRONMENT_LABEL="$(cat "environments/${ENVIRONMENT_NAME}/environment_label.txt")"
else
  ENVIRONMENT_LABEL=
fi

echo ENVIRONMENT_LABEL="${ENVIRONMENT_LABEL}"

[ -f "helm/${CHART_NAME}/values.auto-updated.yaml" ] && HELM_ARGS="${HELM_ARGS} -f helm/${CHART_NAME}/values.auto-updated.yaml"
if [ "${ENVIRONMENT_LABEL}" != "" ]; then
  [ -f "helm/${CHART_NAME}/values.auto-updated.${ENVIRONMENT_LABEL}.yaml" ] && HELM_ARGS="${HELM_ARGS} -f helm/${CHART_NAME}/values.auto-updated.${ENVIRONMENT_LABEL}.yaml"
fi
[ -f "${ENVIRONMENT_CHART_DIR}/values.yaml" ] && HELM_ARGS="${HELM_ARGS} -f ${ENVIRONMENT_CHART_DIR}/values.yaml"
[ -f "${ENVIRONMENT_CHART_DIR}/values.auto-updated.yaml" ] && HELM_ARGS="${HELM_ARGS} -f ${ENVIRONMENT_CHART_DIR}/values.auto-updated.yaml"

if [ "${FROM_PATH}" == "yes" ]; then
  HELM_CHART_VERSION_ARGS=""
  HELM_ARGS="--install ${RELEASE_NAME} ./helm/${CHART_NAME} ${HELM_ARGS}"
else
  HELM_CHART_VERSION_ARGS="--version ${CHART_VERSION} --repo https://raw.githubusercontent.com/whiletrue-industries/srm-devops/helm-charts/${CHART_NAME} ${CHART_NAME}"
  HELM_ARGS="--install ${RELEASE_NAME} ${HELM_CHART_VERSION_ARGS} ${HELM_ARGS}"
fi

echo HELM_ARGS="${HELM_ARGS}"

source bin/connect_environment.sh "${ENVIRONMENT_NAME}"

if ! helm upgrade $HELM_ARGS; then
  if [ "${HELM_CHART_VERSION_ARGS}" != "" ] && ! helm show chart $HELM_CHART_VERSION_ARGS; then
    echo requested chart is not available, waiting 2 minutes and retrying in case it was just published
    sleep 120
    ! helm upgrade $HELM_ARGS && echo helm upgrade failed && exit 1
  else
    echo helm upgrade failed && exit 1
  fi
fi

echo Great Success
exit 0
