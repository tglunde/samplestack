#!/bin/bash

DSN=localhost:8888
USER=sys
PWD=exasol
EXAPLUS=exaplus

$EXAPLUS -c $DSN -u $USER -p $PWD -f $1
