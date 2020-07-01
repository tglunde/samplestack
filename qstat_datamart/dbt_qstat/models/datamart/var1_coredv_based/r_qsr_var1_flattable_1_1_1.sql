SELECT 
   f.M_CREQ_TCASE_TRACEABILITY, f.PI_PTH, 
   f.m_component_cnt  
   -- , f.PTH , f.M_MINPTH, f.M_MAXPTH 
 , r.RELEASE_NAME, r.RELEASE_PRODUCT_NAME
 , d.DELIVERY_CBD_NUMBER ,d.DELIVERY_NUMBER 
 , d.DELIVERY_GUID , d.CUSTOMER 
 , a.CLUSTER_NAME , a.MODULE_NAME 
 , pi.ALMPLUS_QUALITY_STATUS, pi.IMPLEMENTATION_VERSION 
 , pi.NAMESPACE_NAME , pi.PACKAGE_LAYER 
 , pi.PACKAGE_NAME, pi.COMPONENT_VERSION
 , pi.COMPONENT_NAME 
 , 'NYI' AS DATA_STATUS , '' AS DATA_STATUS_DT 
FROM 
  DATAMART.F_QSR_VAR1_COMPONENT_1_1_1 f
JOIN DATAMART.D_QSR_VAR1_RELEASE_1_1_1 r  ON f.T_CMP_RELEASE_GUID = r.T_CMP_RELEASE_GUID 
JOIN DATAMART.D_QSR_VAR1_ARCHITECTURE_1_1_0 a ON f.T_CMP_ARCHITECTURE_GUID = a.T_CMP_ARCHITECTURE_GUID 
JOIN DATAMART.D_QSR_VAR1_PACKAGES_1_1_0 pi ON f.T_CMP_PACKAGES_GUID = pi.T_CMP_PACKAGEDEF_GUID 
JOIN DATAMART.D_QSR_VAR1_COMPONENTDELIVERY_XTND_1_1_0 d  ON f.t_cmp_delivery_guid = d.T_CMP_DELIVERY_GUID
