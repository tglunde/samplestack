with metric as (

    select * from {{ source('RAW', 'component_s_dbt_stage') }}

)

, metrics as (

    SELECT 
        updated,
        component_name ,
        component_version ,
	    cast(tcases as int) as tcases,
	    cast(creqs as int) as creqs,
        cast(creqswithtracetotcase as int) as creqswithtracetotcase

    FROM metric

)

select 
    updated, component_name, component_version,

    tcases, creqs, creqswithtracetotcase,

    CASE WHEN creqs = 0 THEN 0 ELSE tcases / creqs END as tcase_pro_creq

from metrics