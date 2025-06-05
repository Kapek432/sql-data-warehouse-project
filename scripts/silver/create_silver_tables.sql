/*
    Script: create_silver_tables.sql
    Description:
    This script creates the Silver Layer tables for the Data Warehouse project.
    These tables store cleaned and standardized data derived from the Bronze Layer.
    The schema 'silver' is used for the curated, structured layer following Medallion Architecture.
*/

-- ==========================================
-- CRM: Customer Information Table
-- ==========================================
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id              INT,             -- Customer ID
    cst_key             NVARCHAR(50),    -- Customer Key (textual)
    cst_firstname       NVARCHAR(50),    -- First Name
    cst_lastname        NVARCHAR(50),    -- Last Name
    cst_marital_status  NVARCHAR(50),    -- Marital Status
    cst_gndr            NVARCHAR(50),    -- Gender
    cst_create_date     DATE,            -- Account creation date
    record_created_at   DATETIME2 DEFAULT GETDATE()        -- Time of record creation
);
GO

-- ==========================================
-- CRM: Product Information Table
-- ==========================================
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id            INT,             -- Product ID
	cat_id            NVARCHAR(50),    -- Category ID
    prd_key           NVARCHAR(50),    -- Product Key
    prd_nm            NVARCHAR(50),    -- Product Name
    prd_cost          INT,             -- Product Cost
    prd_line          NVARCHAR(50),    -- Product Line
	prd_start_dt      DATE,			   -- Availability Start Date
    prd_end_dt        DATE,            -- Availability End Date
    record_created_at DATETIME2 DEFAULT GETDATE()         -- Time of record creation
);
GO

-- ==========================================
-- CRM: Sales Details Table
-- ==========================================
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num       NVARCHAR(50),    -- Sales Order Number
    sls_prd_key       NVARCHAR(50),    -- Product Key
    sls_cust_id       INT,             -- Customer ID
    sls_order_dt      DATE,            -- Order Date (YYYY-MM-DD)
    sls_ship_dt       DATE,             -- Ship Date
    sls_due_dt        DATE,             -- Due Date
    sls_sales         INT,             -- Sales Amount
    sls_quantity      INT,             -- Quantity Sold
    sls_price         INT,             -- Product Price
    record_created_at DATETIME2 DEFAULT GETDATE()       -- Time of record creation
);
GO

-- ==========================================
-- ERP: Customer Location Table
-- ==========================================
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    cid               NVARCHAR(50),    -- Customer ID
    cntry             NVARCHAR(50),    -- Country
    record_created_at DATETIME2 DEFAULT GETDATE()         -- Time of record creation
);
GO

-- ==========================================
-- ERP: Customer Demographics Table
-- ==========================================
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    cid               NVARCHAR(50),    -- Customer ID
    bdate             DATE,            -- Birthdate
    gen               NVARCHAR(50),    -- Gender
    record_created_at DATETIME2 DEFAULT GETDATE()       -- Time of record creation
);
GO

-- ==========================================
-- ERP: Product Category Table
-- ==========================================
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id                NVARCHAR(50),    -- Product/Category ID
    cat               NVARCHAR(50),    -- Category
    subcat            NVARCHAR(50),    -- Subcategory
    maintenance       NVARCHAR(50),    -- Maintenance type or status
    record_created_at DATETIME2 DEFAULT GETDATE()         -- Time of record creation
);
GO
