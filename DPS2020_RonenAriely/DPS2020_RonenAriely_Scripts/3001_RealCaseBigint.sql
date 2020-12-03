/************************************************  */
/************************************************  */
--  Real Life Question: 
--  --------------------
/************************************************  */
/************************************************  */

use InternalsTableStructure01
GO





/*==================================================
            [DROP Column]
==================================================*/

DROP TABLE IF EXISTS T;
CREATE TABLE T(
	FixedDataType1 BIGINT NOT NULL, -- We do NOT need this column anymore
	FixedDataType2 CHAR(20) NULL,
	VarDatatype VARCHAR(20) NULL,
	FixedDataType3 CHAR(20) NULL
)
GO
INSERT T(FixedDataType1, FixedDataType2, VarDatatype, FixedDataType3)
VALUES (9999, 'Ronen', N'Ariely', 'Lecture')
GO

SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, is_nullable, max_length from GetPhysicalTableStructure('T')
	ALTER TABLE T DROP COLUMN FixedDataType1
SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, is_nullable, max_length from GetPhysicalTableStructure('T')
GO

https://sessionize.com/pituach/
https://ariely.info/Blog/tabid/83
https://www.facebook.com/ronen.ariely/


/****************** Find the missing data *********/

-->> Common mistake! 
-->> ❎ CONVERT DOES NOT RETURN THE SAME VALUE AS ON THE DISK!!!


/*********** This procedure fits integers! *****/
--> ✅ Using CONVERT to binary according to the length of the data type
--> ✅ Split to bytes 
--> ✅ Reverze order
SELECT CONVERT(BINARY(8), 9999)
GO 
-- 0x000000000000270F				  <-- resule of convert
-- 00 00 00 00 00 00 27 0F			  <-- split to bytes
-- 0F27000000000000                   <-- reverse order = this is the value on the disk



----------------------------------------------------
-- Let's confirm the data exists on the disk!
DBCC IND('InternalsTableStructure01', 'dbo.T', 0);
GO
----------------------------------------------------
DBCC TRACEON(3604, -1);
GO
DBCC PAGE('InternalsTableStructure01', 1, 256, 1);
GO
----------------------------------------------------




/*==================================================
            [UPDATE values to zero]
==================================================*/
-- Make no sense since this column is FIXED SIZE and it is "NOT NULL"




/*==================================================
            [Question/Idea?]
==================================================*/
-- what about new rows which will be inserted after we change the structure?









/*==================================================
            [ALTER Column from "NOT NULL" to "NULL"]
==================================================*/
-- Create the table from scratch
DROP TABLE IF EXISTS T;
CREATE TABLE T(
	FixedDataType1 BIGINT NOT NULL, -- We do NOT need this column anymore
	FixedDataType2 CHAR(20) NULL,
	VarDatatype VARCHAR(20) NULL,
	FixedDataType3 CHAR(20) NULL
)
GO
INSERT T(FixedDataType1, FixedDataType2, VarDatatype, FixedDataType3)
VALUES (9999, 'Ronen', N'Ariely', 'Lecture')
GO

SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, is_nullable, max_length from GetPhysicalTableStructure('T')
	ALTER TABLE T ALTER COLUMN FixedDataType1 BIGINT NULL
SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, is_nullable, max_length from GetPhysicalTableStructure('T')
GO

-- no change in the leaf-offset
-- The column was simply marked as nullable


/*==================================================
            [ALTER Column from "NULL" to "NOT NULL"]
==================================================*/
-- Off-topic!!

SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, is_nullable, max_length from GetPhysicalTableStructure('T')
ALTER TABLE T
	ALTER COLUMN FixedDataType1 BIGINT NOT NULL
SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, is_nullable, max_length from GetPhysicalTableStructure('T')
GO

-- Notice that ALTER from NOT NULL into NULL, added another Physical column
-- but there is no change in the DATA!
-- The physical locations is the same








/*==================================================
            [ALTER Column to a smaller data type]
==================================================*/
-- Create the table from scratch
DROP TABLE IF EXISTS T;
CREATE TABLE T(
	FixedDataType1 BIGINT NOT NULL, -- We do NOT need this column anymore
	FixedDataType2 CHAR(20) NULL,
	VarDatatype VARCHAR(20) NULL,
	FixedDataType3 CHAR(20) NULL
)
GO
INSERT T(FixedDataType1, FixedDataType2, VarDatatype, FixedDataType3)
VALUES (9999, 'Ronen', N'Ariely', 'Lecture')
GO

SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, is_nullable, max_length from GetPhysicalTableStructure('T')
	UPDATE T SET FixedDataType1 = 1
	ALTER TABLE T ALTER COLUMN FixedDataType1 TINYINT NOT NULL
SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, is_nullable, max_length from GetPhysicalTableStructure('T')
GO

-- Another Physical column was added!
-- But notice that the physical locations were not changed












/*==================================================
            [Off-topic! ALTER Column to a bigger type]
==================================================*/

SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, is_nullable, max_length from GetPhysicalTableStructure('T')
	ALTER TABLE T
		ALTER COLUMN FixedDataType1 BIGINT NOT NULL
SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, is_nullable, max_length from GetPhysicalTableStructure('T')
GO

-- This action is equivalent to DROP COLUMN and ADD new COLUMN !
-- It is not done *in-place* !







/*==================================================
            [DROP column and ADD Column in place?!?]
==================================================*/
SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, is_nullable, max_length from GetPhysicalTableStructure('T')
	ALTER TABLE T DROP COLUMN FixedDataType1
	-- Note that if the table already includes data then we cannot add column "Not Null",
	-- since the current rows have no data in this column and this will conflict the constraint.
	ALTER TABLE T ADD FixedDataType4 BIGINT NULL
SELECT column_name, partition_column_id, leaf_null_bit, leaf_offset, is_nullable, max_length from GetPhysicalTableStructure('T')
GO
-- we can add column in place of last column which was dropped





/*==================================================
            [Solution - REBUILD table]
==================================================*/
-- Well,what is the solution for thequestion in the forum?!?
-- I recommend to go to thethreadamndcheck my responsesthere since we cannot cover all inn this session

-- But me must mention howto fix our complesx table structure
SELECT * from GetPhysicalTableStructure('T')
	ALTER TABLE T REBUILD 
SELECT * from GetPhysicalTableStructure('T')
GO



