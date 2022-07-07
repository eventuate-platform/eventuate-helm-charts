#! /bin/bash -e

kubectl get po

mkdir -p ~/pod-logs

kubectl get po > ~/pod-logs/pods.txt

for name in $(kubectl get po -o json | jq -r .items[].metadata.name) ; do
    kubectl logs $name > ~/pod-logs/${name}.txt
done