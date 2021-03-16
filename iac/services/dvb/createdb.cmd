SET DVB_TAG=rel_5.3.0.1_initial_install_only
SET NS=dev
SET PWD=start123
SET USER=SYS
SET SYSPWD=exasol
SET DSN=exasol:8888
SET EXAPLUS=exaplus

kubectl run -it --rm clientdb-exasol --image=datavaultbuilder/clientdb_exasol:%DVB_TAG% --restart=Never --namespace %NS% --env="AUTHENTICATOR_PASSWORD=%PWD%" --command /dvb_sql/create_db.sh -- %DSN% %USER% %SYSPWD%
