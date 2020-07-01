
  SELECT
     fct.COMPONENT_GUID AS t_cmp_packages_guid,
     fct.COMPONENT_GUID AS t_cmp_packagedef_guid,
     fct.COMPONENT_GUID AS t_cmp_architecture_guid,
     fct.COMPONENT_GUID AS t_cmp_datastatus_guid,
     fct.COMPONENT_GUID AS t_cmp_delivery_guid,
     1 AS m_component_cnt,
     mtrc_creq_tcase.METRIC_VALUE AS m_creq_tcase_traceability,
     mtrc_pth.METRIC_VALUE AS pi_pth
  FROM
    {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_COMPONENT_U_STAGING') }} fct
    LEFT OUTER JOIN {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_METRIC_U_STAGING') }} mtrc_creq_tcase ON
      ( mtrc_creq_tcase.COMPONENT_NAME = fct.PACKAGE_NAME AND mtrc_creq_tcase.COMPONENT_VERSION = fct.COMPONENT_VERSION 
      AND mtrc_creq_tcase.METRIC_NAME = 'CREQsWithTraceToTCASE' and mtrc_creq_tcase.SPECMETRIC_NAME is not null )
    LEFT OUTER JOIN {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_METRIC_U_STAGING') }} mtrc_pth ON
      ( mtrc_pth.COMPONENT_NAME = fct.PACKAGE_NAME AND mtrc_pth.COMPONENT_VERSION = fct.COMPONENT_VERSION 
      AND mtrc_pth.METRIC_NAME = 'ImplPTH' and mtrc_pth.SPECMETRIC_NAME is not null )



