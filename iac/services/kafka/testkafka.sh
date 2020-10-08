#!/bin/bash

NS=kafka
BROKER=my-cluster-kafka-bootstrap:9092
TOPIC=my-topic

kubectl -n $NS run kafka-producer -ti --image=strimzi/kafka:0.19.0-kafka-2.5.0 \
    --rm=true --restart=Never -- bin/kafka-console-producer.sh \
    --broker-list $BROKER --topic $TOPIC

kubectl -n $NS run kafka-consumer -ti --image=strimzi/kafka:0.19.0-kafka-2.5.0 \
    --rm=true --restart=Never -- bin/kafka-console-consumer.sh \
    --bootstrap-server $BROKER --topic $TOPIC --from-beginning