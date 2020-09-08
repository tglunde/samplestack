FROM preset/superset:latest

RUN superset fab create-admin \
               --username admin \
               --firstname Superset \
               --lastname Admin \
               --email admin@superset.com \
               --password admin

RUN superset db upgrade

RUN superset load_examples

RUN superset init

COPY ./requirements* ./docker/requirements* /app/

USER root
RUN apt update ; apt install -y unixodbc unixodbc-dev vim
ADD EXASOL_ODBC-6.2.5.tar.gz /
RUN chown -R superset:superset /EXASOL_ODBC-6.2.5
COPY exasol_odbc.ini /app/superset_home/.odbc.ini
COPY exasol_odbcinst.ini /etc/odbcinst.ini
COPY exasol_odbcinst_template.ini /etc/
COPY exasol_connect_test*.py /app/superset_home/
RUN usermod --home /app/superset_home superset; chown superset:superset /app/superset_home/.odbc.ini /app/superset_home/*.py
RUN cd /app \
    && pip install -e . \
    && pip install --no-cache -r requirements.txt -r requirements-dev.txt \
    && pip install --no-cache -r requirements-extra.txt \
    && pip install --no-cache -r requirements-local.txt || true
USER superset
