-- ============================================================================
-- Procedure: silver.load_silver_layer
-- Description:
--     Transforms and loads data from the Bronze Layer to the Silver Layer.
--     Applies cleansing, normalization, and business rules as per transformation scripts.
--     Measures time per each load step and logs errors if any.
-- ============================================================================

CREATE OR ALTER PROCEDURE silver.load_silver_layer AS
BEGIN
    DECLARE @start_all    DATETIME2 = SYSDATETIME();
    DECLARE @start_step   DATETIME2;
    DECLARE @end_step     DATETIME2;
    DECLARE @duration_ms  INT;

    PRINT '=== Starting load into Silver Layer ===';

    BEGIN TRY

        -- === CRM Customer Info ===
        PRINT '=== Transforming & Loading CRM Customer Info ===';
        SET @start_step = SYSDATETIME();

        TRUNCATE TABLE silver.crm_cust_info;

        INSERT INTO silver.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
        SELECT 
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'Unknown'
            END,
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'Unknown'
            END,
            cst_create_date
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS row_num
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) AS t
        WHERE row_num = 1;

        SET @end_step = SYSDATETIME();
        SET @duration_ms = DATEDIFF(MILLISECOND, @start_step, @end_step);
        PRINT 'CRM Customer Info loaded in ' + CAST(@duration_ms AS VARCHAR) + ' ms';

        -- === CRM Product Info ===
        PRINT '=== Transforming & Loading CRM Product Info ===';
        SET @start_step = SYSDATETIME();

        TRUNCATE TABLE silver.crm_prd_info;

        INSERT INTO silver.crm_prd_info (prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
            SUBSTRING(prd_key, 7, LEN(prd_key)),
            prd_nm,
            ISNULL(prd_cost, 0),
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'Unknown'
            END,
            CAST(prd_start_dt AS DATE),
            CAST(
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key 
                    ORDER BY prd_start_dt
                ) - 1 AS DATE
            )
        FROM bronze.crm_prd_info;

        SET @end_step = SYSDATETIME();
        SET @duration_ms = DATEDIFF(MILLISECOND, @start_step, @end_step);
        PRINT 'CRM Product Info loaded in ' + CAST(@duration_ms AS VARCHAR) + ' ms';

        -- === CRM Sales Details ===
        PRINT '=== Transforming & Loading CRM Sales Details ===';
        SET @start_step = SYSDATETIME();

        TRUNCATE TABLE silver.crm_sales_details;

        INSERT INTO silver.crm_sales_details (
            sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END,
            CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END,
            CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END,
            CASE WHEN sls_sales IS NULL OR sls_sales < 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price) ELSE sls_sales END,
            sls_quantity,
            CASE WHEN sls_price IS NULL OR sls_price < 0 THEN sls_sales / NULLIF(sls_quantity, 0) ELSE sls_price END
        FROM bronze.crm_sales_details;

        SET @end_step = SYSDATETIME();
        SET @duration_ms = DATEDIFF(MILLISECOND, @start_step, @end_step);
        PRINT 'CRM Sales Details loaded in ' + CAST(@duration_ms AS VARCHAR) + ' ms';

        -- === ERP Customer AZ12 ===
        PRINT '=== Transforming & Loading ERP Customer AZ12 ===';
        SET @start_step = SYSDATETIME();

        TRUNCATE TABLE silver.erp_cust_az12;

        INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
        SELECT 
            CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END,
            CASE WHEN bdate < DATEADD(YEAR, -100, GETDATE()) OR bdate > GETDATE() THEN NULL ELSE CAST(bdate AS DATE) END,
            CASE
                WHEN gen IS NULL THEN 'Unknown'
                WHEN UPPER(gen) IN ('M', 'MALE') THEN 'Male'
                WHEN UPPER(gen) IN ('F', 'FEMALE') THEN 'Female'
                ELSE 'Unknown'
            END
        FROM bronze.erp_cust_az12;

        SET @end_step = SYSDATETIME();
        SET @duration_ms = DATEDIFF(MILLISECOND, @start_step, @end_step);
        PRINT 'ERP Customer AZ12 loaded in ' + CAST(@duration_ms AS VARCHAR) + ' ms';

        -- === ERP Location A101 ===
        PRINT '=== Transforming & Loading ERP Location A101 ===';
        SET @start_step = SYSDATETIME();

        TRUNCATE TABLE silver.erp_loc_a101;

        INSERT INTO silver.erp_loc_a101 (cid, cntry)
        SELECT 
            REPLACE(cid, '-', ''),
            CASE
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'Unknown'
                ELSE TRIM(cntry)
            END
        FROM bronze.erp_loc_a101;

        SET @end_step = SYSDATETIME();
        SET @duration_ms = DATEDIFF(MILLISECOND, @start_step, @end_step);
        PRINT 'ERP Location A101 loaded in ' + CAST(@duration_ms AS VARCHAR) + ' ms';

        -- === ERP Product Category G1V2 ===
        PRINT '=== Loading ERP Product Category G1V2 ===';
        SET @start_step = SYSDATETIME();

        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
        SELECT id, cat, subcat, maintenance
        FROM bronze.erp_px_cat_g1v2;

        SET @end_step = SYSDATETIME();
        SET @duration_ms = DATEDIFF(MILLISECOND, @start_step, @end_step);
        PRINT 'ERP Product Category G1V2 loaded in ' + CAST(@duration_ms AS VARCHAR) + ' ms';

        -- === Total Duration ===
        SET @end_step = SYSDATETIME();
        SET @duration_ms = DATEDIFF(MILLISECOND, @start_all, @end_step);
        PRINT '=== Silver Layer Load Complete in ' + CAST(@duration_ms AS VARCHAR) + ' ms ===';

    END TRY
    BEGIN CATCH
        PRINT '=== ERROR OCCURRED DURING LOAD ===';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    END CATCH
END;
