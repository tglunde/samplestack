  SELECT
    cmp.COMPONENT_IMPLEMENTATIONVERSION as implementation_version,
    cmp.COMPONENT_QLEVEL as almplus_quality_status,
    cmp.COMPONENT_QACHECK as qacheck,
    cmp.COMPONENT_GUID as t_cmp_packages_guid
  FROM 
    {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_COMPONENT_U_STAGING') }} cmp
