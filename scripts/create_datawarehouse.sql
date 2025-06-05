/*
    Script: create_datawarehouse.sql
    Description:
    This script creates a SQL Server database called 'DataWarehouse' along with 
    three schemas: bronze, silver, and gold. These schemas follow the Medallion Architecture:
      - bronze: stores raw data
      - silver: stores cleaned/transformed data
      - gold: stores business-ready, analytical data
*/

-- Switch to the 'master' database to perform database-level operations
USE master;
GO

-- Check if the 'DataWarehouse' database already exists, and drop it if needed
-- (Optional safety mechanism - uncomment if you want to reset the DB during testing)
-- IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
-- BEGIN
--     DROP DATABASE DataWarehouse;
-- END
-- GO

-- Create the 'DataWarehouse' database
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    CREATE DATABASE DataWarehouse;
END
GO

-- Switch context to the newly created database
USE DataWarehouse;
GO

-- Create schemas for each Medallion layer
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
