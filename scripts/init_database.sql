/*
	Create Database 'DataWarehouse2'
*/

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse2')
BEGIN
	ALTER DATABASE DataWarehouse2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse2;
END
GO

CREATE DATABASE DataWarehouse2;
GO

USE DataWarehouse2;
GO

/*
	Create Layer Schema
*/

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
