with metric as (

    select * from {{ source('RAW', 'COMPONENT_S_DBT_STAGE') }}

)

select * from metric