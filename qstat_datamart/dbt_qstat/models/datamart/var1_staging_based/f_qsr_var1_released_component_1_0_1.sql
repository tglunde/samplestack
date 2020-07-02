
  SELECT
     t_component_guid AS t_cmp_release_guid,
     t_component_guid AS t_cmp_packages_guid,
     t_component_guid AS t_cmp_packagedef_guid,
     t_component_guid AS t_cmp_architecture_guid,
     t_component_guid AS t_cmp_datastatus_guid,
     m_component_cnt,
     m_creq_tcase_traceability,
     pi_pth,
     m_minpth,
     m_maxpth,
     pi_pth_nospecmetricname,
     m_minpth_nospecmetricname,
     m_maxpth_nospecmetricname,
     pi_lmtpth
  FROM
    {{ ref('f_qsr_var1_component_1_0_1')}}
