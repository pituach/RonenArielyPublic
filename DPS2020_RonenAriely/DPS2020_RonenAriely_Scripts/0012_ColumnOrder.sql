use InternalsTableStructure01
GO

DROP TABLE IF EXISTS T
GO
CREATE TABLE T(--,
	Column_Two char(4000) null ,
	Column_One char(4000) null
)
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






INSERT T(Column_One,Column_Two)
SELECT TOP 1000 'a', REPLICATE('b',4000)
GO


/**********************************************************  */
/**************************************** Playing Start Here */
---------------------------- DROP Column_One and Create Column_One
-- Droping column does not remove the column behind the scenes!
-- http://ariely.info/Blog/tabid/83/EntryId/213/SQL-Server-Internals-Getting-the-data-of-deleted-column.aspx
ALTER TABLE T DROP COLUMN Column_One
GO
-- If Column_One is not the last column,  
--    then the new column is added after the old column in addition to the old column!
--    This mean that the PHYSICAL length of table's row behind the scenes is 4000+4000+1 = 8001
-- If Column_One is the last column,  
--    then the new column is added in-place!
--    This mean that the PHYSICAL length of table's row behind the scenes is only 4000+1 = 4001
ALTER TABLE T ADD Column_One char(1) null
GO

-----------------------------------------------------------------------
-- If Column_One is not the last column,  
--    The PHYSICAL length of table's row behind the scenes is 8001
--    THEREFORE, adding another column length 3000 raise an error!
-- If Column_One is the last column,  
--    The PHYSICAL length of table's row behind the scenes is 4001
--    THEREFORE, adding another column length 3000 is OK :-)
ALTER TABLE T ADD Col3 char(3000) null
GO

/****************************************** Playing End Here */
/**********************************************************  */


PRINT 'END!'
GO



