#! /bin/bash -e

NAME=zookeeper
ID=-$(date +%Y%m%d%H%M%S)
RN=${NAME}$ID
POD=$RN-0
POD_EXEC="kubectl exec $POD -- bash -c "
POD_EXEC_I="kubectl exec -i $POD -- bash -c "

NODE=/foo$ID

echo installing

helm install --wait $RN charts/${NAME}

echo running helm test

helm test $RN

echo testing

$POD_EXEC_I "bin/zkCli.sh -server $RN:2181" <<END
create $NODE
set $NODE bar
get $NODE 
END

echo deleting

kubectl delete po --wait=true $POD

kubectl wait --for=condition=ready pod --timeout=90s $POD

echo testing persistence

$POD_EXEC "echo get $NODE | bin/zkCli.sh -server $RN:2181"

# kubectl exec zookeeper-0 -- bash -c "echo get /foo | bin/zkCli.sh -server zookeeper:2181"

echo
echo
echo SUCCESS

helm uninstall $RN
