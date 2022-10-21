
tmp_dir=$(mktemp -d)
echo tmp_dir $tmp_dir
tmp_chart=$tmp_dir/tmp-chart

update_chart_with_dependency() {
    chart=$1
    dependency=$2
    dependency_version=$(sed -e '/^version:/!d' -e 's/^version: *//' < charts/$dependency/Chart.yaml)
    echo $dependency_version
    cp -r charts/$chart $tmp_chart
    sed -e "s/    version:.*/    version: $dependency_version/" -e "s?repository:.*?repository: \"file://$(PWD)/charts/$dependency\"?" \
    < $tmp_chart/Chart.yaml > $tmp_chart/Chart.yaml.new
    mv $tmp_chart/Chart.yaml.new $tmp_chart/Chart.yaml
}


