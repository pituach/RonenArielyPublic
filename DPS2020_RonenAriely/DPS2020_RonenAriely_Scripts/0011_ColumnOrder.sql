use InternalsTableStructure01
GO

DROP TABLE IF EXISTS T
GO
CREATE TABLE T(-- ,
	Column_Two char(1) null,
	Column_One char(4000) null
)
GO

INSERT T(Column_One,Column_Two)
SELECT REPLICATE('b',4000), 'a'
GO

/***********************************************************/
/* illustrate Some actions which are executed on the table */
/***********************************************************/
/***********************************************************/
/***********************************************************/
/***********************************************************/
/***********************************************************/
/***********************************************************/
/***********************************************************/
/***********************************************************/
/***********************************************************/
/***********************************************************/

ALTER TABLE T DROP COLUMN Column_One
GO
ALTER TABLE T ADD Column_Three char(3000) null
GO

INSERT T(Column_Two,Column_Three)
SELECT TOP 10000 'a', REPLICATE('b',3000)
FROM sys.all_objects t1
CROSS JOIN sys.all_objects t2
GO

/***********************************************************/
/*********************** Result ****************************/
/***********************************************************/
-- number of pages
SELECT type_desc, SUM(total_pages) total_pages, SUM(used_pages) used_pages,SUM(data_pages) data_pages
FROM sys.allocation_units
GROUP BY type_desc
GO

-- Size of databases
SELECT      sys.databases.name,  
            CONVERT(VARCHAR,SUM(size)*8/1024)+' MB' AS [Total disk space]  
FROM        sys.databases   
JOIN        sys.master_files  
ON          sys.databases.database_id=sys.master_files.database_id  
where sys.databases.name = 'InternalsTableStructure01' or sys.databases.name = 'InternalsTableStructure02'
GROUP BY    sys.databases.name  
ORDER BY    sys.databases.name 
GO
