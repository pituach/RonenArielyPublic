
/****************************************************  */
/* [logical layer] vs [Physical layer under the scene] */
/****************************************************  */

use InternalsTableStructure01
GO

----------------------------------------------- Create Sample table
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
            [logical layer]
==================================================*/
SELECT * FROM T
GO----------------------------------------------- Select From Table
select object_id as Table_ID, [name], column_id
from sys.columns
where object_id = OBJECT_ID(N'T')
GO----------------------------------------------- sys.columns
EXEC sp_help @objname = 'T'
GO----------------------------------------------- sp_help
GO ---------------- SSMS object explorer - logical layer! */


