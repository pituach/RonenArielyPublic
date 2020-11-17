/************************************************  */
/************************************************
              [Partitioned Tables]
*************************************************  */
/************************************************  */
-- For last demo in this "playing with ALTER COLUMNs" let/s cover a simple Partitioned Tables

use InternalsTableStructure01
GO
-- DROP TABLE IF EXISTS T
-- DROP partition scheme PS
-- DROP partition function PF
create partition function PF (INT) as range for values ('10');
go
create partition scheme PS as partition PF all to ([PRIMARY]);
go
------------------------------------
DROP TABLE IF EXISTS T
GO
create table T (
	INT01 INT not null,
	INT02 int not null
) on PS(INT01);
go

SELECT partition_num,column_name, partition_column_id, leaf_null_bit, leaf_offset, max_inrow_length from GetPhysicalTableStructure('T')
GO
SELECT * from GetPhysicalTableStructure('T')
GO
-- Notice that we have 2 ROWSET with identical structure
-- one ROWSET for each partition

-- Behind the scenes PHYSICALLY this behave like two tables
-- But LOGICALLY they are managed as one table










