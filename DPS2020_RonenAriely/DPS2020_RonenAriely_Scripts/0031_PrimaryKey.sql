
-- Let's start check the impact of DDL on the table's physical structure
use InternalsTableStructure01
GO

DROP TABLE IF EXiSTS T
CREATE TABLE T(
	INT01		INT NOT NULL IDENTITY(1,1),
	NVARCHAR02	NVARCHAR(10),
	CHAR03		CHAR(10) NOT NULL,
	CHAR04		CHAR(10) NOT NULL
)
INSERT T (NVARCHAR02, CHAR03, CHAR04)
	VALUES (REPLICATE(N'a', 10), 'Ronen','Ariely')
GO

/*==================================================
            [ADD Primary Key on first column]
==================================================*/
SELECT index_id,column_name, partition_column_id, leaf_null_bit, leaf_offset, key_ordinal,  CASE WHEN column_name = 'INT01' THEN N'⬅⬅⬅⬅⬅' ELSE '' END from GetPhysicalTableStructure('T')
	ALTER TABLE T ADD CONSTRAINT pk_T primary key (INT01);
SELECT index_id,column_name, partition_column_id, leaf_null_bit, leaf_offset, key_ordinal,  CASE WHEN column_name = 'INT01' THEN N'⬅⬅⬅⬅⬅' ELSE '' END from GetPhysicalTableStructure('T')
GO
-- index_id changed
-- key_ordinal


/*==================================================
            [REMOVE Primary Key]
==================================================*/
ALTER TABLE T DROP CONSTRAINT IF EXISTS pk_T;
GO
SELECT index_id,column_name, partition_column_id, leaf_null_bit, leaf_offset, key_ordinal,  CASE WHEN column_name = 'INT01' THEN N'⬅⬅⬅⬅⬅' ELSE '' END from GetPhysicalTableStructure('T')
GO




/*==================================================
            [ADD Primary Key on multiple columns]
==================================================*/
ALTER TABLE T DROP CONSTRAINT IF EXISTS pk_T;
GO
ALTER TABLE T ADD CONSTRAINT pk_T primary key (CHAR04,CHAR03);
SELECT index_id,column_name, partition_column_id, leaf_null_bit, leaf_offset, key_ordinal,  CASE WHEN column_name in ('CHAR04','CHAR03') THEN N'⬅⬅⬅⬅⬅' ELSE '' END from GetPhysicalTableStructure('T')
GO


