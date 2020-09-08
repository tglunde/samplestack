#!/bin/bash
set -eu

function check_jdbc_addon_driver_customer_info() {
	if [ -z "${ADDON_DRIVER_LICENSE_NAME:-}" ] || [ -z "${ADDON_DRIVER_LICENSE_EMAIL}" ]; then
	  return -1
	else
	  return 0
	 fi
}

function unhide_jdbc_addon_driver() {
	/opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core -c "UPDATE dvb_core.source_types SET source_type_is_hidden = FALSE WHERE source_type_id = '$1';"
}

function set_jdbc_addon_driver_license_and_unhide() {
	/opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core -c "UPDATE dvb_core.source_types SET source_type_is_hidden = FALSE, jdbc_addon_driver_license = 'RTK=$2;' WHERE source_type_id = '$1';"
}

if [[ -v SET_NAT_TCP_TIMEOUT ]]; then
         sudo ipvsadm --set ${SET_NAT_TCP_TIMEOUT} 0 0 || true
         sudo ipvsadm -l --timeout || true
fi

if [ -z ${CORE_MAX_WORKER_PROCESSES+x} ]; then
         CORE_MAX_WORKER_PROCESSES=8
fi
if [ -z ${CORE_MAX_PARALLEL_WORKERS+x} ]; then
         CORE_MAX_PARALLEL_WORKERS=3
fi
if [ -z ${CORE_SHARED_BUFFERS+x} ]; then
         CORE_SHARED_BUFFERS="128MB"
fi
if [ -z ${CORE_EFFECTIVE_CACHE_SIZE+x} ]; then
         CORE_EFFECTIVE_CACHE_SIZE="512MB"
fi
if [ -z ${CORE_WORK_MEM+x} ]; then
         CORE_WORK_MEM="8MB"
fi
if [ -z ${CORE_MAINTENANCE_WORK_MEM+x} ]; then
         CORE_MAINTENANCE_WORK_MEM="128MB"
fi
if [ -z ${CORE_MAX_LOCKS_PER_TRANSACTION+x} ]; then
         CORE_MAX_LOCKS_PER_TRANSACTION=1024
fi
if [ -z ${PLJAVA_VMOPTIONS+x} ]; then
         PLJAVA_VMOPTIONS="-Xms128M"
fi
if [ -z ${TIMEZONE+x} ]; then
  export TIMEZONE="Europe/Zurich"
fi
if [ -z ${LD_LIBRARY_PATH+x} ]; then
  export LD_LIBRARY_PATH=/instantclient_12_2
fi
if [ -z ${ORACLE_HOME+x} ]; then
  export ORACLE_HOME=/instantclient_12_2
fi

if [ -z ${CACHE_TEMPLATES+x} ]; then
  CACHE_TEMPLATES=true
fi

sed -e 's~{{MAX_WORKER_PROCESSES}}~'$CORE_MAX_WORKER_PROCESSES'~g' \
	-e 's~{{MAX_PARALLEL_WORKERS}}~'$CORE_MAX_PARALLEL_WORKERS'~g' \
	-e 's~{{SHARED_BUFFERS}}~'$CORE_SHARED_BUFFERS'~g' \
	-e 's~{{EFFECTIVE_CACHE_SIZE}}~'$CORE_EFFECTIVE_CACHE_SIZE'~g' \
	-e 's~{{WORK_MEM}}~'$CORE_WORK_MEM'~g' \
	-e 's~{{MAINTENANCE_WORK_MEM}}~'$CORE_MAINTENANCE_WORK_MEM'~g' \
	-e 's~{{MAX_LOCKS_PER_TRANSACTION}}~'$CORE_MAX_LOCKS_PER_TRANSACTION'~g' \
	-e 's~{{PLJAVA_VMOPTIONS}}~'"$PLJAVA_VMOPTIONS"'~g' \
	-e 's~{{TIMEZONE}}~'"$TIMEZONE"'~g' \
	 /opt/datavaultbuilder/pgsql/data/postgresql.conf.template >  /opt/datavaultbuilder/pgsql/data/postgresql.conf

# set the timezone of the container
sudo /opt/datavaultbuilder/bin/update_timezone.sh ${TIMEZONE}

