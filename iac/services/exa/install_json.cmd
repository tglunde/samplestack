SET EXAUSER=sys
SET EXAPWD=exasol

docker-compose exec exasol awk "/WritePasswd/{ print $3; }" /etc/cos/EXAConf > tmp
SET /p WRITE= < tmp
docker-compose exec exasol awk "/ReadPasswd/{ print $3; }" /etc/cos/EXAConf > tmp
SET /p READ= < tmp
del tmp
echo %WRITE% |base64 -d -i > tmp
SET /p PWDWRITE= < tmp
echo %READ% |base64 -d -i > tmp 
SET /p PWDREAD= < tmp
del tmp


for %%f in (*.sql) do (
    curl -v -X PUT -T "%%f" http://w:%PWDWRITE%@localhost:9583/default/sql/%%f
    docker-compose exec exasol exaplus -u %EXAUSER% -p %EXAPWD% -c localhost:8888 -f /exa/data/bucketfs/bfsdefault/.dest/default/sql/%%f
)

rem for filename in *.sql; do
rem     curl -v -X PUT -T "$filename" http://w:$PWDWRITE@localhost:9583/default/sql/$filename
rem     docker-compose exec exasol exaplus -u $EXAUSER -p $EXAPWD -c localhost:8888 -f /exa/data/bucketfs/bfsdefault/.dest/default/sql/$filename
rem done
