/*
================================================================================
Stored Procedure: bronze.load_bronze
Description:
    This procedure handles the complete ETL execution for the 'Bronze' layer.
    It truncates existing data and uses BULK INSERT to ingest raw source CSV 
    files from both CRM and ERP systems into their designated staging tables.

Features & Controls:
    - Time Tracking: Utilizes datetime variables (@BATCH_START_TIME, @START_TIME, etc.)
                     to log precise pipeline and individual table execution durations.
    - Bulk Optimization: Uses the 'TABLOCK' hint during bulk ingestion to minimize 
                         transaction logging and speed up operations.
    - Error Handling: Wrapped inside a TRY...CATCH block to safely capture, 
                      print, and debug processing errors without breaking the flow.

Usage Example:
    To run the complete Bronze layer pipeline, execute the following command:
    
    EXEC bronze.load_bronze;
================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN 
    DECLARE @BATCH_START_TIME DATETIME, @BATCH_END_TIME DATETIME;
    DECLARE @START_TIME DATETIME, @END_TIME DATETIME;
    
    BEGIN TRY
        SET @BATCH_START_TIME = GETDATE();
        PRINT '===========================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '===========================================================';

        PRINT '-----------------------------------------------------------';
        PRINT 'Loading CRM Tables'
        PRINT '-----------------------------------------------------------';

        SET @START_TIME = GETDATE ();
        PRINT '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;
        PRINT '>> Inserting Data Into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );
        SET @END_TIME = GETDATE ();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @START_TIME, @END_TIME) AS NVARCHAR) + ' Seconds';
        PRINT '>>-------------';

        SET @START_TIME = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;
        PRINT '>> Inserting Data Into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );
        SET @END_TIME = GETDATE ();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @START_TIME, @END_TIME) AS NVARCHAR) + ' Seconds';
        PRINT '>> ------------';

        SET @START_TIME = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;
        PRINT '>> Inserting Data Into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );
        SET @END_TIME = GETDATE ();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @START_TIME, @END_TIME) AS NVARCHAR) + ' Seconds';
        PRINT '>> ------------';

        PRINT '-----------------------------------------------------------';
        PRINT 'Loading ERP Tables'
        PRINT '-----------------------------------------------------------';
        
        SET @START_TIME = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;
        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );
        SET @END_TIME = GETDATE ();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @START_TIME, @END_TIME) AS NVARCHAR) + ' Seconds';
        PRINT '>> ------------';
        
        SET @START_TIME = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;
        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @END_TIME = GETDATE ();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @START_TIME, @END_TIME) AS NVARCHAR) + ' Seconds';
        PRINT '>> ------------';

        SET @START_TIME = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2'; 
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK 
        );
        SET @END_TIME = GETDATE ();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(Second, @START_TIME, @END_TIME) AS NVARCHAR) + ' Seconds';
        PRINT '>> ------------';
        
        SET @BATCH_END_TIME = GETDATE();
        PRINT '===========================================================';
        PRINT 'Bronze Layer Loaded Successfully!';
        PRINT 'Total Batch Duration: ' + CAST(DATEDIFF(Second, @BATCH_START_TIME, @BATCH_END_TIME) AS NVARCHAR) + ' Seconds';
        PRINT '===========================================================';

    END TRY
    BEGIN CATCH
        PRINT '============================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '============================================';
    END CATCH
END
