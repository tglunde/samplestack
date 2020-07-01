select 
    cmp.UPDATED as data_status,
    TO_DATE( cmp.updated, 'YYYYMMDD') AS data_status_dt,
    cmp.COMPONENT_GUID as t_cmp_datastatus_guid
from
    {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_COMPONENT_U_STAGING') }} cmp
