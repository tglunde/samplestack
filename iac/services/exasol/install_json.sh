#/bin/sh
EXAUSER=sys
EXAPWD=exasol
WRITE=$(docker-compose exec exasol awk '/WritePasswd/{ print $3; }' /etc/cos/EXAConf)
READ=$(docker-compose exec exasol awk '/ReadPasswd/{ print $3; }' /etc/cos/EXAConf)

PWDWRITE=$(echo $WRITE |base64 -d -i)
PWDREAD=$(echo $READ |base64 -d -i)

for filename in *.sql; do
    curl -v -X PUT -T "$filename" http://w:$PWDWRITE@localhost:9583/default/sql/$filename
    docker-compose exec exasol exaplus -u $EXAUSER -p $EXAPWD -c localhost:8888 -f /exa/data/bucketfs/bfsdefault/.dest/default/sql/$filename
done
