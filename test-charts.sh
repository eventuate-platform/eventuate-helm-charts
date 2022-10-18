#! /bin/bash -e

./test-kafka.sh
./test-keycloak.sh
./test-mysql-config-map.sh
./test-mysql.sh
./test-zookeeper.sh
