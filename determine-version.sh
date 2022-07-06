#! /bin/bash -e

CHART_VERSION=$(sed  -e '/^version:/!d' -e 's/.*: //' <  $(ls charts/*/Chart.yaml | head -1))

BUILD_DATE=$(date -u +'%Y%m%d%H%M%S')
if [[ "$GITHUB_REF" == refs/tags/* ]]; then
    VERSION=${GITHUB_REF/refs\/tags\//}
else
    VERSION=${CHART_VERSION}-BUILD.${BUILD_DATE}
fi

echo $VERSION