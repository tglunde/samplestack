from file_converter import file_converter

fco = file_converter()
fco.replaceDBType("mssql") 
fco.getFileList({"complete_data_type": "varchar(8000)", 
                 "character_maximum_length": 8000, 
                 "data_type_name": "varchar", 
                 "data_type": "varchar"})

fco.fileConversion(["system_id","hub_id",
                    "related_businessobject_view_id",
                    "business_rules_businessobject_container_id",
                    "business_ruleset_view_id",
                    "container_id",
                    "hub_load_id",
                    "staging_table_id",
                    "hub_id_of_alias_parent",
                    "hub_a_id",
                    "hub_b_id",
                    "link_id",
                    "functional_suffix_id",
                    "satellite_id",
                    "staging_resource_id",
                    "source_table_id",
                    "source_table_staging_id",
                    "object_id",
                    "granularity_satellite_id",
                    "path_id",
                    "businessobject_set_id",
                    "businessobject_view_id",
                    "quick_insert_table_id",
                    "start_hub_id",
                    "job_suffix_id",
                    "column_id",
                    "column_name",
                    "column_name_detail",
                    "column_nq_id",
                    "business_key_short",
                    "business_rules_view_code"
                   ], fco.lower)


fco.renameFileLower()
