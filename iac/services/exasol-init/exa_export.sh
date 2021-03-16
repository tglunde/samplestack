#!/bin/bash

DSN=$1
FILE=$2
USER=sys
PWD=exasol
EXAPLUS=exaplus

$EXAPLUS -c $DSN -u $USER -p $PWD -sql 'drop table if exists db_history.database_ddl;' 
$EXAPLUS -c $DSN -u $USER -p $PWD -sql 'execute script exa_toolbox.create_ddl(true,true,true);'
$EXAPLUS -c $DSN -u $USER -p $PWD -sql "export (select ddl from db_history.database_ddl) into local csv file '$FILE' DELIMIT=NEVER;"
