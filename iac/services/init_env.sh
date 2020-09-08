##create exasol db
mkdir -p /root/env_torsten/env_torsten_db
mkdir /root/env_torsten/env_torsten_db/exa
cp docker-compose.exa.yml /root/env_torsten/env_torsten_db/

mkdir -p /root/env_torsten/env_torsten_dvb
mkdir -p /root/env_torsten/env_torsten_dvb/secrets
cp docker-compose.dvb.yml /root/env_torsten/env_torsten_dvb/
echo "DVB_TAG=rel_5_b2.4" > .env
echo "TIMEZONE=Europe/Berlin" >> .env

# install dvb structures on exasol
cd dvb_dir
docker run -it --rm --entrypoint=/bin/bash --mount type=bind,ro=true,src=$(pwd)/secrets/authenticator_password.txt,dst=/run/secrets/authenticator_password datavaultbuilder/clientdb_exasol:rel_5_b2.4 /dvb_sql/create_db.sh IP:PORT sys SYSPWD
