#! /bin/bash -e

sudo ./install-k8s-tools.sh

kind create cluster

for script in ./test-zookeeper.sh ./test-kafka.sh ./test-mysql.sh do

echo ====== $script

$script

done
