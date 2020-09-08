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
	/opt/datavaultbuilder/pgsql/bin/psql -h core -U dbadmin -d datavaultbuilder_core -c "UPDATE dvb_core.source_types SET source_type_is_hidden = FALSE WHERE source_type_id = '$1';"
}

function set_jdbc_addon_driver_license_and_unhide() {
	/opt/datavaultbuilder/pgsql/bin/psql -h core -U dbadmin -d datavaultbuilder_core -c "UPDATE dvb_core.source_types SET source_type_is_hidden = FALSE, jdbc_addon_driver_license = 'RTK=$2;' WHERE source_type_id = '$1';"
}

if [[ -v SET_NAT_TCP_TIMEOUT ]]; then
         sudo ipvsadm --set ${SET_NAT_TCP_TIMEOUT} 0 0 || true
         sudo ipvsadm -l --timeout || true
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

# set the timezone of the container
sudo /opt/datavaultbuilder/bin/update_timezone.sh ${TIMEZONE}

# wait for core
cp /opt/datavaultbuilder/connection_pool/etc/.pgpass.template ~/.pgpass
cat /etc/secrets/authenticator_password >> ~/.pgpass
chmod 0600 ~/.pgpass
#/opt/datavaultbuilder/pgsql/bin/psql -h core -U dbadmin -d datavaultbuilder_core -c "SELECT dvb_core.f_wait_for_client_db(false);"
/opt/datavaultbuilder/pgsql/bin/psql -h core -U authenticator_cp -d datavaultbuilder_core \
  -c "SELECT public.set_user_u('dbadmin');" \
	-c "SELECT dvb_core.f_wait_for_client_db(false);" \
	-c "SELECT public.reset_user('token');"


if [ -n "${ADDON_EXCEL_DRIVER_RTK:-}" ]; then
	set_jdbc_addon_driver_license_and_unhide msexcelfilecd ${ADDON_EXCEL_DRIVER_RTK}
elif [ "${ADDON_EXCEL_DRIVER_TRIAL:-}" = "true" ] && [ ! -f /opt/datavaultbuilder/lib/jdbc_addon_drivers/cdata.jdbc.excel.lic ]; then
	if $(check_jdbc_addon_driver_customer_info); then
		#get trial license lic file
		DRIVERNAME=excel /opt/datavaultbuilder/bin/get_addon_driver_trial_license.sh
		unhide_jdbc_addon_driver msexcelfilecd
	fi
fi

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

if [ "${ENABLE_XML_FILES:-}" = "true" ]; then
  unhide_jdbc_addon_driver xmlfilepd
fi

#rm -f ~/.pgpass

# Starting connection pool
export CLASSPATH=/opt/datavaultbuilder/lib/jdbc_drivers/
scl enable rh-python36 "java -Duser.language=en -Duser.country=US -Djava.security.egd=file:///dev/urandom -Doracle.jdbc.J2EE13Compliant=true ${JAVA_OPTS:-} -jar /opt/datavaultbuilder/lib/dvb_connection_pool-0.0.3-SNAPSHOT-jar-with-dependencies.jar"
#-Dnet.snowflake.jdbc.loggerImpl=net.snowflake.client.log.SLF4JLogger
