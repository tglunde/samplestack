
SELECT 
   f.M_CREQ_TCASE_TRACEABILITY, f.PI_PTH, f.m_component_cnt  
 , f.M_MINPTH, f.M_MAXPTH
 , f.pi_lmtpth as pi_logpth
 , f.pi_lmtpth 
 , d.DELIVERY_CBD_NUMBER ,d.DELIVERY_NUMBER 
 , d.DELIVERY_GUID , d.CUSTOMER 
 , r.RELEASE_NAME, r.PRODUCT_NAME
 , a.CLUSTER_NAME , a.MODULE_NAME 
 , pi.ALMPLUS_QUALITY_STATUS , pi.IMPLEMENTATION_VERSION 
 , pi.NAMESPACE_NAME , pi.PACKAGE_LAYER 
 , pi.PACKAGE_NAME, pi.COMPONENT_VERSION
 , pi.COMPONENT_NAME 
 , 'NYI' as DATA_STATUS , '' AS DATA_STATUS_DT 
FROM 
  {{ ref('f_qsr_var1_component_1_1_1') }} f
JOIN {{ ref('d_qsr_var1_release_1_1_1') }} r  ON f.t_component = r.T_CMP_RELEASE 
JOIN {{ ref('d_qsr_var1_architecture_1_1_1') }} a ON f.t_component = a.T_CMP_ARCHITECTURE 
JOIN {{ ref('d_qsr_var1_packages_1_1_1') }} pi ON f.t_component = pi.T_CMP_PACKAGES 
JOIN {{ ref('d_qsr_var1_componentdelivery_xtnd_1_1_1') }} d  ON f.t_component = d.T_CMP_DELIVERY
