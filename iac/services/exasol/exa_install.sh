#!/bin/sh

EXA_POD=exasol-0
EXA_BUCKETFS=localhost:8889

WRITE=`kubectl -n dev exec $EXA_POD -- awk '/WritePasswd/{ print $3; }' /exa/etc/EXAConf | base64 -d`
READ=`kubectl -n dev exec $EXA_POD -- awk '/ReadPasswd/{ print $3; }' /exa/etc/EXAConf | base64 -d`

curl -X PUT -T exasol-kafka-connector-extension-0.1.0.jar http://w:$WRITE@$EXA_BUCKETFS/default/

