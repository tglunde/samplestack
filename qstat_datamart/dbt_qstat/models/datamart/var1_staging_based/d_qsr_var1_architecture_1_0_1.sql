  select 
    cmp.PACKAGE_AUTOSARCLUSTER as cluster_name,
    cmp.PACKAGE_SHORTNAME as module_name,
    cmp.COMPONENT_GUID as t_cmp_architecture_guid
  from
    {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_COMPONENT_U_STAGING') }} cmp
