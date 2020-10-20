#!/bin/bash
DSN=$1
EXA_BUCKETFS=$2
NS=$3
USER=sys
PWD=exasol
EXAPLUS=exaplus
EXA_POD=$(kubectl get pod -n $NS |grep exasol | awk '{print $1}')

$EXAPLUS -c $DSN -u $USER -p $PWD -sql 'create schema if not exists EXA_TOOLBOX;'
for s in `dirname $0`/sql/*.sql
do
  $EXAPLUS -c $DSN -u $USER -p $PWD -f $s
done

WRITE=`kubectl -n $NS exec $EXA_POD -- awk '/WritePasswd/{ print $3; }' /exa/etc/EXAConf | base64 -d`
READ=`kubectl -n $NS exec $EXA_POD -- awk '/ReadPasswd/{ print $3; }' /exa/etc/EXAConf | base64 -d`

curl -X PUT -T  `dirname $0`/exasol-kafka-connector-extension-0.1.0.jar http://w:$WRITE@$EXA_BUCKETFS/default/