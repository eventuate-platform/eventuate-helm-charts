#! /bin/bash -e

sudo ./install-k8s-tools.sh

kind create cluster

./test-zookeeper.sh

./test-kafka.sh

./test-mysql.sh
