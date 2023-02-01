#! /bin/bash -e

NAME=zipkin
ID=-$(date +%Y%m%d%H%M%S)
RN=${NAME}$ID

NODE=/foo$ID

echo installing

helm install --wait $RN charts/${NAME}

echo
echo
echo SUCCESS

helm uninstall $RN
