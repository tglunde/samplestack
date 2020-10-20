#!/bin/bash

#java -jar /work/avro-tools-1.10.0.jar getschema /work/message.avro > /work/schema.avsc
#java -jar /work/avro-tools-1.10.0.jar tojson /work/message.avro > /work/message.json
/usr/bin/kafka-avro-console-producer --bootstrap-server  my-cluster-kafka-bootstrap:9092 \
    --topic=mytopic \
    --property schema.registry.url=http://kafka-sr-schema-registry:8081 \
    --property value.schema='{"type":"record","name":"mysecond","fields":[{"name":"Metadata","type":"string"}]}'
