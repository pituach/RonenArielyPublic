
/****************************************************  */
/* [logical layer] vs [Physical layer under the scene] */
/****************************************************  */
use InternalsTableStructure01
GO
/*==================================================
            [Physical layer under the scene]
==================================================*/
--> UNDOCUMENTED system Internal View: 
--    (1) sys.system_internals_partitions (2) sys.system_internals_partition_columns

CREATE OR ALTER FUNCTION dbo.GetPhysicalTableStructure(@TableName sysname) 
RETURNS TABLE AS RETURN (
	select 
		p.object_id as obj_id, 
		p.index_id,
		p.partition_number as partition_num, 
		coalesce(cx.name, c.name) as column_name,
		pc.partition_column_id,
		pc.leaf_null_bit,
		pc.max_inrow_length,
		pc.max_length,
		pc.key_ordinal,
		pc.leaf_offset,
		pc.is_nullable,
		pc.is_dropped,
		pc.is_uniqueifier,
		pc.is_sparse,
		pc.is_anti_matter,
		c.is_computed
	from sys.system_internals_partitions p
	join sys.system_internals_partition_columns pc on p.partition_id = pc.partition_id
	left join sys.index_columns ic on p.object_id = ic.object_id and ic.index_id = p.index_id and ic.index_column_id = pc.partition_column_id
	left join sys.columns c on p.object_id = c.object_id and ic.column_id = c.column_id	
	left join sys.columns cx on p.object_id = cx.object_id and p.index_id in (0,1) and pc.partition_column_id = cx.column_id
	where p.object_id = object_id(@TableName)
)
GO

SELECT * from GetPhysicalTableStructure('T')
GO

