-- =============================================
-- Procedure: bronze.load_bronze_layer
-- Description: Loads CSV data into the bronze layer tables with timing and error handling.
-- Tracks load time using 4 declared datetime variables.
-- =============================================
CREATE OR ALTER PROCEDURE bronze.load_bronze_layer AS
BEGIN
    -- Time tracking variables
    DECLARE @start_all      DATETIME2 = SYSDATETIME();
    DECLARE @start_step     DATETIME2;
    DECLARE @end_step       DATETIME2;
    DECLARE @duration_ms    INT;

    PRINT '=== Starting load into Bronze Layer ===';

    BEGIN TRY

        -- === CRM Customer Info ===
        PRINT '=== Loading CRM Customer Info ===';
        SET @start_step = SYSDATETIME();

        TRUNCATE TABLE bronze.crm_cust_info;
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\ACER\Desktop\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_step = SYSDATETIME();
        SET @duration_ms = DATEDIFF(MILLISECOND, @start_step, @end_step);
        PRINT 'CRM Customer Info loaded in ' + CAST(@duration_ms AS VARCHAR) + ' ms';

        -- === CRM Product Info ===
        PRINT '=== Loading CRM Product Info ===';
        SET @start_step = SYSDATETIME();

        TRUNCATE TABLE bronze.crm_prd_info;
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\ACER\Desktop\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_step = SYSDATETIME();
        SET @duration_ms = DATEDIFF(MILLISECOND, @start_step, @end_step);
        PRINT 'CRM Product Info loaded in ' + CAST(@duration_ms AS VARCHAR) + ' ms';

        -- === CRM Sales Details ===
        PRINT '=== Loading CRM Sales Details ===';
        SET @start_step = SYSDATETIME();

        TRUNCATE TABLE bronze.crm_sales_details;
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\ACER\Desktop\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_step = SYSDATETIME();
        SET @duration_ms = DATEDIFF(MILLISECOND, @start_step, @end_step);
        PRINT 'CRM Sales Details loaded in ' + CAST(@duration_ms AS VARCHAR) + ' ms';

        -- === ERP Customer AZ12 ===
        PRINT '=== Loading ERP Customer AZ12 ===';
        SET @start_step = SYSDATETIME();

        TRUNCATE TABLE bronze.erp_cust_az12;
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\ACER\Desktop\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_step = SYSDATETIME();
        SET @duration_ms = DATEDIFF(MILLISECOND, @start_step, @end_step);
        PRINT 'ERP Customer AZ12 loaded in ' + CAST(@duration_ms AS VARCHAR) + ' ms';

        -- === ERP Location A101 ===
        PRINT '=== Loading ERP Location A101 ===';
        SET @start_step = SYSDATETIME();

        TRUNCATE TABLE bronze.erp_loc_a101;
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\ACER\Desktop\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_step = SYSDATETIME();
        SET @duration_ms = DATEDIFF(MILLISECOND, @start_step, @end_step);
        PRINT 'ERP Location A101 loaded in ' + CAST(@duration_ms AS VARCHAR) + ' ms';

        -- === ERP Product Category G1V2 ===
        PRINT '=== Loading ERP Product Category G1V2 ===';
        SET @start_step = SYSDATETIME();

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\ACER\Desktop\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_step = SYSDATETIME();
        SET @duration_ms = DATEDIFF(MILLISECOND, @start_step, @end_step);
        PRINT 'ERP Product Category G1V2 loaded in ' + CAST(@duration_ms AS VARCHAR) + ' ms';

        -- === Total Duration ===
        SET @end_step = SYSDATETIME();
        SET @duration_ms = DATEDIFF(MILLISECOND, @start_all, @end_step);
        PRINT '=== Bronze Layer Load Complete in ' + CAST(@duration_ms AS VARCHAR) + ' ms ===';

    END TRY
    BEGIN CATCH
        PRINT '=== ERROR OCCURRED DURING LOAD ===';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    END CATCH
END;
