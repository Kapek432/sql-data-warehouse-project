-- ========================================================================
-- CRM_CUST_INFO Transformation Script: Bronze → Silver Layer
-- Description:
--     This script performs data cleansing, deduplication, trimming, and 
--     standardization for the bronze.crm_cust_info table. The output is 
--     ready to be loaded into the silver layer following Medallion Architecture.
-- ========================================================================

-- ============================================================
-- STEP 1: Check for NULLs in the primary key (cst_id)
-- ============================================================
SELECT COUNT(*) AS null_cst_id_count
FROM bronze.crm_cust_info
WHERE cst_id IS NULL;

-- ============================================================
-- STEP 2: Check for duplicate customer IDs
-- ============================================================
SELECT cst_id, COUNT(*) AS duplicate_count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- ============================================================
-- STEP 3: Inspect an example duplicate entry
-- ============================================================
SELECT * 
FROM bronze.crm_cust_info
WHERE cst_id = 29483;

-- ============================================================
-- STEP 4: Identify latest records based on cst_create_date
--         (used for deduplication logic)
-- ============================================================
SELECT *, 
       ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS row_num
FROM bronze.crm_cust_info
WHERE cst_id = 29483;

-- ============================================================
-- STEP 5: Check for extra whitespace in selected fields
-- ============================================================
-- First Name
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Last Name
SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Customer Key (none expected)
SELECT cst_key
FROM bronze.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Marital Status
SELECT cst_marital_status
FROM bronze.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);

-- Gender
SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- ============================================================
-- STEP 6: Distinct values for categorical normalization
-- ============================================================
-- Marital Status
SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;

-- Gender
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

-- ============================================================
-- STEP 7: FINAL TRANSFORMED DATASET — ready for silver layer
-- ============================================================
-- This query:
-- - Removes rows with NULL primary keys
-- - Deduplicates by keeping the latest record per cst_id
-- - Trims whitespace
-- - Normalizes categorical values for marital status and gender
SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'Unknown'
    END AS cst_marital_status,
    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'Unknown'
    END AS cst_gndr,
    cst_create_date
FROM (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS row_num
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) AS t
WHERE row_num = 1;

-- ============================================================
-- End of crm_cust_info transformation
-- This cleaned data can now be inserted into silver.crm_cust_info
-- ============================================================
