

/*****************************************************************************  */ 
/* Ronen Ariely                                                                 */
/*   Site      : https://ariely.info                                            */
/*   Site      : https://ariely.info/Blog/tabid/83                              */
/*   facebook  : https://www.facebook.com/ronen.ariely/                         */
/*   linkedin  : https://www.linkedin.com/in/pitoach/                           */
/*   twitter   : https://twitter.com/pitoach                                    */
/*                                                                              */
/*****************************************************************************  */ 
/*   Version   : 0.1                                                            */
----------------------------------------------------------------------------------


/*****************************************************************************  */ 
/*****************************************************************************  */ 
/**************************************************** Split LINESTRING to POINT */

----------------------------------------------------------
DROP TABLE IF EXISTS Numbers
GO
CREATE TABLE Numbers (n INT)
GO
;WITH
	L0   AS(SELECT 1 AS c UNION ALL SELECT 1),
	L1   AS(SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
	L2   AS(SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
	L3   AS(SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
	L4   AS(SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
	L5   AS(SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
	Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n FROM L5)
INSERT Numbers 
	select n FROM Nums where n < 100000
GO
CREATE CLUSTERED INDEX IX_Numbers_n
    ON dbo.Numbers (n);   
GO



---------------------------------------------------------- Using Loop
DECLARE @GeometryToConvert GEOMETRY
SET     @GeometryToConvert = 
    GEOMETRY::STGeomFromText('LINESTRING (-71.880713132200128 43.149953199689264, -71.88050339886712 43.149719933022993, -71.880331598867372 43.149278533023676, -71.88013753220099 43.147887799692512, -71.879965998867931 43.147531933026357, -71.879658998868422 43.147003933027179, -71.879539598868575 43.146660333027739, -71.879525332201979 43.145994399695439, -71.87959319886852 43.145452399696296, -71.879660598868384 43.14531113302985, -71.879915932201357 43.145025599696908, -71.879923198868028 43.1449217996971, -71.879885998868076 43.144850733030523, -71.879683932201715 43.144662333030851, -71.879601398868488 43.144565333030982, -71.879316798868956 43.144338333031328, -71.879092332202617 43.144019799698469, -71.8789277322029 43.143902533032019, -71.878747932203169 43.143911533031996, -71.878478132203554 43.14405779969843, -71.878328332203807 43.144066133031743, -71.878148732204068 43.144016599698489, -71.8772655988721 43.143174533033118, -71.876876198872708 43.142725133033821, -71.876801532206173 43.142654933033953, -71.876629398873092 43.142600733034044)', 4269)
   
declare @loop int
declare @Points table (Point GEOMETRY)

set @loop = @GeometryToConvert.STNumPoints()
while @loop > 0 begin
    insert into @Points values(@GeometryToConvert.STPointN(@loop))
    set @loop = @loop -1
end

select Point, Point.STAsText()
from @Points
GO
-- IO very high
-- CPU very high
-- Don't use this!

---------------------------------------------------------- Using recursive CTE 
DECLARE @GeometryToConvert GEOMETRY
SET     @GeometryToConvert = 
    GEOMETRY::STGeomFromText('LINESTRING (-71.880713132200128 43.149953199689264, -71.88050339886712 43.149719933022993, -71.880331598867372 43.149278533023676, -71.88013753220099 43.147887799692512, -71.879965998867931 43.147531933026357, -71.879658998868422 43.147003933027179, -71.879539598868575 43.146660333027739, -71.879525332201979 43.145994399695439, -71.87959319886852 43.145452399696296, -71.879660598868384 43.14531113302985, -71.879915932201357 43.145025599696908, -71.879923198868028 43.1449217996971, -71.879885998868076 43.144850733030523, -71.879683932201715 43.144662333030851, -71.879601398868488 43.144565333030982, -71.879316798868956 43.144338333031328, -71.879092332202617 43.144019799698469, -71.8789277322029 43.143902533032019, -71.878747932203169 43.143911533031996, -71.878478132203554 43.14405779969843, -71.878328332203807 43.144066133031743, -71.878148732204068 43.144016599698489, -71.8772655988721 43.143174533033118, -71.876876198872708 43.142725133033821, -71.876801532206173 43.142654933033953, -71.876629398873092 43.142600733034044)', 4269)
;WITH GeometryPoints(N, Point) AS  
( 
   SELECT 1,  @GeometryToConvert.STPointN(1)
   UNION ALL
   SELECT N + 1, @GeometryToConvert.STPointN(N + 1)
   FROM GeometryPoints GP
   WHERE N < @GeometryToConvert.STNumPoints()  
)
SELECT *, Point.STAsText() FROM GeometryPoints
GO
-- IO very high since it use table spool for the CTE
-- CPU very low

---------------------------------------------------------- Using Numbers Table
DECLARE @GeometryToConvert GEOMETRY
SET     @GeometryToConvert = 
    GEOMETRY::STGeomFromText('LINESTRING (-71.880713132200128 43.149953199689264, -71.88050339886712 43.149719933022993, -71.880331598867372 43.149278533023676, -71.88013753220099 43.147887799692512, -71.879965998867931 43.147531933026357, -71.879658998868422 43.147003933027179, -71.879539598868575 43.146660333027739, -71.879525332201979 43.145994399695439, -71.87959319886852 43.145452399696296, -71.879660598868384 43.14531113302985, -71.879915932201357 43.145025599696908, -71.879923198868028 43.1449217996971, -71.879885998868076 43.144850733030523, -71.879683932201715 43.144662333030851, -71.879601398868488 43.144565333030982, -71.879316798868956 43.144338333031328, -71.879092332202617 43.144019799698469, -71.8789277322029 43.143902533032019, -71.878747932203169 43.143911533031996, -71.878478132203554 43.14405779969843, -71.878328332203807 43.144066133031743, -71.878148732204068 43.144016599698489, -71.8772655988721 43.143174533033118, -71.876876198872708 43.142725133033821, -71.876801532206173 43.142654933033953, -71.876629398873092 43.142600733034044)', 4269)
SELECT n, MyPoint = @GeometryToConvert.STPointN(n), @GeometryToConvert.STPointN(n).STAsText()
FROM Numbers 
where n  <= @GeometryToConvert.STNumPoints ()
GO
-- IO high
-- CPU high
-- Yet... when the source data is a table this might be the best option in some cases

---------------------------------------------------------- Using on-the-fly table
DECLARE @GeometryToConvert GEOMETRY
SET     @GeometryToConvert = 
    GEOMETRY::STGeomFromText('LINESTRING (-71.880713132200128 43.149953199689264, -71.88050339886712 43.149719933022993, -71.880331598867372 43.149278533023676, -71.88013753220099 43.147887799692512, -71.879965998867931 43.147531933026357, -71.879658998868422 43.147003933027179, -71.879539598868575 43.146660333027739, -71.879525332201979 43.145994399695439, -71.87959319886852 43.145452399696296, -71.879660598868384 43.14531113302985, -71.879915932201357 43.145025599696908, -71.879923198868028 43.1449217996971, -71.879885998868076 43.144850733030523, -71.879683932201715 43.144662333030851, -71.879601398868488 43.144565333030982, -71.879316798868956 43.144338333031328, -71.879092332202617 43.144019799698469, -71.8789277322029 43.143902533032019, -71.878747932203169 43.143911533031996, -71.878478132203554 43.14405779969843, -71.878328332203807 43.144066133031743, -71.878148732204068 43.144016599698489, -71.8772655988721 43.143174533033118, -71.876876198872708 43.142725133033821, -71.876801532206173 43.142654933033953, -71.876629398873092 43.142600733034044)', 4269)
SELECT n, @GeometryToConvert.STPointN(n), @GeometryToConvert.STPointN(n).STAsText()
FROM (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),(21),(22),(23),(24),(25),(26),(27),(28),(29)) Numbers (n) 
where n  <= @GeometryToConvert.STNumPoints ()
GO
-- No IO
-- CPU high


/*****************************************************************************  */ 
/*****************************************************************************  */ 
/**************************************************** Split MULTIPOINT to POINT */
-- Note! this is the same procedure as Split LINESTRING (or any other collaction) to POINT


---------------------------------------------------------- Breack MULTIPOINT to table of points
DECLARE @g geography;
SET @g = geography::STGeomFromText('MULTIPOINT((2 3), (7 8 9.5))', 4326); -- MULTIPOINT: collection of points 
SELECT C1, @g.STGeometryN(t1.c1).ToString(), @g.STGeometryN(t1.c1).Lat, @g.STGeometryN(t1.c1).Long --, CONVERT(VARCHAR(100),@g.STGeometryN(t1.c1))
FROM (VALUES (1),(2),(3),(4)) t1 (c1) -- use number table which has moire numbers then the max that might have in your case
where t1.c1 <= @g.STNumPoints ()
GO

---------------------------------------------------------- 


/*****************************************************************************  */ 
/*************** Extract LineStrings in GeometryCollection to create LineString */
-- Note! This solution based previous "Split MULTIPOINT to POINT" as first step. This is not direct approach

---------------------------------------------------- Copnvert MULTIPOINT into LINESTRING
DECLARE @g geography;
SET @g = geography::STGeomFromText('MULTIPOINT((2 3), (7 8 9.5))', 4326);
-- CONVERT THE ABOVE MULTIPOINT INTO LINESTRING
;With MyCTE as (
	-- Breack MULTIPOINT to table of points
	SELECT C1, MyPoint = @g.STGeometryN(t1.c1)
	FROM (VALUES (1),(2),(3),(4)) t1 (c1)
	where t1.c1 <= @g.STNumPoints ()
)
,MyCTE2 as (
	select MyStr = 
		'LINESTRING(' + STRING_AGG(CONVERT(VARCHAR(10),MyPoint.Long) + ' ' + CONVERT(VARCHAR(10),MyPoint.Lat), ', ') WITHIN GROUP(ORDER BY C1) + ')'
	FROM MyCTE   
)
SELECT geography::STLineFromText(MyStr, 4326).ToString()
from MyCTE2
GO


/*****************************************************************************  */ 
/*****************************************************************************  */ 
/*****************************************************************************  */ 
