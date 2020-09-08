#!/bin/bash

cp /opt/datavaultbuilder/api/etc/.pgpass.template_dbadmin ~/.pgpass
cat /etc/secrets/core_dbadmin_password >> ~/.pgpass
chmod 0600 ~/.pgpass

# set the timezone of the container
sudo /opt/datavaultbuilder/bin/update_timezone.sh ${TIMEZONE}

if [ -f /etc/secrets/jwt_secret ]; then
	JWT_SECRET='@/etc/secrets/jwt_secret'
else
  JWT_SECRET=`head -c 512 /dev/urandom | tr -dc A-Za-z0-9 | head -c 64`
fi
if [ -z "$CONNECTION_POOL" ]; then
	export CONNECTION_POOL=30
fi
if [ -z "$IP_BINDING" ]; then
	export IP_BINDING='*4'
fi

sed -e "s~{{JWT_SECRET}}~$JWT_SECRET~g" \
  /opt/datavaultbuilder/api/etc/postgrest.conf.template > /etc/postgrest.conf
chmod 0600 /etc/postgrest.conf

export PATH=/opt/datavaultbuilder/pgsql/bin:${PATH}

# in case the jwt is in a docker secret, we need it in a variable now
if  [ "$JWT_SECRET" ==  "@/etc/secrets/jwt_secret" ]; then
	JWT_SECRET=`cat /etc/secrets/jwt_secret`
fi
until /opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core -h core <<EOSQL
  SELECT dvb_core.f_store_jwt_secret('$JWT_SECRET');
EOSQL
do
	echo "Waiting for core to start..."
  sleep 1
done
echo "JWT secret successfully stored in core."
echo "Starting Postgrest..."

# now we need only the authenticator password in .pgpass
cp /opt/datavaultbuilder/api/etc/.pgpass.template_authenticator ~/.pgpass
cat /etc/secrets/authenticator_password >> ~/.pgpass

/usr/local/bin/postgrest /etc/postgrest.conf
