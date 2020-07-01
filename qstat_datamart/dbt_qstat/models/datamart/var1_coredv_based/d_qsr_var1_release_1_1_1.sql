   select 
      distinct
      rls."Product Name" as product_name,
      'R' || rls."Release Version" as release_name,
      rls."Release GUID" as release_guid,
      rls."BK Component" as t_cmp_release
   from
      {{ source('access', 'release_c_release')}} rls
      