/*
================================================================================
DataWarehouse2 Database and Layer Schema Setup
--------------------------------------------------------------------------------
Script Purpose: 
    Create the DataWarehouse2 database and initialize the Bronze, Silver, 
    and Gold schemas for a layered data warehouse architecture.

Warning:
    This script will permanently drop the existing DataWarehouse2 database 
    and all of its data if the database already exists.
    Do not run this script in a production environment unless the database
    deletion is intentional and properly backed up.
================================================================================
*/

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
