
use InternalsTableStructure01
GO

/*==================================================
	[CHANGE_TRACKING] 
==================================================*/
ALTER DATABASE InternalsTableStructure01
SET CHANGE_TRACKING = ON(CHANGE_RETENTION = 5 DAYS, AUTO_CLEANUP = ON);
GO

ALTER TABLE T ENABLE CHANGE_TRACKING;
SELECT index_id,column_name, partition_column_id, leaf_null_bit, leaf_offset, max_inrow_length, key_ordinal, CASE WHEN index_id = 1 and partition_column_id> 10000 THEN N'⬅⬅⬅⬅⬅' ELSE '' END from GetPhysicalTableStructure('T')
GO
-- Enabling change tracking on our table added one more PHYSICAL hidden column 8KB size!

--index_id | column_name | partition_column_id | leaf_null_bit | leaf_offset | max_inrow_length | key_ordinal
--1        | NULL        | 134217730           | 6             | 28          | 8                | 0
