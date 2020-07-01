
   SELECT 
      d.CUSTOMER as customer,
      d.DELIVERY_GUID as delivery_guid,
      d.DELIVERY_CBD_NUMBER as delivery_cbd_number,
      d.delivery_number as delivery_number,
      urc.dlvry_cmp_name as component_name,
      urc.dlvry_cmp_version as component_version,
      urc.cmp_guid as component_guid,
      urc.cmp_guid as t_cmp_delivery_guid
   FROM 
    {{ ref('d_qsr_var1_delivery_1_0_1') }} d
    JOIN (
       -- distinct combination of component+version with delivery, enriched with component_guid
       SELECT
          dlvry.DELIVERY_GUID AS DLVRY_GUID,
          dlvry.DELIVERY_CBDNUMBER AS DLVRY_CBD_NUMBER,
          dlvry.COMPONENT_NAME AS DLVRY_CMP_NAME,
          dlvry.COMPONENT_VERSION AS DLVRY_CMP_VERSION,
          cmp.COMPONENT_GUID AS CMP_GUID
       FROM
        {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_DELIVERY_U_STAGING') }} dlvry
        join {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_COMPONENT_U_STAGING') }} cmp on (DLVRY.COMPONENT_NAME = cmp.PACKAGE_NAME and dlvry.COMPONENT_VERSION = cmp.COMPONENT_VERSION )
    ) urc
    ON d.DELIVERY_GUID = urc.DLVRY_GUID and d.DELIVERY_CBD_NUMBER = urc.DLVRY_CBD_NUMBER

