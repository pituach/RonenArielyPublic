/************************************************
           [VARIABLE-LENGTH]
*************************************************  */
use InternalsTableStructure01
GO

DROP TABLE IF EXISTS T
GO
CREATE TABLE T(
	FixedDataType1 BIGINT NOT NULL,
	FixedDataType2 CHAR(20) NULL,
	VarDatatype VARCHAR(20) NULL,
	FixedDataType3 CHAR(20) NULL
)
GO



/*==================================================
     [FIXED-LENGTH to VARIABLE-LENGTH]
==================================================*/
SELECT index_id,column_name, partition_column_id, leaf_null_bit, leaf_offset, CASE WHEN column_name = 'FixedDataType2' or column_name IS NULL THEN N'⬅⬅⬅⬅⬅' ELSE '' END from GetPhysicalTableStructure('T')
	ALTER TABLE T ALTER COLUMN FixedDataType2 VARCHAR(20)
SELECT index_id,column_name, partition_column_id, leaf_null_bit, leaf_offset, CASE WHEN column_name = 'FixedDataType2' or column_name IS NULL THEN N'⬅⬅⬅⬅⬅' ELSE '' END from GetPhysicalTableStructure('T')
GO
-- SQL Server need to "move" the column from one group to the second:
-- leaf_offset of the column changed from positive 12 (FIXED-LENGTH) to Negative -2 (VARIABLE-LENGTH)
	-- Drop old column
	-- Add new VARIABLE-LENGTH column at the end


/*==================================================
     [VARIABLE-LENGTH - Change the size]
==================================================*/
SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, max_inrow_length, CASE WHEN column_name = 'VarDatatype' THEN N'⬅⬅⬅⬅⬅' ELSE '' END from GetPhysicalTableStructure('T')
	-- increase size from 20 to 100
	ALTER TABLE T ALTER COLUMN VarDatatype VARCHAR(100) 
SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, max_inrow_length, CASE WHEN column_name = 'VarDatatype' THEN N'⬅⬅⬅⬅⬅' ELSE '' END from GetPhysicalTableStructure('T')
GO
-- Notice that "increase size" was done in-place


-- What about Decrease the size?
SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, max_inrow_length, CASE WHEN column_name = 'VarDatatype' THEN N'⬅⬅⬅⬅⬅' ELSE '' END from GetPhysicalTableStructure('T')
	ALTER TABLE T ALTER COLUMN VarDatatype VARCHAR(20)
SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, max_inrow_length, CASE WHEN column_name = 'VarDatatype' THEN N'⬅⬅⬅⬅⬅' ELSE '' END from GetPhysicalTableStructure('T')
GO
-- This is exactly the opusite of how FIXED-LENGTH worked!
-- In VARIABLE-LENGTH decreasing the size DROP column and ADD new physical column at the end







/*==================================================
     [VARIABLE-LENGTH - ALTER Unicode to ASCII]
==================================================*/
DROP TABLE IF EXISTS T;
CREATE TABLE T(
	VarDatatype1 NVARCHAR(20) NULL,
	VarDatatype2 NVARCHAR(20) NULL,
	FixedDataType1 NCHAR(20) NULL
)
GO
insert T (VarDatatype1) values (N'Ronen')
GO

SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, max_inrow_length, CASE WHEN column_name = 'VarDatatype1' or column_name is NULL THEN N'⬅⬅⬅⬅⬅' ELSE '' END from GetPhysicalTableStructure('T')
	ALTER TABLE T ALTER COLUMN VarDatatype1 varchar(20) null
SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, max_inrow_length, CASE WHEN column_name = 'VarDatatype1' or column_name is NULL THEN N'⬅⬅⬅⬅⬅' ELSE '' END from GetPhysicalTableStructure('T')
GO
-- DROP column + ADD new column at the end

DBCC IND ('InternalsTableStructure01', 'T', 1);
GO -- 360
DBCC TRACEON (3604);
GO
DBCC PAGE ('InternalsTableStructure01', 1, 256, 3);
GO
-- We can notice that the old data exists as well as the new data!

