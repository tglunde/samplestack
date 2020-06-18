with metric_name as (

    select
        distinct metric_name 
        
    from {{ ref('xml_metric') }}
)

select * from metric_name