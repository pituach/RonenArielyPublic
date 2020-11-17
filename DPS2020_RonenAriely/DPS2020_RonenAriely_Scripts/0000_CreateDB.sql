
use master
GO

ALTER DATABASE [InternalsTableStructure01] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
ALTER DATABASE [InternalsTableStructure02] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

DROP DATABASE IF EXISTS InternalsTableStructure01
DROP DATABASE IF EXISTS InternalsTableStructure02
GO



/****************************************************  */
/*              CREATE DATABASE                */
/****************************************************  */
CREATE DATABASE InternalsTableStructure01
CREATE DATABASE InternalsTableStructure02
GO

