with metric_name as (

    select
        distinct upper(metric_name) as metric_name , metric_name as metric_name_orig
        
    from {{ source('PSA', 'xmlmetric_s_xmlinterface') }}

)

select * from metric_name