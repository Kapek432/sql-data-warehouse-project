-- ============================================================================
-- CRM_PRD_INFO Transformation Script: Bronze → Silver Layer
-- Description:
--     This script cleans and transforms product data for the Silver Layer.
--     It includes deduplication, key extraction, date normalization, 
--     and categorical value standardization.
-- ============================================================================

-- ============================================================
-- STEP 1: Inspect for NULLs and duplicates in primary key
-- ============================================================
SELECT COUNT(*) AS null_prd_id_count
FROM bronze.crm_prd_info
WHERE prd_id IS NULL;

SELECT prd_id, COUNT(*) AS duplicate_count
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;

-- No NULLs or duplicates detected in prd_id (primary key)

-- ============================================================
-- STEP 2: Analyze product key structure for joining
-- ============================================================

-- Check how prd_key aligns with external data (ERP & Sales)
SELECT DISTINCT prd_key FROM bronze.crm_prd_info;
SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2;
SELECT DISTINCT sls_prd_key FROM bronze.crm_sales_details;

-- Observation:
-- - First 5 characters of prd_key (after replacing '-' with '_') → join with erp_px_cat_g1v2.id
-- - Characters from position 7 onward → join with crm_sales_details.sls_prd_key

-- Preview transformed keys
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key_sls,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;

-- ============================================================
-- STEP 3: Check and handle NULLs in prd_cost
-- ============================================================
SELECT MAX(prd_cost) AS max_cost, MIN(prd_cost) AS min_cost
FROM bronze.crm_prd_info;

SELECT * 
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL;

-- Decision: Replace NULLs with 0 in prd_cost

-- ============================================================
-- STEP 4: Check for whitespace issues
-- ============================================================
SELECT COUNT(*) AS dirty_prd_nm_count
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- ✅ No trimming needed for prd_nm

-- ============================================================
-- STEP 5: Standardize categorical values in prd_line
-- ============================================================
SELECT DISTINCT prd_line FROM bronze.crm_prd_info;

-- Mapping:
-- - M → Mountain
-- - R → Road
-- - S → Other Sales
-- - T → Touring

-- ============================================================
-- STEP 6: Check for invalid or illogical date ranges
-- ============================================================
SELECT * 
FROM bronze.crm_prd_info
WHERE prd_start_dt > prd_end_dt;

-- Review entire date sequence
SELECT *
FROM bronze.crm_prd_info
ORDER BY prd_id, prd_start_dt;

-- ============================================================
-- STEP 7: FINAL TRANSFORMED DATASET — ready for silver layer
-- ============================================================

-- Final output:
-- - Extracts normalized keys for joins
-- - Replaces NULL cost with 0
-- - Standardizes product line descriptions
-- - Recalculates prd_end_dt based on next prd_start_dt per key
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- standardized category ID
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,        -- sales-compatible product key
    prd_nm,
    ISNULL(prd_cost, 0) AS prd_cst,                        -- replace nulls with 0
    CASE UPPER(TRIM(prd_line))                             -- standardize product line
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'Unknown'
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,            -- ensure DATE format
    CAST(
        LEAD(prd_start_dt) OVER (
            PARTITION BY prd_key 
            ORDER BY prd_start_dt
        ) - 1 AS DATE
    ) AS prd_end_dt -- inferred end date based on next start date
FROM bronze.crm_prd_info;

-- ============================================================
-- End of crm_prd_info transformation
-- This cleaned dataset is ready for loading into silver.crm_prd_info
-- ============================================================
