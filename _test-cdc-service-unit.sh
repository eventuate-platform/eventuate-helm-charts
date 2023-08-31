#! /bin/bash -e

set -o pipefail

bootstrap_servers() {
    yq '. | select(.kind == "Deployment") | .spec.template.spec.containers[].env | .[] | select(.name == "EVENTUATELOCAL_KAFKA_BOOTSTRAP_SERVERS") | .value'
}

zookeeper_connection_string() {
    yq '. | select(.kind == "Deployment") | .spec.template.spec.containers[].env | .[] | select(.name == "EVENTUATELOCAL_ZOOKEEPER_CONNECTION_STRING") | .value'
}

assert_equals() {
    if [ "$1" != "$2" ]; then
        echo "Expected $1 but got $2"
        exit 1
    fi
}

assert_equals "kafka:9092" "$(helm template eventuate-cdc charts/eventuate-cdc | bootstrap_servers)" 

assert_equals "foo:9092" "$(helm template eventuate-cdc charts/eventuate-cdc --set cdc.kafka=foo | bootstrap_servers)" 

assert_equals "foo:9093" "$(helm template eventuate-cdc charts/eventuate-cdc --set cdc.kafkaBootstrapBrokers=foo:9093 | bootstrap_servers)" 

assert_equals "zookeeper:2181" "$(helm template eventuate-cdc charts/eventuate-cdc | zookeeper_connection_string)" 

assert_equals "foo:2181" "$(helm template eventuate-cdc charts/eventuate-cdc --set cdc.zookeeper=foo | zookeeper_connection_string)" 

assert_equals "foo:2182" "$(helm template eventuate-cdc charts/eventuate-cdc --set cdc.zookeeperConnectString=foo:2182 | zookeeper_connection_string)" 

echo
echo SUCCESS
echo




