#! /bin/bash -e

NODE=/foo$(date +%Y%m%d%H%M%S)

kubectl exec zookeeper-0 -- bash -c "cd /usr/local/apache-zookeeper-3.5.6-bin ; echo create $NODE | bin/zkCli.sh -server zookeeper:2181"
kubectl exec zookeeper-0 -- bash -c "cd /usr/local/apache-zookeeper-3.5.6-bin ; echo set $NODE bar | bin/zkCli.sh -server zookeeper:2181"
kubectl exec zookeeper-0 -- bash -c "cd /usr/local/apache-zookeeper-3.5.6-bin ; echo get $NODE | bin/zkCli.sh -server zookeeper:2181"

# kubectl exec zookeeper-0 -- bash -c "cd /usr/local/apache-zookeeper-3.5.6-bin ; echo get /foo | bin/zkCli.sh -server zookeeper:2181"

echo
echo
echo SUCCESS
