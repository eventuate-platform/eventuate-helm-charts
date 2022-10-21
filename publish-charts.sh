#! /bin/bash -e

VERSION=${1?}        

if [ ! -d helm-repository ] ; then
    git worktree add helm-repository helm-repository
fi


if which gsed ; then
    SED=gsed
else
    SED=sed
fi

tmp_dir=$(mktemp -d)
tmp_charts=$tmp_dir/charts

echo tmp_charts= $tmp_charts

cp -r charts $tmp_dir/charts

$SED --in-place -e "s/^appVersion:.*$/appVersion: $VERSION/" -e "s/version:.*$/version: $VERSION/" \
    $tmp_charts/*/Chart.yaml

helmRepo=$(pwd)/helm-repository

for chart in $tmp_charts/* ; do
    echo doing chart $chart

    dependency=$($SED -e '/ - name: */!d' -e 's/.* - name: *//' < $chart/Chart.yaml)

    if [ -n "$dependency" ] ; then

        echo dependency update for $dependency

        $SED --in-place -e "s/    version:.*/    version: $VERSION/" -e "s?repository:.*?repository: \"file://$tmp_charts/$dependency\"?" \
            $chart/Chart.yaml
        helm dependency update $chart
    fi

    echo Done dependency update

    $SED --in-place  -e "s?repository:.*?repository: \"https://raw.githubusercontent.com/eventuate-platform/eventuate-helm-charts/helm-repository\"?" \
                    $chart/Chart.yaml


    helm package $chart -d $helmRepo
 done

helm repo index helm-repository

cd helm-repository

git add .

if git diff-index --quiet HEAD -- ; then
    echo no changes
else
    git commit -am "Updated charts"
    git push
fi