#/opt/datavaultbuilder/pgsql/bin/pg_ctl -D /opt/datavaultbuilder/pgsql/data -o "-c listen_addresses='localhost'" -w start
cp -f /opt/datavaultbuilder/pgsql/data/pg_hba.startup.conf /opt/datavaultbuilder/pgsql/data/pg_hba.conf
/opt/datavaultbuilder/pgsql/bin/pg_ctl -D /opt/datavaultbuilder/pgsql/data -w start

DBADMIN_PASSWORD=`cat /etc/secrets/core_dbadmin_password`
if [ -n "$DBADMIN_PASSWORD" ]; then

         /opt/datavaultbuilder/pgsql/bin/psql <<EOSQL
         ALTER ROLE "dbadmin" WITH PASSWORD '$DBADMIN_PASSWORD';
EOSQL
         echo "Updated dbadmin password"
fi
if [ -z ${CLIENT_DB_TYPE+x} ]; then
         CLIENT_DB_TYPE=postgres_client_db
fi
if [ -z ${CLIENT_DB_USER+x} ]; then
         CLIENT_DB_USER=authenticator
fi
if [ -z ${CLIENT_DB_CONNECTIONSTRING+x} ]; then
         CLIENT_DB_CONNECTIONSTRING="jdbc:postgresql://clientdb_postgres:5432/datavaultbuilder"
fi

AUTHENTICATOR_PASSWORD=`cat /etc/secrets/authenticator_password`
if [ -n "$AUTHENTICATOR_PASSWORD" ]; then
         /opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core <<EOSQL
         ALTER USER "authenticator" WITH PASSWORD '$AUTHENTICATOR_PASSWORD';
         ALTER USER "authenticator_cp" WITH PASSWORD '$AUTHENTICATOR_PASSWORD';
         SET session_replication_role = replica; -- disable triggers
         UPDATE dvb_config_core.fdb_config SET dvb_db_type_url = '$CLIENT_DB_CONNECTIONSTRING', dvb_db_is_active = TRUE WHERE dvb_db_id = '$CLIENT_DB_TYPE';
         UPDATE dvb_config_core.fdb_config SET dvb_db_is_active = FALSE WHERE dvb_db_id != '$CLIENT_DB_TYPE'; -- because triggers are disabled at the moment
         --UPDATE dvb_config_core.fdb_config SET username = '$CLIENT_DB_USER' WHERE dvb_db_id = '$CLIENT_DB_TYPE' OR dvb_db_id = 'postgres_local_core';
         CLUSTER dvb_config_core.fdb_config USING pk_fdb_config;
         SET session_replication_role = DEFAULT; -- re-enable triggers
EOSQL
         echo "updated authentificator password"

fi

if [ -n "${CLIENT_DB_AUTHENTICATOR_USERNAME:-}" ]; then
  /opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core -c "UPDATE dvb_config_core.fdb_config SET username = '$CLIENT_DB_AUTHENTICATOR_USERNAME' WHERE dvb_db_id = '$CLIENT_DB_TYPE';"
  echo "Updated Authenticator Username for client db"
fi

if [ -n "${CLIENT_DB_CONNECTIONSTRING_USER_AUTHENTICATION:-}" ]; then
  /opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core -c "UPDATE dvb_config_core.fdb_config SET dvb_db_user_authentication_url = '$CLIENT_DB_CONNECTIONSTRING_USER_AUTHENTICATION' WHERE dvb_db_id = '$CLIENT_DB_TYPE';"
  echo "Updated user authentification connection string"
fi


if [ "${DISABLE_IMPERSONATE:-}" = "true" ]; then
	/opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core -c "UPDATE dvb_config_core.fdb_config SET switch_user = FALSE WHERE dvb_db_is_active;"
elif [ "${DISABLE_IMPERSONATE:-}" = "false" ]; then
	/opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core -c "UPDATE dvb_config_core.fdb_config SET switch_user = TRUE WHERE dvb_db_is_active;"
fi

if [ -n "${SNOWFLAKE_DATABASE:-}" ]; then
  /opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core -c "UPDATE dvb_config_core.fdb_type_parameters SET additional_session_init_commands = array_replace(additional_session_init_commands, 'USE DATAVAULTBUILDER', 'USE ${SNOWFLAKE_DATABASE}') WHERE dvb_db_type_id = 'snowflake';"
  echo "Updated Snowflake Database Name"
