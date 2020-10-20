FROM confluentinc/cp-schema-registry:latest

COPY --chown=appuser:appuser jq-linux64 /work/
COPY --chown=appuser:appuser produce.sh /work/
COPY --chown=appuser:appuser message.avro /work/
COPY --chown=appuser:appuser avro-tools*.jar /work/
