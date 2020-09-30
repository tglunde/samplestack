FROM python:3.8.6-slim-buster 
RUN pip install dbt==0.17.2 
RUN pip install dbt-exasol
COPY exasol_patch.patch /tmp/
RUN apt update && apt install patch git -y && apt clean
RUN patch -ruN -d /usr/local/lib/python3.8/site-packages/dbt < /tmp/exasol_patch.patch
RUN mkdir -p /usr/app && groupadd dbtuser && useradd -d /usr/app -g dbtuser dbtuser && chown -R dbtuser:dbtuser /usr/app
USER dbtuser
WORKDIR /usr/app
COPY dbt /usr/app/
ENTRYPOINT ["dbt"]

