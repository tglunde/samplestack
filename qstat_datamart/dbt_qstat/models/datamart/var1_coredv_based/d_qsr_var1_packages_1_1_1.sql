  SELECT
    cmp."Namespace Name" as namespace_name,
    cmp."Layer" as package_layer,
    cmp."Component Name" as package_name,
    cmp."Component Name" as component_name,
    cmp."Component Version" as component_version,
    cmp."Component Name" || '- v' || cmp."Component Version" as versioned_component_name,
    'not yet implemented' as implementation_version,
    cmp."ALMPlus Status" as almplus_quality_status,
    'not yet implemented' as qm_approved,
    cmp."Namespace GUID" as t_namespace_guid,
    cmp."Component GUID" as t_package_guid,
    cmp."BK Component" as t_cmp_packages
  FROM 
    {{ source( 'access', 'component_c_packages' ) }} cmp