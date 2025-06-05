-- ============================================================================
-- ERP_LOC_A101 Transformation Script: Bronze → Silver Layer
-- Description:
--     This script cleans and standardizes customer location data for the Silver Layer.
--     It includes normalization of customer ID values and mapping of country codes
--     to standardized country names.
-- ============================================================================

-- ============================================================
-- STEP 1: Preview raw input data
-- ============================================================
SELECT * 
FROM bronze.erp_loc_a101;

-- ============================================================
-- STEP 2: Clean customer ID (cid)
-- ============================================================

-- Observation:
-- Customer IDs contain hyphens ('-'), which should be removed

SELECT 
    cid,
    REPLACE(cid, '-', '') AS cleaned_cid
FROM bronze.erp_loc_a101;

-- ============================================================
-- STEP 3: Inspect and standardize country codes (cntry)
-- ============================================================

-- Distinct values in cntry
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101;

-- Mapping rules:
-- - 'DE'  → 'Germany'
-- - 'US', 'USA' → 'United States'
-- - '' (empty) or NULL → 'Unknown'
-- - All other values → keep trimmed original

-- Preview standardized country values
SELECT
    REPLACE(cid, '-', '') AS cid, 
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'Unknown'
        ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101;

-- ============================================================
-- STEP 4: FINAL TRANSFORMED DATASET — ready for silver layer
-- ============================================================

-- Final output:
-- - Removes hyphens from customer ID
-- - Maps country codes to standardized country names

SELECT
    REPLACE(cid, '-', '') AS cid,
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'Unknown'
        ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101;

-- ============================================================
-- End of erp_loc_a101 transformation
-- This cleaned dataset is ready for loading into silver.crm_cust_location
-- ============================================================
