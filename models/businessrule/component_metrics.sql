with metrics as (
	select 
        component_name , 
        component_version , 
	    nvl(specmetric_name, 'basemetric') as metric_group ,
	    metric_name , metric_value 
        
    from {{ ref('xml_metric') }} 

), basemetrics AS (
	select 
        component_name , 
        component_version, 
        metric_name, 
        metric_value 
        
    from metrics 
    
    where metric_group = 'basemetric'

), pivoted AS (
    
    select 
        component_name,
        component_version,
        {{ dbt_utils.pivot(
            'metric_name', 
            dbt_utils.get_column_values(ref('component_metric_names'),'metric_name'),
            then_value='metric_value',
            else_value='NULL',
            agg='max'
            ) 
        }}

    from basemetrics

    group by 1,2

)
select * from pivoted