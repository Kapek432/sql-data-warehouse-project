-- ============================================================================
-- ERP_CUST_AZ12 Transformation Script: Bronze → Silver Layer
-- Description:
--     This script cleans and transforms customer data for the Silver Layer.
--     It includes normalization of customer keys, correction of birth dates,
--     and standardization of gender values.
-- ============================================================================

-- ============================================================
-- STEP 1: Preview raw input data
-- ============================================================
SELECT * 
FROM bronze.erp_cust_az12;

-- ============================================================
-- STEP 2: Normalize customer ID (cid)
-- ============================================================

-- Observation:
-- Some customer IDs are prefixed with 'NAS'. Remove this prefix.

SELECT 
    cid,
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cst_key -- normalized customer key
FROM bronze.erp_cust_az12;

-- ============================================================
-- STEP 3: Validate and clean birth date (bdate)
-- ============================================================

-- Rule:
-- - Customers cannot be older than 100 years
-- - Future birthdates are also invalid

SELECT *
FROM bronze.erp_cust_az12
WHERE bdate < DATEADD(YEAR, -100, GETDATE())
   OR bdate > GETDATE();

-- Action:
-- - Replace out-of-range birthdates with NULL

-- ============================================================
-- STEP 4: Standardize gender column (gen)
-- ============================================================

-- Mapping:
-- - 'M' → 'Male'
-- - 'F' → 'Female'
-- - NULL or empty → 'Unknown'

SELECT DISTINCT gen 
FROM bronze.erp_cust_az12;

-- Preview transformed gender values
SELECT 
    CASE
        WHEN gen IS NULL OR LTRIM(RTRIM(gen)) = '' THEN 'Unknown'
        WHEN UPPER(gen) IN ('M','MALE') THEN 'Male'
        WHEN UPPER(gen) IN ('F','FEMALE') THEN 'Female'
        ELSE 'Unknown'
    END AS standardized_gen
FROM bronze.erp_cust_az12;

-- ============================================================
-- STEP 5: FINAL TRANSFORMED DATASET — ready for silver layer
-- ============================================================

-- Final output:
-- - Normalizes customer key (cst_key)
-- - Cleans bdate based on logical limits
-- - Standardizes gender values

SELECT 
    -- Normalized customer key
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cst_key,

    -- Cleaned birth date
    CASE
        WHEN bdate < DATEADD(YEAR, -100, GETDATE()) OR bdate > GETDATE() THEN NULL
        ELSE CAST(bdate AS DATE)
    END AS bdate,

    -- Standardized gender
    CASE
        WHEN gen IS NULL THEN 'Unknown'
        WHEN UPPER(gen) IN ('M','MALE') THEN 'Male'
        WHEN UPPER(gen) IN ('F','FEMALE') THEN 'Female'
        ELSE 'Unknown'
    END AS gen

FROM bronze.erp_cust_az12;

-- ============================================================
-- End of erp_cust_az12 transformation
-- This cleaned dataset is ready for loading into silver.crm_cust_info
-- ============================================================
