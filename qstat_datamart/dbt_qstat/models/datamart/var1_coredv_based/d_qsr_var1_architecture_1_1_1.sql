  SELECT 
    distinct
    cmp."Cluster" as cluster_name,
    cmp."Modul" as module_name,
    cmp."BK Component" as t_cmp_architecture
  FROM
    {{ source( 'access', 'component_c_architecture') }} cmp
