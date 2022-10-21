#! /bin/bash -e

NAME=keycloak
ID=-$(date +%Y%m%d%H%M%S)
RN=${NAME}$ID
POD=$RN-0
POD_EXEC="kubectl exec $POD -- bash -c "
POD_EXEC_I="kubectl exec -i $POD -- bash -c "

. ./copy-chart-helpers.sh

update_chart_with_dependency ${NAME} mysql

helm install --dependency-update --wait $RN $tmp_chart

echo testing

helm test $RN

echo cleaning up

helm uninstall $RN
