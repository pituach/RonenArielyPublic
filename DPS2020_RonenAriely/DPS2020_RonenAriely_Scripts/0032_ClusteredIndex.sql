
use InternalsTableStructure01
GO
DROP TABLE IF EXiSTS T
GO
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
            [Binary Data on the disk]
==================================================*/

-- Un-docemented tools:
--   DBCC IND
--   DBCC PAGE

------------------------------------------------
-- Step 1: find the pages with the data
DBCC IND('InternalsTableStructure01', 'dbo.T', 0);
GO -- 512

------------------------------------------------
-- Note: Remember the page number for next demo!

------------------------------------------------
DBCC TRACEON(3604, -1);
GO
DBCC PAGE('InternalsTableStructure01', 1, 256, 1);
GO
/*
0000000000000000:   30001c00 01000000 526f6e65 6e202020 20204172  0.......Ronen     Ar
0000000000000014:   69656c79 20202020 04000001 00370061 00610061  iely    .....7.a.a.a
0000000000000028:   00610061 00610061 00610061 006100             .a.a.a.a.a.a.a.
*/

------------------------------------------------



/*==================================================
	[INDEX] ADD CLUSTERED INDEX
==================================================*/
SELECT index_id,column_name, partition_column_id, leaf_null_bit, leaf_offset, max_inrow_length, max_length,  CASE WHEN column_name in ('CHAR04','INT01') THEN N'⬅⬅⬅⬅⬅' ELSE '' END from GetPhysicalTableStructure('T')
	CREATE CLUSTERED INDEX CX_T ON T (CHAR04)
SELECT index_id,column_name, partition_column_id, leaf_null_bit, leaf_offset, max_inrow_length, max_length,  CASE WHEN column_name in ('CHAR04','INT01') THEN N'⬅⬅⬅⬅⬅' ELSE '' END from GetPhysicalTableStructure('T')
GO

--> ADD new column! 
	-- unique identifier - 4 bytes, leaf_offset negative, TOTALLY HIDDEN FROM THE USERS!
-- Physical order changed : The entire dtaa was copied on disk!


/*==================================================
            [Binary Data on the disk]
==================================================*/
DBCC IND('InternalsTableStructure01', 'dbo.T', 0);
GO -- 520

DBCC TRACEON(3604, -1);
GO
DBCC PAGE('InternalsTableStructure01', 1, 256, 1);
GO
/*
Before
0000000000000000:   30001c00 01000000 526f6e65 6e202020 20204172  0.......Ronen     Ar
0000000000000014:   69656c79 20202020 04000001 00370061 00610061  iely    .....7.a.a.a
0000000000000028:   00610061 00610061 00610061 006100             .a.a.a.a.a.a.a.
-----------------------------------------

New
0000000000000000:   30001c00 41726965 6c792020 20200100 0000526f  0...Ariely    ....Ro
0000000000000014:   6e656e20 20202020 05000002 00250039 00610061  nen     .....%.9.a.a
0000000000000028:   00610061 00610061 00610061 00610061 00        .a.a.a.a.a.a.a.a.
*/





/*==================================================
	[INDEX] DROP CLUSTERED INDEX
==================================================*/
DROP INDEX if exists CX_T ON T
GO
SELECT index_id, column_name, partition_column_id, leaf_null_bit, leaf_offset, max_inrow_length, max_length from GetPhysicalTableStructure('T')
GO

-- The hidden column is not removed!

