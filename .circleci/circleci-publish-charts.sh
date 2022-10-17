#! /bin/bash -e

VERSION=$(./determine-version.sh)
echo $VERSION
./publish-charts.sh $VERSION
