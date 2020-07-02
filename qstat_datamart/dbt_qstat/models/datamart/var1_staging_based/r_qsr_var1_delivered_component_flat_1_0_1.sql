select 
 f.M_CREQ_TCASE_TRACEABILITY, f.PI_PTH, f.m_component_cnt
 , f.pi_LMTPTH, f.M_MINPTH, f.M_MAXPTH
 , d.DELIVERY_CBD_NUMBER ,d.DELIVERY_NUMBER ,d.DELIVERY_GUID , d.CUSTOMER 
 , a.CLUSTER_NAME , a.MODULE_NAME 
 , pi.ALMPLUS_QUALITY_STATUS , pi.IMPLEMENTATION_VERSION 
 , pd.NAMESPACE_NAME , pd.PACKAGE_LAYER , pd.PACKAGE_NAME, pd.COMPONENT_VERSION, pd.COMPONENT_NAME 
 , ds.DATA_STATUS , ds.DATA_STATUS_DT 
from 
{{ ref( 'f_qsr_var1_delivered_component_1_0_1' ) }}  f
join {{ ref( 'd_qsr_var1_architecture_1_0_1' ) }} a on f.T_CMP_ARCHITECTURE_GUID = a.T_CMP_ARCHITECTURE_GUID 
join {{ ref( 'd_qsr_var1_packageimpl_1_0_1' ) }} pi on f.T_CMP_PACKAGES_GUID = pi.T_CMP_PACKAGES_GUID
join {{ ref( 'd_qsr_var1_packagedef_1_0_1' ) }} pd on f.T_CMP_PACKAGEDEF_GUID = pd.T_CMP_PACKAGEDEF_GUID
join {{ ref( 'd_qsr_var1_datastatus_1_0_1' ) }} ds on f.t_cmp_datastatus_guid = ds.t_cmp_datastatus_guid
join {{ ref( 'd_qsr_var1_componentdelivery_xtnd_1_0_1' ) }} d  on f.t_cmp_delivery_guid = d.T_CMP_DELIVERY_GUID