fi

#refresh clientdb connection pool settings
#/opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core -c "SELECT dvb_core.f_restart_connection_pool(poolname => 'clientdb', restart_delay_in_sec => 0);" # TODO: make that working
echo "refrehed connection pool to client db"
#wait until clientdb is up
echo "waiting for client db..."
/opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core -c "SELECT dvb_core.f_wait_for_client_db();"
echo "client db found!"


/opt/datavaultbuilder/pgsql/bin/psql -v ON_ERROR_STOP=1 -U dbadmin -d datavaultbuilder_core <<EOSQL
		\set ON_ERROR_STOP true
		SELECT dvb_config_core.case_environment_constants();
		SELECT dvb_core.f_initialize_client_db_specifics();
		REFRESH MATERIALIZED VIEW dvb_core.api_hook_templates;
		SELECT dvb_core.f_refresh_config();
		SELECT dvb_cache.f_refresh_caches();
		SELECT dvb_core.f_update_internal_schedule_id_sequence();
		REFRESH MATERIALIZED VIEW dvb_core.x_relations;
		SELECT dvb_core.f_fixes_on_startup();
		SELECT dvb_core.f_refresh_x_relations();
		SELECT dvb_core.f_refresh_config();
EOSQL
if [ $? -eq 0 ]; then
    echo "Core Maintenace successful"
else
	echo "Startup Failed...please check log above and try restart. If the error persists, please Contact DVB Support"
fi

if [ "${ENABLE_BETA_FEATURES:-}" = "true" ]; then
	ENABLE_BETA_FEATURES=TRUE
else
	ENABLE_BETA_FEATURES=FALSE
fi
/opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core -c "INSERT INTO dvb_config_core.core_config (config_key, config_value, config_type) VALUES ('enable_beta_features', '$ENABLE_BETA_FEATURES', 'general') ON CONFLICT (config_key) DO UPDATE SET config_value=EXCLUDED.config_value, config_type=EXCLUDED.config_type;"

set +o nounset
if [ -n "$GUI_USER_NAME" ]; then
         if [ -n "$GUI_USER_PASSWORD" ]; then
                  if [ -z ${GUI_USER_EMAIL+x} ]; then
                           GUI_USER_EMAIL=""
                  fi
                  GUI_USER_GROUP="dvb_admin" # overwrites environment variable
                  if [ -z ${GUI_USER_TEXT+x} ]; then
                           GUI_USER_TEXT="Added via Docker parameters"
                  fi
                  /opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core <<EOSQL
                  select dvb_core.f_create_user('$GUI_USER_NAME','$GUI_USER_EMAIL','$GUI_USER_PASSWORD','$GUI_USER_GROUP','$GUI_USER_TEXT',null)
EOSQL
                  echo "created initial GUI user"
         fi
fi

if [ "${USE_UNSECURE_DEFAULT_ENCRYPTION_KEYS:-}" = "true" ]; then
         /opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core <<EOSQL
         INSERT INTO dvb_config_core.core_config (config_key, config_value, config_comment, config_type)
           VALUES ('systems_password_private_key_file', '/opt/datavaultbuilder/etc/default_keys/systems_password_private_key', 'Path to private key file', 'secret_path')
           ON CONFLICT (config_key) DO
           UPDATE SET config_value = EXCLUDED.config_value, config_comment = EXCLUDED.config_comment, config_type = EXCLUDED.config_type;
         INSERT INTO dvb_config_core.core_config (config_key, config_value, config_comment, config_type)
           VALUES ('systems_password_private_key_password_file', '/opt/datavaultbuilder/etc/default_keys/systems_password_private_key_password', 'Path to private key password file', 'secret_path')
           ON CONFLICT (config_key) DO
           UPDATE SET config_value = EXCLUDED.config_value, config_comment = EXCLUDED.config_comment, config_type = EXCLUDED.config_type;
         INSERT INTO dvb_config_core.core_config (config_key, config_value, config_comment, config_type)
           VALUES ('systems_password_public_key_file', '/opt/datavaultbuilder/etc/default_keys/systems_password_public_key', 'Path to public key file', 'secret_path')
           ON CONFLICT (config_key) DO
           UPDATE SET config_value = EXCLUDED.config_value, config_comment = EXCLUDED.config_comment, config_type = EXCLUDED.config_type;
