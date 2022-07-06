#! /bin/bash -e

NAME=mysql
ID=-$(date +%Y%m%d%H%M%S)
RN=${NAME}$ID
POD=$RN-0
POD_EXEC="kubectl exec $POD -- bash -c "
POD_EXEC_I="kubectl exec -i $POD -- bash -c "

NODE=/foo$ID

echo installing

helm install --wait $RN charts/${NAME}

echo testing

helm test $RN

$POD_EXEC "echo 'create table foo (bar varchar(100));' | mysql -h$RN  -uroot -prootpassword -o eventuate -P 3306"

echo deleting

kubectl delete po $POD

kubectl wait --for=condition=ready pod --timeout=90s $POD

echo testing persistence

sleep 10

$POD_EXEC "echo 'select * from foo;' | mysql -h$RN  -uroot -prootpassword -o eventuate -P 3306"

echo
echo
echo SUCCESS

helm uninstall $RN
