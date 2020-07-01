  select 
  distinct
  dlvry."Customer" as customer,
  dlvry."Delivery GUID" as delivery_guid,
  dlvry."CBD Number" as delivery_cbd_number,
  dlvry."Delivery Number" as delivery_number,
  dlvry."Component Name" as component_name,
  dlvry."Component Version" as component_version,
  dlvry."Component GUID" as component_guid,
  dlvry."BK Component" as t_cmp_delivery
 from
    {{ source('access', 'delivery_c_componentdelivery')}} dlvry