EOSQL
         echo "updated default encryption keys"
else
         /opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core <<EOSQL
         UPDATE dvb_config_core.core_config SET config_value = NULL WHERE config_key = 'systems_password_private_key_file' AND config_value = '/opt/datavaultbuilder/etc/default_keys/systems_password_private_key';
         UPDATE dvb_config_core.core_config SET config_value = NULL WHERE config_key = 'systems_password_private_key_password_file' AND config_value = '/opt/datavaultbuilder/etc/default_keys/systems_password_private_key_password';
         UPDATE dvb_config_core.core_config SET config_value = NULL WHERE config_key = 'systems_password_public_key_file' AND config_value = '/opt/datavaultbuilder/etc/default_keys/systems_password_public_key';
EOSQL
         if [ ! -f "/etc/secrets/systems_password_public_key" ]; then
	 	echo "----------------------------------"
		echo "No password encryption keys found. Either generate a key pair with gpg and include them with docker secret or set the environment variable 'USE_UNSECURE_DEFAULT_ENCRYPTION_KEYS=true'"
		echo "----------------------------------"
	 fi
fi

# push license in core db
if [ -f /etc/secrets/datavault_builder_license ]; then
	/opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core -c "INSERT INTO dvb_config_core.license (license_id, license_key) VALUES (0, '$(cat /etc/secrets/datavault_builder_license)') ON CONFLICT (license_id) DO UPDATE SET license_key = EXCLUDED.license_key;"
	echo "updated datavaultbuilder license"
fi

SCHEDULER_PASSWORD=`cat /etc/secrets/scheduler_password`
if [ -n "$SCHEDULER_PASSWORD" ]; then
				/opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core -c "ALTER USER \"pgagent\" WITH PASSWORD '$SCHEDULER_PASSWORD';"
				echo "updated pgagent password"
fi

#if [ -n "${ADDON_EXCEL_DRIVER_RTK:-}" ]; then
#	set_jdbc_addon_driver_license_and_unhide msexcelfilecd ${ADDON_EXCEL_DRIVER_RTK}
#elif [ "${ADDON_EXCEL_DRIVER_TRIAL:-}" = "true" ] && [ ! -f /opt/datavaultbuilder/lib/jdbc_addon_drivers/cdata.jdbc.excel.lic ]; then
#	if $(check_jdbc_addon_driver_customer_info); then
#		#get trial license lic file
#		DRIVERNAME=excel /opt/datavaultbuilder/bin/get_addon_driver_trial_license.sh
#		unhide_jdbc_addon_driver msexcelfilecd
#	fi
#fi

if [ -n "${ADDON_REST_DRIVER_RTK:-}" ]; then
	set_jdbc_addon_driver_license_and_unhide restcd ${ADDON_REST_DRIVER_RTK}
elif [ "${ADDON_REST_DRIVER_TRIAL:-}" = "true" ] && [ ! -f /opt/datavaultbuilder/lib/jdbc_addon_drivers/cdata.jdbc.rest.lic ]; then
	if $(check_jdbc_addon_driver_customer_info); then
		#get lic file
		DRIVERNAME=rest MAINCLASS=cdata.jdbc.rest.RESTDriverMain /opt/datavaultbuilder/bin/get_addon_driver_trial_license_rssbus.sh
		unhide_jdbc_addon_driver restcd
	fi
fi

if [ -n "${ADDON_SALESFORCE_DRIVER_RTK:-}" ]; then
	set_jdbc_addon_driver_license_and_unhide salesforcecd ${ADDON_SALESFORCE_DRIVER_RTK}
elif [ "${ADDON_SALESFORCE_DRIVER_TRIAL:-}" = "true" ] && [ ! -f /opt/datavaultbuilder/lib/jdbc_addon_drivers/cdata.jdbc.salesforce.lic ]; then
	if $(check_jdbc_addon_driver_customer_info); then
		#get lic file
		DRIVERNAME=salesforce /opt/datavaultbuilder/bin/get_addon_driver_trial_license.sh
		unhide_jdbc_addon_driver salesforcecd
	fi
