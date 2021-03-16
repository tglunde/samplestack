create schema if not exists EXA_TOOLBOX;

CREATE OR REPLACE JAVA SET SCRIPT EXA_TOOLBOX.KAFKA_CONSUMER(...) EMITS (...) AS
  %scriptclass com.exasol.cloudetl.kafka.KafkaConsumerQueryGenerator;
  %jar /buckets/bfsdefault/default/exasol-kafka-connector-extension-0.1.0.jar;
/

CREATE OR REPLACE JAVA SET SCRIPT EXA_TOOLBOX.KAFKA_IMPORT(...) EMITS (...) AS
  %scriptclass com.exasol.cloudetl.kafka.KafkaTopicDataImporter;
  %jar /buckets/bfsdefault/default/exasol-kafka-connector-extension-0.1.0.jar;
/

CREATE OR REPLACE JAVA SET SCRIPT EXA_TOOLBOX.KAFKA_METADATA(
  params VARCHAR(2000), 
  kafka_partition DECIMAL(18, 0), 
  kafka_offset DECIMAL(36, 0)
)
EMITS (partition_index DECIMAL(18, 0), max_offset DECIMAL(36,0)) AS
  %scriptclass com.exasol.cloudetl.kafka.KafkaTopicMetadataReader;
  %jar /buckets/bfsdefault/default/exasol-kafka-connector-extension-0.1.0.jar;
/  