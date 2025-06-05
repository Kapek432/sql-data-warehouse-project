-- ============================================================================
-- ERP_PX_CAT_G1V2 Transformation Script: Bronze → Silver Layer
-- Description:
--     This script validates and prepares product category mapping data for the Silver Layer.
--     It includes verification of categorical values and whitespace normalization.
-- ============================================================================

-- ============================================================
-- STEP 1: Preview raw input data
-- ============================================================
SELECT * 
FROM bronze.erp_px_cat_g1v2;

-- ============================================================
-- STEP 2: Inspect distinct values for reference columns
-- ============================================================

-- Category codes
SELECT DISTINCT cat 
FROM bronze.erp_px_cat_g1v2;

-- Subcategory codes
SELECT DISTINCT subcat 
FROM bronze.erp_px_cat_g1v2;

-- Maintenance tags
SELECT DISTINCT maintenance 
FROM bronze.erp_px_cat_g1v2;

-- ============================================================
-- STEP 3: Check for unwanted whitespace
-- ============================================================

SELECT * 
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- No whitespace issues found in cat, subcat or maintenance columns

-- ============================================================
-- STEP 4: FINAL TRANSFORMED DATASET — ready for silver layer
-- ============================================================

-- Final output:
-- - No transformation needed
-- - Data can be passed directly to the silver layer

SELECT *
FROM bronze.erp_px_cat_g1v2;

-- ============================================================
-- End of erp_px_cat_g1v2 transformation
-- This clean dataset is ready for loading into silver.erp_px_cat_g1v2
-- ============================================================
