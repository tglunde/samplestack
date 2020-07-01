select 
    rls.PRODUCT_NAME as product_name,
    'R' || rls.RELEASE_VERSION as release_name,
    rls.RELEASE_GUID as release_guid,
    rls.COMPONENT_GUID as t_cmp_release_guid
from
    {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_RELEASE_U_STAGING' ) }} rls