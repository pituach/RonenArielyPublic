

/*********************** DATA_COMPRESSION ***************/

-- REBUILD: ROW and PAGE compression for rowstore tables and indexes


use AdventureWorks2019
GO

-- What tables and indexes are not compressed?
SELECT DISTINCT s.name, t.name, i.name, i.type, i.index_id, p.partition_number, p.rows
FROM sys.tables t
LEFT JOIN sys.indexes i ON t.object_id = i.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
LEFT JOIN sys.partitions p ON i.index_id = p.index_id AND t.object_id = p.object_id
WHERE t.type = 'U' AND p.data_compression_desc = 'NONE'
ORDER BY p.rows desc
GO





EXEC sp_estimate_data_compression_savings 
    @schema_name = 'Sales', 
    @object_name = 'SalesOrderDetail', 
    @index_id = NULL, 
    @partition_number = NULL, 
    @data_compression = 'ROW'
 GO

EXEC sp_estimate_data_compression_savings 
    @schema_name = 'Sales', 
    @object_name = 'SalesOrderDetail', 
    @index_id = NULL, 
    @partition_number = NULL, 
    @data_compression = 'PAGE'
GO



ALTER INDEX PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID 
        ON Sales.SalesOrderDetail 
        REBUILD PARTITION = ALL 
        WITH (DATA_COMPRESSION = PAGE);
GO

ALTER INDEX IX_SalesOrderDetail_ProductID
        ON Sales.SalesOrderDetail 
        REBUILD PARTITION = ALL 
        WITH (DATA_COMPRESSION = PAGE);
GO




