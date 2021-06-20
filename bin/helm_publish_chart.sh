#!/usr/bin/env bash

CHART_NAME="${1}"
PUBLISH_VERSION="${2}"

[ -z "${CHART_NAME}" ] && echo missing CHART_NAME && exit 1
[ -z "${PUBLISH_VERSION}" ] && echo missing PUBLISH_VERSION && exit 1

REPODIR="$(pwd)"
TEMPDIR=`mktemp -d`
cd $TEMPDIR

git clone -b helm-charts git@github.com:whiletrue-industries/srm-devops.git &&\
cd srm-devops &&\
mkdir -p "${CHART_NAME}" &&\
helm package "${REPODIR}/helm/${CHART_NAME}" -d "./${CHART_NAME}" --version "${PUBLISH_VERSION}" &&\
helm repo index --url "https://raw.githubusercontent.com/whiletrue-industries/srm-devops/helm-charts/${CHART_NAME}/" "./${CHART_NAME}" &&\
git add . &&\
git commit -m "publish ${CHART_NAME} version ${PUBLISH_VERSION}" &&\
git push origin helm-charts
RES="$?"

cd "${REPODIR}"
rm -rf "${TEMPDIR}"
exit $RES