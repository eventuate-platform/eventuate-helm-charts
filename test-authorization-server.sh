#! /bin/bash -e

NAME=authorization-server
ID=-$(date +%Y%m%d%H%M%S)
#ID=-xxx
RN=${NAME}$ID

echo installing

helm upgrade --install --wait $RN charts/${NAME}

echo
echo
echo SUCCESS

echo TESTING

helm test $RN

helm uninstall $RN
