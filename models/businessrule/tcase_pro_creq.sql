with metrics as (

    SELECT 
        UPDATED,
        COMPONENT_NAME ,
        COMPONENT_VERSION ,
	    "TCASES" as tcases,
	    "CREQS" as creqs,
        "CREQSWITHTRACETOTCASE" as creqswithtracetotcase
        
    
    FROM {{ ref('bo_component_metric') }} 

)

select 
    updated, component_name, component_version,

    tcases, creqs, CREQsWithTraceToTCASE,

    CASE WHEN CREQS = 0 THEN 0 ELSE tcases / creqs END as tcase_pro_creq

from metrics