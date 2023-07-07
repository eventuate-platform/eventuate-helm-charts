#! /bin/bash -e

NAME=eventuate-cdc
#ID=-$(date +%Y%m%d%H%M%S)
ID=-xxx
RN=${NAME}$ID
POD=$RN-0
POD_EXEC="kubectl exec $POD -- bash -c "
POD_EXEC_I="kubectl exec -i $POD -- bash -c "

KN=kafka$ID
MYSQL_C=mysql-customer-service$ID
POSTGRES_O=postgres-order-service$ID
CDC=cdc$ID


helm upgrade --install $MYSQL_C ./charts/mysql \
    --set mysqlDatabase=customer_service \
    --set persistentStorage=false \
    --wait

helm upgrade --install $MYSQL_C-init-db charts/initialize-cdc-schema \
    --set dbHost=$MYSQL_C \
    --set dbDatabase=customer_service \
    --set dbCredentialsConfigMap=${MYSQL_C}-database-credentials \
    --wait --wait-for-jobs 

helm upgrade --install $POSTGRES_O ./charts/postgres \
    --set postgresDatabase=order_service \
    --set persistentStorage=false \
    --wait

helm upgrade --install $POSTGRES_O-init-db charts/initialize-cdc-schema \
    --set dbType=postgres \
    --set dbHost=$POSTGRES_O \
    --set dbDatabase=order_service \
    --set dbCredentialsConfigMap=${POSTGRES_O}-database-credentials  \
    --wait --wait-for-jobs 

. ./copy-chart-helpers.sh

update_chart_with_dependency kafka zookeeper

helm upgrade --install --dependency-update --wait $KN $tmp_chart

echo calling mktemp
temp_values=$(mktemp)

echo $temp_values

cat > $temp_values <<END
cdc:
  zookeeper: $KN-zookeeper
  kafka: $KN
  databaseServers:
    - customer-service-mysql:
      readerType: mysql-binlog
      host: ${MYSQL_C}
      credentials:
        username:
          value: root
        password:
          valueFrom:
            secretKeyRef:
              name: ${MYSQL_C}-database-credentials
              key: rootPassword
      databases: 
        - customer_service
    - order-service-mysql:
      readerType: postgres-wal
      host: ${POSTGRES_O}
      credentials:
        username:
          valueFrom:
            secretKeyRef:
              name: ${POSTGRES_O}-database-credentials
              key: postgresUser
        password:
          valueFrom:
            secretKeyRef:
              name: ${POSTGRES_O}-database-credentials
              key: postgresPassword
      databases: 
        - order_service
END

helm upgrade --install eventuate-cdc charts/eventuate-cdc \
    --wait --values $temp_values

echo
echo
echo SUCCESS
echo
echo
