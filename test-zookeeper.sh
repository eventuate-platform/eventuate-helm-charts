#! /bin/bash -e

ID=-$(date +%Y%m%d%H%M%S)
RN=zookeeper$ID
POD=$RN-0
NODE=/foo$ID
POD_EXEC="kubectl exec $POD -- bash -c "
POD_EXEC_I="kubectl exec -i $POD -- bash -c "

echo installing

helm install --wait $RN charts/zookeeper

echo testing

$POD_EXEC_I "bin/zkCli.sh -server zookeeper:2181" <<END
create $NODE
set $NODE bar
get $NODE 
END

echo deleting

kubectl delete po $POD

kubectl wait --for=condition=ready pod --timeout=90s $POD

echo testing persistence

$POD_EXEC "echo get $NODE | bin/zkCli.sh -server zookeeper:2181"

# kubectl exec zookeeper-0 -- bash -c "echo get /foo | bin/zkCli.sh -server zookeeper:2181"

echo
echo
echo SUCCESS

helm uninstall $RN
