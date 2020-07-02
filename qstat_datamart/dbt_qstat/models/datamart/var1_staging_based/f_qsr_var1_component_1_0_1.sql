{{
  config(
	tags = [ 'fact']
	)
}}

WITH metricselect 
AS (

  SELECT
     fct.COMPONENT_GUID AS t_component_guid
     ,1 AS m_component_cnt
     ,mtrc_creq_tcase.METRIC_VALUE AS m_creq_tcase_traceability
     ,mtrc_pth.METRIC_VALUE AS pi_pth
     ,mtrc_minpth.METRIC_VALUE AS m_minpth
     ,mtrc_maxpth.METRIC_VALUE AS m_maxpth
     ,mtrc_pth2.METRIC_VALUE AS pi_pth_nospecmetricname
     ,mtrc_minpth2.METRIC_VALUE AS m_minpth_nospecmetricname
     ,mtrc_maxpth2.METRIC_VALUE AS m_maxpth_nospecmetricname
  FROM
    {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_COMPONENT_U_STAGING') }} fct
    LEFT OUTER JOIN {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_METRIC_U_STAGING') }} mtrc_creq_tcase ON
      ( mtrc_creq_tcase.COMPONENT_NAME = fct.PACKAGE_NAME AND mtrc_creq_tcase.COMPONENT_VERSION = fct.COMPONENT_VERSION 
      AND mtrc_creq_tcase.METRIC_NAME = 'CREQsWithTraceToTCASE' and mtrc_creq_tcase.SPECMETRIC_NAME is not null )
    LEFT OUTER JOIN {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_METRIC_U_STAGING') }} mtrc_pth ON
      ( mtrc_pth.COMPONENT_NAME = fct.PACKAGE_NAME AND mtrc_pth.COMPONENT_VERSION = fct.COMPONENT_VERSION 
      AND mtrc_pth.METRIC_NAME = 'ImplPTH' and mtrc_pth.SPECMETRIC_NAME is not null )
    LEFT OUTER JOIN {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_METRIC_U_STAGING') }} mtrc_minpth ON
      ( mtrc_minpth.COMPONENT_NAME = fct.PACKAGE_NAME AND mtrc_minpth.COMPONENT_VERSION = fct.COMPONENT_VERSION 
      AND mtrc_minpth.METRIC_NAME = 'MinPTH' and mtrc_minpth.SPECMETRIC_NAME is not null )
    LEFT OUTER JOIN {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_METRIC_U_STAGING') }} mtrc_maxpth ON
      ( mtrc_maxpth.COMPONENT_NAME = fct.PACKAGE_NAME AND mtrc_maxpth.COMPONENT_VERSION = fct.COMPONENT_VERSION 
      AND mtrc_maxpth.METRIC_NAME = 'MaxPTH' and mtrc_maxpth.SPECMETRIC_NAME is not null )

    LEFT OUTER JOIN {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_METRIC_U_STAGING') }} mtrc_creq_tcase2 ON
      ( mtrc_creq_tcase2.COMPONENT_NAME = fct.PACKAGE_NAME AND mtrc_creq_tcase2.COMPONENT_VERSION = fct.COMPONENT_VERSION 
      AND mtrc_creq_tcase2.METRIC_NAME = 'CREQsWithTraceToTCASE' and mtrc_creq_tcase2.SPECMETRIC_NAME is null )
    LEFT OUTER JOIN {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_METRIC_U_STAGING') }} mtrc_pth2 ON
      ( mtrc_pth2.COMPONENT_NAME = fct.PACKAGE_NAME AND mtrc_pth2.COMPONENT_VERSION = fct.COMPONENT_VERSION 
      AND mtrc_pth2.METRIC_NAME = 'ImplPTH' and mtrc_pth2.SPECMETRIC_NAME is null )
    LEFT OUTER JOIN {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_METRIC_U_STAGING') }} mtrc_minpth2 ON
      ( mtrc_minpth2.COMPONENT_NAME = fct.PACKAGE_NAME AND mtrc_minpth2.COMPONENT_VERSION = fct.COMPONENT_VERSION 
      AND mtrc_minpth2.METRIC_NAME = 'MinPTH' and mtrc_minpth2.SPECMETRIC_NAME is null )
    LEFT OUTER JOIN {{ source( 'qstat_xml_files', 'XMLINTERFACE_R_VI_XML_METRIC_U_STAGING') }} mtrc_maxpth2 ON
      ( mtrc_maxpth2.COMPONENT_NAME = fct.PACKAGE_NAME AND mtrc_maxpth2.COMPONENT_VERSION = fct.COMPONENT_VERSION 
      AND mtrc_maxpth2.METRIC_NAME = 'MaxPTH' and mtrc_maxpth2.SPECMETRIC_NAME is null )
),

flattendpth 
AS
(
  select 
     t_component_guid,
     m_component_cnt,
     m_creq_tcase_traceability,
     pi_pth,
     m_minpth,
     m_maxpth,
     pi_pth_nospecmetricname,
     m_minpth_nospecmetricname,
     m_maxpth_nospecmetricname,
     case when m_maxpth > 800 then '>>80'
          when m_maxpth > 80 then '>80'
          else ''|| m_maxpth
     end AS pi_lmtmaxpth
  from 
    metricselect
)

select 
     t_component_guid,
     m_component_cnt,
     m_creq_tcase_traceability,
     pi_pth,
     m_minpth,
     m_maxpth,
     pi_pth_nospecmetricname,
     m_minpth_nospecmetricname,
     m_maxpth_nospecmetricname,
     coalesce( ''||m_minpth, 'missing ' ) || '..' || coalesce( pi_lmtmaxpth, ' missing' ) as pi_lmtpth
  from 
  flattendpth
