#! /bin/bash -e

sudo ./install-k8s-tools.sh

./test-zookeeper.sh

./test-kafka.sh

./test-mysql.sh
