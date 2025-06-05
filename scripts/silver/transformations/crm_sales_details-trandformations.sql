-- ============================================================================
-- CRM_SALES_DETAILS Transformation Script: Bronze → Silver Layer
-- Description:
--     This script cleans and transforms sales transaction data for the Silver Layer.
--     It includes validation and normalization of dates, correction of numeric anomalies,
--     and basic imputation logic for sales-related fields.
-- ============================================================================

-- ============================================================
-- STEP 1: Inspect for invalid sales order/ship/due dates
-- ============================================================

-- Check for incorrect date lengths
SELECT *
FROM bronze.crm_sales_details
WHERE LEN(sls_order_dt) != 8 OR LEN(sls_ship_dt) != 8 OR LEN(sls_due_dt) != 8;

-- ============================================================
-- STEP 2: Normalize date fields (replace 0 or invalid length with NULL)
-- ============================================================

SELECT 
    CASE 
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,
    CASE 
        WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,
    CASE 
        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt
FROM bronze.crm_sales_details;

-- ============================================================
-- STEP 3: Check logical consistency between dates
-- ============================================================

SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_ship_dt > sls_due_dt;

-- No invalid date sequences remain

-- ============================================================
-- STEP 4: Inspect sales-related numeric fields for data quality
-- ============================================================

SELECT
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE 
    sls_sales < 0 OR sls_price < 0
    OR sls_sales IS NULL OR sls_price IS NULL
    OR sls_quantity IS NULL;

-- Observation:
-- - sls_quantity contains no invalid values
-- - sls_sales and sls_price may be NULL or negative

-- ============================================================
-- STEP 5: Normalize and impute invalid sales and price values
-- ============================================================

SELECT
    -- Raw values
    sls_sales,
    sls_quantity,
    sls_price,

    -- Cleaned and imputed fields
    CASE
        WHEN sls_sales IS NULL OR sls_sales < 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales_new,

    sls_quantity AS sls_quantity_new,

    CASE
        WHEN sls_price IS NULL OR sls_price < 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price_new
FROM bronze.crm_sales_details
WHERE 
    sls_sales IS NULL OR sls_sales < 0 
    OR sls_price IS NULL OR sls_price < 0 
    OR sls_sales != sls_quantity * ABS(sls_price);

-- ============================================================
-- STEP 6: FINAL TRANSFORMED DATASET — ready for silver layer
-- ============================================================

-- Final output:
-- - Normalizes and validates sales/due/ship dates
-- - Imputes/corrects sales and price values
-- - Retains original identifiers
SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,

    -- Normalized and validated date fields
    CASE 
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,

    CASE 
        WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,

    CASE 
        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,

    -- Cleaned and imputed numeric fields
	CASE
        WHEN sls_sales IS NULL OR sls_sales < 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,

    sls_quantity,

    CASE
        WHEN sls_price IS NULL OR sls_price < 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details;

-- ============================================================
-- End of crm_sales_details transformation
-- This cleaned dataset is ready for loading into silver.crm_sales_details
-- ============================================================

