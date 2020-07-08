with metric as (

    select * from {{ source('RAW', 'component_s_dbt_stage') }}

)

select * from metric