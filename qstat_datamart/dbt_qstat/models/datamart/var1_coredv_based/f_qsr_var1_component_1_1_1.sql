{{
  config(
	tags = [ 'fact']
	)
}}


with baseselect
AS (
  SELECT
    distinct
  	fct."Business Key for Hub Component" as t_component,
  	1 as m_component_cnt,
  	fct.CREQSWITHTRACETOTCASE as m_creq_tcase_traceability,
  	fct."ImplPTH" as pi_pth,
  	fct."MaxPTH" as m_maxpth,
  	fct."MinPTH" as m_minpth,
  	case when fct."MaxPTH" > 800 then '>>80'
          when fct."MaxPTH" > 80 then '>80'
          else ''|| fct."MaxPTH" 
     end AS pi_lmtmaxpth
  FROM
	{{ source('DV-AL', 'component_c_factcomponent')}} fct
)

SELECT 
	t_component,
	m_component_cnt,
	m_creq_tcase_traceability,
	pi_pth,
	m_maxpth,
	m_minpth,
	pi_lmtmaxpth,
    coalesce( ''||m_minpth, 'missing ' ) || '..' || coalesce( pi_lmtmaxpth, ' missing' ) as pi_lmtpth
FROM
	baseselect
