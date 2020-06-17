CREATE OR REPLACE VIEW staging.vi_xml_delivery AS 
SELECT DISTINCT * FROM (
SELECT '20200605' AS UPDATED, staging.vi_delivery('http://172.105.76.56/files/' || '20200605' || '/DeliveriesCmpData.xml','dvb','start123') FROM dual);

CREATE OR REPLACE VIEW staging.vi_xml_component AS 
SELECT '20200605' AS UPDATED, staging.vi_component('http://172.105.76.56/files/' || '20200605' || '/CmpPrcDB.xml','dvb','start123') FROM dual;

CREATE OR REPLACE VIEW staging.vi_xml_metric AS 
SELECT DISTINCT * FROM (
SELECT '20200605' AS UPDATED, staging.vi_metric('http://172.105.76.56/files/' || '20200605' || '/metricsDB.xml','dvb','start123') FROM dual);

CREATE OR REPLACE VIEW staging.vi_xml_release AS 
SELECT DISTINCT * FROM (
SELECT '20200605' AS UPDATED, staging.vi_release('http://172.105.76.56/files/' || '20200605' || '/PrdReleaseDependencies.xml','dvb','start123') FROM dual);
