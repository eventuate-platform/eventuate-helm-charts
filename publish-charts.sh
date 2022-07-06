#! /bin/bash -e

VERSION=${1?}        

# This needs to figure out if anything has changed
# Perhaps have the commit SHA in repo


if [ ! -d helm-repository ] ; then
    git worktree add helm-repository helm-repository
fi

sed -i '' -e "s/^appVersion:.*$/appVersion: $VERSION/" -e "s/^version:.*$/version: $VERSION/" charts/*/Chart.yaml
ls -d charts/* | xargs -n1 -I XYZ helm package XYZ -d helm-repository
cd helm-repository
helm repo index .
git add .
if git diff --quiet HEAD; then
    echo no changes
else
    git commit -am "Updated charts"
    git push
fi
