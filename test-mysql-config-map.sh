#! /bin/bash -e

NAME=mysql
ID=-$(date +%Y%m%d%H%M%S)
NS=test-${NAME}$ID
RN=${NAME}$ID
POD=$RN-0
POD_EXEC="kubectl -n $NS exec $POD -- bash -c "
POD_EXEC_I="kubectl -n $NS exec -i $POD -- bash -c "

NODE=/foo$ID

echo installing

MYSQL_VALUES="envSecretKeyRefs:
  - name: mysql-helm-test-db-secrets${ID}
    key: rootpassword
    env: MYSQL_ROOT_PASSWORD
  - name: mysql-helm-test-db-secrets${ID}
    key: user
    env: MYSQL_USER
  - name: mysql-helm-test-db-secrets${ID}
    key: password
    env: MYSQL_PASSWORD
"

kubectl create namespace "$NS"

kubectl -n $NS create secret generic mysql-helm-test-db-secrets${ID} \
--from-literal=rootpassword=rootXXX \
--from-literal=user=mysqluser \
--from-literal=password=mysqlpasswordXX

helm install -n $NS --wait $RN charts/${NAME} --values <(echo "$MYSQL_VALUES")

echo testing

helm test -n $NS $RN

echo tested

$POD_EXEC "echo 'create table foo (bar varchar(100));' | mysql -h$RN  -umysqluser -pmysqlpasswordXX -o eventuate -P 3306"

helm uninstall -n $NS $RN
kubectl delete namespace $NS 
