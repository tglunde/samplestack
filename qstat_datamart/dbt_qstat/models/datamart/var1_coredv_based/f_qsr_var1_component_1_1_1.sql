  SELECT
    distinct
  	fct."Business Key for Hub Component" as t_cmp_packages,
  	fct."Business Key for Hub Component" as t_cmp_architecture,
  	fct."Business Key for Hub Component" as t_cmp_release,
  	fct."Business Key for Hub Component" as t_cmp_delivery,
  	1 as m_component_cnt,
  	fct.CREQSWITHTRACETOTCASE as m_creq_tcase_traceability,
  	fct."ImplPTH" as pi_pth,
  	fct."MaxPTH" as m_maxpth,
  	fct."MinPTH" as m_minpth,
  	case when fct."MaxPTH" > 800 then '\>\>80'
          when fct."MaxPTH" > 80 then '\>80'
          else ''|| fct."MaxPTH" 
     end AS m_lmtpth
  FROM
	{{ source('access', 'component_c_factcomponent')}} fct
