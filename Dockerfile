FROM fishtownanalytics/dbt:0.17.0
USER root
WORKDIR /opt
RUN git clone https://github.com/tglunde/dbt-exasol

RUN pip install -e ./dbt-exasol/

ADD exasol_patch.patch /opt/

RUN patch -ruN -d /usr/local/lib/python3.8/site-packages/dbt < /opt/exasol_patch.patch