#!/bin/bash

SCHEDULER_PASSWORD=`cat /etc/secrets/scheduler_password`
if [ -n "$SCHEDULER_PASSWORD" ]; then
    cp /root/.pgpass_templ /root/.pgpass
    echo "$SCHEDULER_PASSWORD" >>/root/.pgpass
fi

if [ -n "$MAX_SERVICE_CONNECTION_AGE" ]; then
    MAX_SERVICE_CONNECTION_AGE="-a $MAX_SERVICE_CONNECTION_AGE"
fi

if [ -n "$CONNECTIONSTRING" ]; then
    /usr/bin/pgagent -f "$CONNECTIONSTRING" $MAX_SERVICE_CONNECTION_AGE $PGAGENT_OPTIONS
else
    /usr/bin/pgagent -f "hostaddr=core dbname=datavaultbuilder_core user=pgagent" $MAX_SERVICE_CONNECTION_AGE $PGAGENT_OPTIONS
fi
