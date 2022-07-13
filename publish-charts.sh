#! /bin/bash -e

VERSION=${1?}        

# This needs to figure out if anything has changed
# Perhaps have the commit SHA in repo


if [ ! -d helm-repository ] ; then
    git worktree add helm-repository helm-repository
fi

echo about to sed: charts/*/Chart.yaml


if which gsed ; then
    SED=gsed
else
    SED=sed
fi

$SED --in-place -e "s/^appVersion:.*$/appVersion: $VERSION/" -e "s/^version:.*$/version: $VERSION/" charts/*/Chart.yaml
echo done sed
git diff HEAD

ls -d charts/* | xargs -n1 -I XYZ helm package XYZ -d helm-repository

cd helm-repository

helm repo index .

git add .

if git diff-index --quiet HEAD -- ; then
    echo no changes
else
    git commit -am "Updated charts"
    git push
fi
