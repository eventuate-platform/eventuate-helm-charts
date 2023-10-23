#! /bin/bash -e

NAME=mysql
ID=-$(date +%Y%m%d%H%M%S)
RN=${NAME}$ID
POD=$RN-0
POD_EXEC="kubectl exec $POD -- bash -c "
POD_EXEC_I="kubectl exec -i $POD -- bash -c "
TEST_DATABASE=test_database

NODE=/foo$ID

echo installing

helm install --wait $RN charts/${NAME} --set mysqlDatabase=$TEST_DATABASE

echo testing

helm test $RN

$POD_EXEC "echo 'create table foo (bar varchar(100));' | mysql -h$RN  -uroot -prootpassword -o $TEST_DATABASE -P 3306"

echo deleting

kubectl delete po --wait=true $POD

kubectl wait --for=condition=ready pod --timeout=90s $POD

echo testing persistence

sleep 10

set count=1

until $POD_EXEC "echo 'select * from foo;' | mysql -h$RN  -uroot -prootpassword -o $TEST_DATABASE -P 3306" ; do
    count=$((count+1))
    if [ "$count" = "10" ] ; then
        break
    fi
    echo $count
    sleep 5
done


$POD_EXEC "echo 'select * from foo;' | mysql -h$RN  -uroot -prootpassword -o $TEST_DATABASE -P 3306"

echo
echo
echo SUCCESS

helm uninstall $RN
