FROM confluentinc/cp-schema-registry:latest

COPY --chown=appuser:appuser jq-linux64 /work/
RUN chmod u+x /work/jq-linux64
COPY --chown=appuser:appuser produce.sh /work/
COPY --chown=appuser:appuser message.avro /work/
COPY --chown=appuser:appuser message2.avro /work/
COPY --chown=appuser:appuser message3.avro /work/
COPY --chown=appuser:appuser avro-tools*.jar /work/
