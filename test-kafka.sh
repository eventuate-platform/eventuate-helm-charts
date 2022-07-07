#! /bin/bash -e

NAME=kafka
ID=-$(date +%Y%m%d%H%M%S)
RN=${NAME}$ID
POD=$RN-0
POD_EXEC="kubectl exec $POD -- bash -c "
POD_EXEC_I="kubectl exec -i $POD -- bash -c "

ZKN=zookeeper$ID

MESSAGE=/foomessage$ID

echo installing

helm install --wait $ZKN charts/zookeeper
helm install --wait $RN charts/${NAME}  --set zookeeper.hostname=$ZKN

echo helm test

helm test ${NAME}$ID

echo creating topic

$POD_EXEC 'bin/kafka-topics.sh  --bootstrap-server $RN:9092 --create --topic foofoo'

echo producing

echo foo:$MESSAGE | $POD_EXEC_I "bin/kafka-console-producer.sh   --topic foofoo   --bootstrap-server $RN:9092   --property parse.key=true   --property key.separator=":"" 

echo consuming

$POD_EXEC "bin/kafka-console-consumer.sh   --topic foofoo   --bootstrap-server $RN:9092  --max-messages 1  --from-beginning --timeout-ms 10000" | grep $MESSAGE

helm uninstall $RN
helm uninstall $ZKN

