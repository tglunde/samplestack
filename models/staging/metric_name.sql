with metric_name as (

    select
        distinct upper(metric_name) as metric_name 
        
    from {{ source('PSA', 'XMLMETRIC_S_XMLINTERFACE') }}

    order by 1

)

select * from metric_name