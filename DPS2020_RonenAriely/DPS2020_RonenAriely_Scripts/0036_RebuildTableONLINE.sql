
use InternalsTableStructure01
GO

/*==================================================
            [rebuild INDEX ONLINE=ON]
==================================================*/
ALTER index pk_T on T rebuild with (online=on);
SELECT index_id,column_name, partition_column_id, leaf_null_bit, leaf_offset, is_anti_matter, CASE WHEN is_anti_matter = 1 THEN N'⬅⬅⬅⬅⬅' ELSE '' END from GetPhysicalTableStructure('T')
GO





