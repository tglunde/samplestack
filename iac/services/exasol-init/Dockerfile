FROM datavaultbuilder/clientdb_exasol:rel_5.3.0.1_initial_install_only AS dvb 

FROM openjdk:7
RUN apt update && apt install -y curl ca-certificates-java default-jre

RUN curl -kLO https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/linux/amd64/kubectl
RUN chmod +x kubectl
RUN install kubectl /usr/local/bin

COPY --from=dvb /dvb_sql /dvb_sql
COPY --from=dvb /usr/opt/EXASuite-6/EXASolution-6.2.9 /usr/opt/EXASuite-6/EXASolution-6.2.9 
RUN useradd -b /work -d /work -m -s /bin/bash dvbuser
RUN chown dvbuser:dvbuser -R /dvb_sql/*
USER dvbuser
ENV EXASOL_VERSION=6.2.9
ENV EXA_RE_VERSION=6.2.9
ENV EXA_OS_VERSION=6.2.9
ENV EXA_DB_VERSION=6.2.9
ENV PATH="/usr/opt/EXASuite-6/EXASolution-6.2.9/bin/Console/:${PATH}"
COPY --chown=dvbuser:dvbuser sql /work/sql/
COPY --chown=dvbuser:dvbuser *.sh /work/

#ADD --chown=dvbuser:dvbuser https://github.com/exasol/kafka-connector-extension/releases/download/0.1.0/exasol-kafka-connector-extension-0.1.0.jar /work/
ADD --chown=dvbuser:dvbuser https://drive.exasol.com/f/ca77b626f39c43fa8a1a/?dl=1 /work/exasol-kafka-connector-extension-0.1.0.jar

WORKDIR /work
ENTRYPOINT ["/work/entrypoint.sh"]
