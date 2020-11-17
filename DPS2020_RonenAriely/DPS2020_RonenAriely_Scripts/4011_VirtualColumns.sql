
/*==================================================
	[Virtual columns] 
==================================================*/

Use InternalsTableStructure01
GO


/******************************************************/
/******************************************************/
/******************************************************/
/************** Computed columns **********/
-- Today session is for advance users. 
-- If you are still here after 50 minutes,
--   then you do not need me to explain what are comuted columns 🙂🤣

DROP TABLE IF EXISTS T
-- DROP PARTITION FUNCTION pTheAge
-- DROP PARTITION SCHEME pTheAgePrimary
GO

CREATE PARTITION FUNCTION pTheAge(INT) 
	AS RANGE RIGHT FOR VALUES (50)
GO
CREATE PARTITION SCHEME pTheAgePrimary AS PARTITION [pTheAge] ALL TO ([PRIMARY])
GO
CREATE TABLE T(
	id int identity(2,2), 
	UserName nvarchar(100),
	TheName nvarchar(100), 
	TheAge int
) on pTheAgePrimary(TheAge);
GO

INSERT T (UserName, TheName, TheAge) 
	values ('a','A', 11),('b','B',22),('c','C',33),('d','D',45),('e','E',56),('f','F',67),('g','G',78)
GO

----------------------------------
ALTER TABLE T 
	-- Create computed column using a "formula"
	ADD ComputedAgeForOldMembers as (CASE WHEN TheAge > 50 then 50 ELSE TheAge END)
GO
----------------------------------

SELECT * FROM T
GO

SELECT * from GetPhysicalTableStructure('T')
GO 
-->> is_computed is managed in the logical layer in sys.columns


select *, is_computed from sys.columns
where object_id = OBJECT_ID('dbo.T')
GO














/******************************************************/
/******************************************************/
/******************************************************/
/******************************************************/
/************** Undocumented virtual columns **********/
SELECT 
	%%rowdump%% as rowdump,	   -- 
	%%physloc%% as physloc,    -- Physical row location as a binary(8) 
	%%lockres%% as lockres	   -- 
FROM T
GO


--> %%physloc%% Practical use: Delete duplicated rows in Heap table
--     EXTREMELY USEFUL !!!
--     https://ariely.info/Blog/tabid/83/EntryId/110/Delete-NONE-DISTINCT-rows.aspx
--     Note: Content in Hebrew, but code and images are give the story 



/************** Parse the information in tghe virtual columns **********/

------------------- Accesories fuinctions: fn_GetRowsetIdFromrowdump ------------- 
SELECT 
	%%rowdump%% [rowdump],
	sys.fn_GetRowsetIdFromrowdump(%%rowdump%%) as [partition_id]
FROM T 
GO
--> Practical use?
--  1. Find the which row is in which partition
--     We can aggregate to find scatter of the columns in the partitions





------------------- Accesories fuinctions: fn_GetRowsetIdFromrowdump ------------- 
SELECT 
	%%physloc%% [physloc],
	sys.fn_PhysLocFormatter(%%physloc%%) [file_id:page_id:slot_id]
FROM T
GO
--> Practical use?
--  1. Find page location



------------------- Accesories fuinctions: fn_RowDumpCracker ------------- 

SELECT distinct rdc.*
FROM T T
CROSS APPLY  sys.fn_RowDumpCracker(%%rowdump%%) rdc
GO -- contains information about the rows construction


------------------- Accesories fuinctions: fn_physlocCracker -------------

SELECT T.*, plc.*
FROM T
CROSS APPLY sys.fn_physlocCracker(%%physloc%%) plc
GO 

--> Practical use?
--  Get information about the pysical location in the file (can be used for DBCC PAGE)
--  Simpler then DBCC when need speicifc location of a specific row



















/*============================== ISSUE remove partition */


/*
SELECT DISTINCT TABLES.NAME
FROM SYS.PARTITIONS
INNER JOIN SYS.TABLES ON PARTITIONS.OBJECT_ID = TABLES.OBJECT_ID
WHERE PARTITIONS.PARTITION_NUMBER <> 1
GO

SELECT 
	SCHEMA_NAME(B.SCHEMA_ID) SCHEMANAME, B.NAME TABLENAME, C.INDEX_ID, C.NAME INDEXNAME, C.TYPE_DESC,
	A.PARTITION_NUMBER, D.NAME DATASPACENAME, F.NAME SCHEMADATASPACENAME,
	H.VALUE DATARANGEVALUE, A.ROWS,
	J.IN_ROW_RESERVED_PAGE_COUNT, J.LOB_RESERVED_PAGE_COUNT,
	J.IN_ROW_RESERVED_PAGE_COUNT+J.LOB_RESERVED_PAGE_COUNT TOTALPAGECOUNT,
	I.LOCATION
FROM SYS.PARTITIONS A
JOIN SYS.TABLES B ON A.OBJECT_ID = B.OBJECT_ID
JOIN SYS.INDEXES C ON A.OBJECT_ID = C.OBJECT_ID AND A.INDEX_ID = C.INDEX_ID
JOIN SYS.DATA_SPACES D ON C.DATA_SPACE_ID = D.DATA_SPACE_ID
LEFT JOIN SYS.DESTINATION_DATA_SPACES E ON E.PARTITION_SCHEME_ID = D.DATA_SPACE_ID AND A.PARTITION_NUMBER = E.DESTINATION_ID
LEFT JOIN SYS.DATA_SPACES F ON E.DATA_SPACE_ID = F.DATA_SPACE_ID 
LEFT JOIN SYS.PARTITION_SCHEMES G ON D.NAME = G.NAME
LEFT JOIN SYS.PARTITION_RANGE_VALUES H ON G.FUNCTION_ID = H.FUNCTION_ID AND H.BOUNDARY_ID = A.PARTITION_NUMBER
LEFT JOIN (SELECT DISTINCT DATA_SPACE_ID, LEFT(PHYSICAL_NAME, 1) LOCATION FROM SYS.DATABASE_FILES) I ON I.DATA_SPACE_ID = ISNULL(F.DATA_SPACE_ID, D.DATA_SPACE_ID)
LEFT JOIN SYS.DM_DB_PARTITION_STATS J ON J.OBJECT_ID = A.OBJECT_ID AND J.INDEX_ID = A.INDEX_ID AND J.PARTITION_NUMBER = A.PARTITION_NUMBER
ORDER BY 1, 2, 3, A.PARTITION_NUMBER
GO

sp_help T

DROP INDEX ix_whatever ON T

CREATE CLUSTERED INDEX ix_whatever ON dbo.T (id) ON [PRIMARY]
CREATE CLUSTERED INDEX ix_whatever ON dbo.T (id) WITH (DROP_EXISTING = ON) ON [PRIMARY]
GO

*/