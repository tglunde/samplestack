#!/bin/sh
DVB_TAG=rel_5.3.0.1_initial_install_only
NS=dev
PWD=$(cat secrets/authenticator_password.txt)
USER=SYS
SYSPWD=exasol
DSN=exasol:8888
EXAPLUS=/datadrive/EXAplus-6.2.3/exaplus

kubectl run -it --rm clientdb-exasol --image=datavaultbuilder/clientdb_exasol:$DVB_TAG \
        --restart=Never --namespace $NS --env="AUTHENTICATOR_PASSWORD=$PWD" \
        --command /dvb_sql/create_db.sh -- $DSN $USER $SYSPWD
