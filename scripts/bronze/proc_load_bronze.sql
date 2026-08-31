/*
================================================================================
Bronze Layer Data Loading Procedure
--------------------------------------------------------------------------------
Script Purpose:
    Create or alter the stored procedure [bronze].[load_bronze] to load raw
    data from CRM and ERP CSV source files into the Bronze Layer tables.

    The procedure performs the following operations:
        1. Truncate existing data from Bronze Layer tables.
        2. Bulk insert data from CRM and ERP CSV files.
        3. Track the loading duration for each table.
        4. Track the total loading duration for the entire Bronze Layer.
        5. Display loading progress and error information.

Warning:
    This procedure uses TRUNCATE TABLE before loading new data. All existing
    data in the Bronze Layer tables will be permanently removed and replaced
    with data from the source CSV files.

    The BULK INSERT file paths are local to the SQL Server environment.
    Make sure the SQL Server service account has permission to access the
    specified directories and files.

How to Run:
    Execute the stored procedure after it has been created:

        EXEC bronze.load_bronze; 
        OR
        EXECUTE bronze.load_bronze;

Expected Result:
    The procedure will display the loading progress, duration for each table,
    total loading duration, and any error information encountered during
    the loading process.

================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	
	BEGIN TRY
		
		PRINT '================================================================'
		PRINT 'Loading Bronze Layer'
		PRINT '================================================================'

		PRINT '----------------------------------------------------------------'
		PRINT 'Loading CRM Tables'
		PRINT '----------------------------------------------------------------'
		SET @batch_start_time = GETDATE()

		-- BULK INSERT bronze.crm_cust_info
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Insert Data into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\edlym\Videos\Data with bara\SQL COURSES VIDEO\FILES\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR= ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------------------------------'

		-- BULK INSERT bronze.crm_prd_info
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Insert Data into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\edlym\Videos\Data with bara\SQL COURSES VIDEO\FILES\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR= ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------------------------------'


		-- BULK INSERT bronze.crm_sales_details
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Insert Data into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\edlym\Videos\Data with bara\SQL COURSES VIDEO\FILES\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR= ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------------------------------'

		PRINT '----------------------------------------------------------------'
		PRINT 'Loading ERP Tables'
		PRINT '----------------------------------------------------------------'

		-- BULK INSERT bronze.erp_cust_az12
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Insert Data into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\edlym\Videos\Data with bara\SQL COURSES VIDEO\FILES\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR= ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------------------------------'


		-- BULK INSERT bronze.erp_loc_a101
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Insert Data into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\edlym\Videos\Data with bara\SQL COURSES VIDEO\FILES\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR= ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------------------------------'


		-- BULK INSERT bronze.erp_px_cat_g1v2
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Insert Data into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\edlym\Videos\Data with bara\SQL COURSES VIDEO\FILES\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR= ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------------------------------'

		SET @batch_end_time = GETDATE()
		PRINT '================================================================';
		PRINT 'Loading Bronze Layer is Completed';
		PRINT '>> Total Whole Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '================================================================';
	END TRY

	BEGIN CATCH
		PRINT '================================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message ' +  ERROR_MESSAGE();
		PRINT 'Error Number ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '================================================================';
	END CATCH
END
