  SELECT
  	cmp.NAMESPACE_NAME as namespace_name,
  	cmp.PACKAGE_LAYER as package_layer,
  	cmp.PACKAGE_NAME as package_name,
  	cmp.PACKAGE_NAME as component_name,
  	cmp.COMPONENT_VERSION as component_version,
  	cmp.PACKAGE_NAME || ' - v' || cmp.COMPONENT_VERSION AS component_version_name,
  	cmp.NAMESPACE_GUID as t_namespace_guid,
  	cmp.PACKAGE_GUID as t_package_guid,
  	cmp.COMPONENT_GUID as t_cmp_packagedef_guid
  FROM
    {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_COMPONENT_U_STAGING') }} cmp
