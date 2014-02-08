(SELECT
     @myid := @myid + 1 AS id,
     'schema' as type,
     schema_name as name,
     CONCAT(default_character_set_name, '; ', default_collation_name) AS meta_data
 FROM schemata)
UNION ALL
(SELECT
     @myid := @myid + 1 AS id,
     'table' as type,
     table_name as name,
     CONCAT(table_type, '; ', engine, '; ', table_collation) AS meta_data
 FROM tables)
UNION ALL
(SELECT
     @myid := @myid + 1 AS id,
     'column' as type,
     column_name as name,
     CONCAT(column_type, '; ', data_type, '; ', character_set_name) AS meta_data
 FROM columns)
