EXAUSER=sys
EXAPWD=exasol
#WRITE=$(docker-compose exec exasol awk '/WritePasswd/{ print $3; }' /etc/cos/EXAConf)
#READ=$(docker-compose exec exasol awk '/ReadPasswd/{ print $3; }' /etc/cos/EXAConf)

#PWDWRITE=$(echo $WRITE |base64 -d -i)
#PWDREAD=$(echo $READ |base64 -d -i)

EXACMD="docker-compose exec exasol exaplus -u $EXAUSER -p $EXAPWD -c localhost:8888"
for filename in *.json; do
    EVENT_NAME=${filename%.*}
    EVENT_LDTS=$(jq -r ".timestamp" $filename | sed 's/T/ /' | sed 's/Z//')
    EVENT_JSON=$(jq -r "." $filename)
#    echo $EVENT_LDTS
    docker-compose -f ../../iac/services/exa/docker-compose.yml \ 
        exec exasol exaplus -u $EXAUSER -p $EXAPWD -c localhost:8888 \
        -sql "INSERT INTO EXA_TOOLBOX.EVENT values (to_timestamp('$EVENT_LDTS','YYYY-MM-DD HH24:MI:SS.FF3'),'$EVENT_NAME','$EVENT_JSON');"
#    echo $JSON
#    curl -X PUT -T "$filename" http://w:$PWDWRITE@localhost:9583/default/sql/$filename
#    docker-compose exec exasol exaplus -u $EXAUSER -p $EXAPWD -c localhost:8888 -f /exa/data/bucketfs/bfsdefault/.dest/default/sql/$filename
done