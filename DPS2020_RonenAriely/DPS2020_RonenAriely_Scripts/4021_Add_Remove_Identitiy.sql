

/*==================================================
	[Table structure: IDENTITY property] 
==================================================*/

USE tempdb
GO

DROP TABLE IF EXISTS T
GO
create table T (id int IDENTITY (2,2), txt NVARCHAR(100))
GO

INSERT T (txt) VALUES ('Ronen'),('Ariely')
GO

SELECT * FROM T
GO


DBCC IND('tempdb', 'dbo.T', 0);
GO -- Page: 56


/**************** REMOVE IDENTITY ***********/
DROP TABLE IF EXISTS T1
GO
create table T1 (id int not null, txt NVARCHAR(100))
GO


ALTER TABLE T SWITCH TO T1
GO

SELECT * FROM T1
GO -- Data registered under this table
SELECT * FROM T
GO 

DBCC IND('tempdb', 'dbo.T1', 0);
GO -- Page: 432 
-- No Data registered under original table!
-- The Data simply registered to the new table with no data move!


/**************** ADD IDENTITY ***********/
DROP TABLE IF EXISTS T2
GO
create table T2 (id int IDENTITY(1,1) not null, txt NVARCHAR(100))
GO

ALTER TABLE T1 SWITCH TO T2
GO
-- DBCC CHECKIDENT ( table_name, RESEED, new_reseed_value )
DECLARE @id INT; SELECT @id =  MAX(id) + 1 FROM T2
DBCC CHECKIDENT ( T2, RESEED, @id)
GO


SELECT * FROM T1
GO 
SELECT * FROM T2
GO -- Data registered under this table

DBCC IND('tempdb', 'dbo.T2', 0);
GO -- Page: 432 
-- No Data registered under original table!
-- The Data simply registered to the new table with no data move!

INSERT T2(txt) VALUES ('Confirm IDENDITY Works')
GO
SELECT * FROM T2
GO






