#! /bin/bash -e

NAME=authorization-server
ID=-$(date +%Y%m%d%H%M%S)
#ID=-xxx
RN=${NAME}$ID

echo installing

helm upgrade --install --wait $RN charts/${NAME}

echo
echo
echo SUCCESS

POD_EXEC="kubectl exec $(kubectl get po -l app.kubernetes.io/instance=authorization-server$ID -o name) -- bash -c "

echo POD_EXEC=$POD_EXEC

$POD_EXEC "curl -s -X POST -u messaging-client:secret -d client_id=messaging-client -d username=user -d password=password -d grant_type=password \
  http://localhost:9000/oauth2/token" 

$POD_EXEC "curl -s -X POST -u messaging-client:secret -d client_id=messaging-client -d username=user -d password=password -d grant_type=password \
  http://$RN:9000/oauth2/token" 

helm uninstall $RN
