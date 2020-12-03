
use InternalsTableStructure01
GO

/*==================================================
	[INDEX] ADD NONCLUSTERED INDEX
==================================================*/
CREATE NONCLUSTERED INDEX IX_T_NC ON T (INT01);   
SELECT index_id,column_name, partition_column_id, leaf_null_bit, leaf_offset, max_inrow_length, max_length, CASE WHEN index_id>1 THEN N'⬅⬅⬅⬅⬅' ELSE '' END from GetPhysicalTableStructure('T')
GO

--> ADD two new columns
	-- One for the columnm in the index
	-- second for the UNIQUE IDENTIFIER from the clustered index


/*==================================================
	[INDEX] Drop NONCLUSTERED INDEX
==================================================*/
DROP INDEX IX_T_NC on T;
SELECT index_id,column_name, partition_column_id, leaf_null_bit, leaf_offset, max_inrow_length, max_length from GetPhysicalTableStructure('T')
GO 
-- The stored size of clustered index is reclaimed!






/*==================================================
	[INDEX] ADD Multiple INDEXs on Multiple columns and using INCLUDE
==================================================*/
CREATE CLUSTERED INDEX IX_T_C ON T (CHAR04);   
CREATE NONCLUSTERED INDEX IX_T_NC ON T (INT01, CHAR03) INCLUDE (NVARCHAR02);   
SELECT index_id,column_name, partition_column_id, leaf_null_bit, leaf_offset, max_inrow_length, max_length from GetPhysicalTableStructure('T')
GO
-- In CLUSTERED INDEX we have a hidden column for UNIQUE IDENTIFIER 
-- In NONCLUSTERED INDEX:
	-- For each column in the INDEX we get another column in the metadata structure
	-- We have a hidden column for each IDENTIFIER and Participate in the CLUSTERED INDEX
--



/*==================================================
	[INDEX] ADD Key with Multiple columns
==================================================*/
ALTER TABLE T ADD CONSTRAINT pk_T PRIMARY KEY (INT01, CHAR03)
SELECT index_id,column_name, partition_column_id, leaf_null_bit, leaf_offset, max_inrow_length, max_length from GetPhysicalTableStructure('T')
GO