fi

if [ "${ENABLE_EXCEL:-}" = "true" ]; then
  unhide_jdbc_addon_driver msexcelfilepd
fi

if [ "${ENABLE_THEOBALD:-}" = "true" ]; then
  unhide_jdbc_addon_driver theobaldpd
fi

if [ "${ENABLE_XML_FILES:-}" = "true" ]; then
  unhide_jdbc_addon_driver xmlfilepd
fi

if [ "${ENABLE_DATAVIRTUALITY:-}" = "true" ]; then
  unhide_jdbc_addon_driver datavirtuality
fi

if [ "${DOWNLOAD_DEMO_DATA:-}" = "true" ]; then
	set +eu
  echo "Loading demo data files"
	/usr/bin/wget -nv -T 30 -O "/files/AIRPORT.csv"  "https://datavault-builder-public-data.2150.ch/demo_data/AIRPORT.csv"
	chmod 666 "/files/AIRPORT.csv"
	/usr/bin/wget -nv -T 30 -O "/files/ONTIME_20171221-27.csv"  "https://datavault-builder-public-data.2150.ch/demo_data/ONTIME_20171221-27.csv"
	chmod 666 "/files/ONTIME_20171221-27.csv"
	/usr/bin/wget -nv -T 30 -O "/files/AIRLINE.csv"  "https://datavault-builder-public-data.2150.ch/demo_data/AIRLINE.csv"
	chmod 666 "/files/AIRLINE.csv"
	/usr/bin/wget -nv -T 30 -O "/files/WORLD_AREA_CODES.csv"  "https://datavault-builder-public-data.2150.ch/demo_data/WORLD_AREA_CODES.csv"
	chmod 666 "/files/WORLD_AREA_CODES.csv"
	set -eu
fi

if [ "${DOWNLOAD_TEST_DATA:-}" = "true" ]; then
	set +eu
  echo "Loading test data files"
	/usr/bin/wget -nv -T 30 -O "/files/excel_test.xlsx"  "https://datavault-builder-public-data.2150.ch/test_data/v1/excel_test.xlsx"
	chmod 666 "/files/excel_test.xlsx"
	/usr/bin/wget -nv -T 30 -O "/files/excel_old_test.xls"  "https://datavault-builder-public-data.2150.ch/test_data/v1/excel_old_test.xls"
	chmod 666 "/files/excel_old_test.xls"
	/usr/bin/wget -nv -T 30 -O "/files/googlemaps.json"  "https://datavault-builder-public-data.2150.ch/test_data/v1/googlemaps.json"
	chmod 666 "/files/googlemaps.json"
  /usr/bin/wget -nv -T 30 -O "/files/bigExcel_test.xlsx"  "https://datavault-builder-public-data.2150.ch/test_data/v1/bigExcel_test.xlsx"
  chmod 666 "/files/bigExcel_test.xlsx"
	set -eu
fi

echo "sleep to finish refresh of materialized views"
sleep "${REFRESH_WAIT_TIME_IN_SECONDS:-0}"


echo -e "\nRestart Core PostgreSQL Server - Stopping..."
/opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core -c "SELECT dvb_core.f_restart_connection_pool(poolname => 'core', restart_delay_in_sec => 0);"
/opt/datavaultbuilder/pgsql/bin/pg_ctl stop -D /opt/datavaultbuilder/pgsql/data -m f -w -t 60 || \
/opt/datavaultbuilder/pgsql/bin/pg_ctl stop -D /opt/datavaultbuilder/pgsql/data -m i -w -t 20
cp -f /opt/datavaultbuilder/pgsql/data/pg_hba.running.conf /opt/datavaultbuilder/pgsql/data/pg_hba.conf
echo -e "\n   Core PostgreSQL Server running...\n"
### start in virtual environment with python 3.6 ###
scl enable rh-python36 "/opt/datavaultbuilder/pgsql/bin/pg_ctl -D /opt/datavaultbuilder/pgsql/data -w start \
&& /opt/datavaultbuilder/pgsql/bin/psql -U dbadmin -d datavaultbuilder_core -c \"SELECT dvb_core.f_restart_connection_pool(poolname => 'core', restart_delay_in_sec => 0);\" \
&& pglog"