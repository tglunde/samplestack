with metrics as (
	select 
        UPDATED, LDTS,
        component_name , 
        component_version , 
	    COALESCE(specmetric_name, 'basemetric') as metric_group ,
	    metric_name , metric_value 
        
    from {{ source('PSA', 'XMLMETRIC_S_XMLINTERFACE') }} 

), basemetrics AS (
	select 
        UPDATED, LDTS,
        component_name , 
        component_version, 
        metric_name, 
        metric_value 
        
    from metrics 
    
    where metric_group = 'basemetric'

), pivoted AS (
    
    select 
        updated, ldts,
        component_name,
        component_version,
        {{ dbt_utils.pivot(
            'metric_name', 
            dbt_utils.get_column_values(ref('metric_name'),'metric_name'),
            then_value='metric_value',
            else_value='NULL',
            agg='max'
            ) 
        }}

    from basemetrics

    group by 1,2,3,4

)
select * from pivoted