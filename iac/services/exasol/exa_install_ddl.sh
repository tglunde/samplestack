#!/bin/bash
DSN=localhost:8888
USER=sys
PWD=exasol
EXAPLUS=exaplus

$EXAPLUS -c $DSN -u $USER -p $PWD -sql 'create schema if not exists EXA_TOOLBOX;'
for s in `dirname $0`/*.sql
do
  $EXAPLUS -c $DSN -u $USER -p $PWD -f $s
done
