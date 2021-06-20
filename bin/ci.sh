#!/usr/bin/env bash

BRANCH_NAME="${1}"
COMMIT_FROM="${2}"
COMMIT_TO="${3}"
SRM_DEVOPS_DEPLOY_KEY="${4}"

[ "${BRANCH_NAME}" != "main" ] && echo ci is not supported for branches other than main && exit 1

if ! GIT_DIFF="$(git diff --name-only "${COMMIT_FROM}" "${COMMIT_TO}")"; then
  GIT_DIFF="$(git diff --name-only HEAD~1 HEAD)"
fi
echo "--- git diff ---"
echo "${GIT_DIFF}"
echo "----------------"

COMMIT_MSG="$(git log -1 --pretty=format:"%s")"
echo "--- commit message ---"
echo "${COMMIT_MSG}"
echo "----------------------"

RET=0

HELM_CHANGED_CHARTS=""
for CHART_NAME in `ls helm/`; do
  if [ -d "helm/${CHART_NAME}" ]; then
    if echo "${COMMIT_MSG}" | grep "--helm-publish-chart=${CHART_NAME}" || echo "${GIT_DIFF}" | grep -v "^helm/${CHART_NAME}/latest-chart-version.txt" | grep "^helm/${CHART_NAME}/"; then
      echo Publishing helm chart "${CHART_NAME}" with version "v0.0.0-${COMMIT_TO}" &&\
      bin/helm_publish_chart.sh "${CHART_NAME}" "v0.0.0-${COMMIT_TO}"
      [ "$?" != "0" ] && echo Failed && RET=1
      echo "v0.0.0-${COMMIT_TO}" > "helm/${CHART_NAME}/latest-chart-version.txt"
      git add "helm/${CHART_NAME}/latest-chart-version.txt"
      HELM_CHANGED_CHARTS="${HELM_CHANGED_CHARTS} ${CHART_NAME}"
    fi
  fi
done
if [ "${HELM_CHANGED_CHARTS}" != "" ]; then
  git commit -m "helm latest chart version updates:${HELM_CHANGED_CHARTS}"
  git push origin main
fi

exit $RET