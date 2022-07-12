#! /bin/bash -e

NAME=keycloak
ID=-$(date +%Y%m%d%H%M%S)
RN=${NAME}$ID
POD=$RN-0
POD_EXEC="kubectl exec $POD -- bash -c "
POD_EXEC_I="kubectl exec -i $POD -- bash -c "

MKN=mysql$ID

echo installing mysql

helm install --wait $MKN charts/mysql

echo installing keycloak 

helm install --wait $RN charts/${NAME}  --set mysql.host=$MKN

echo testing

helm test $RN

echo cleaning up

helm uninstall $RN
helm uninstall $MKN
