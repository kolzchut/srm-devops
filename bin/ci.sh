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
    CHART_HAS_CHANGES=no
    if echo "${COMMIT_MSG}" | grep "--helm-publish-chart=${CHART_NAME}"; then
      CHART_HAS_CHANGES=yes
      echo Detected forced chart publish from commit message
    elif echo "${GIT_DIFF}" | grep -v "^helm/${CHART_NAME}/latest-chart-version.txt" | grep -v "^helm/${CHART_NAME}/values.auto-updated.yaml" | grep "^helm/${CHART_NAME}/"; then
      CHART_HAS_CHANGES=yes
      echo Detected change in chart files
    fi
    if [ "${CHART_HAS_CHANGES}" == "yes" ]; then
      if bin/helm_publish_chart.sh "${CHART_NAME}" "v0.0.0-${COMMIT_TO}"; then
        echo "v0.0.0-${COMMIT_TO}" > "helm/${CHART_NAME}/latest-chart-version.txt"
        git add "helm/${CHART_NAME}/latest-chart-version.txt"
        HELM_CHANGED_CHARTS="${HELM_CHANGED_CHARTS} ${CHART_NAME}"
      else
        echo Failed && RET=1
      fi
    fi
  fi
done
if [ "${HELM_CHANGED_CHARTS}" != "" ]; then
  git commit -m "helm latest chart version updates:${HELM_CHANGED_CHARTS}"
  git push origin main
fi

exit $RET