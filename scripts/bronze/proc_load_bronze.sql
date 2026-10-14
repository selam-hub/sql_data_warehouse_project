/*
====================================================================================================
SP load data form source system csv files (ERP & CMR) to bronze layer.
======================================================================================================
Here we truncate bronze table befor load and bulk load the data in to each tables 
This Stored Procedure does not accept any parameter or returns any value.
This SP does not accept any  parameter  or returns any value . 
Usage: EXCUTE bronze.load_bronze
=======================================================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @start_batch_time DATETIME, @end_batch_time DATETIME;
		
	BEGIN TRY
		SET @start_batch_time = GETDATE();
		PRINT '=====================================================================================';
		PRINT 'LODING IN BRONZE LAYER';
		PRINT '=====================================================================================';

		PRINT '-------------------------------------------------------------------------------------';
		PRINT 'LOADING CRM TABLE';
		PRINT '-------------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>TRANCATING THE TABLE bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;	
		PRINT '>>INSERTING THE DATA INTO bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\selam\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
		WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>>LOAD DURATION: ' + CAST (DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';
		PRINT'--------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '>>TRANCATING THE TABLE bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>>INSERTING THE DATA INTO bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info 
		FROM 'C:\Users\selam\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
		WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOADING DURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' SECONDS';
		PRINT '---------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '>>TRANCATING THE TABLE bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;	
		PRINT '>>INSERTING THE DATA INTO bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\selam\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
		WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';

		PRINT '-------------------------------------------------------------------------------------';
		PRINT 'LOADING ERP TABLE';
		PRINT '-------------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>TRANCATING THE TABLE bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT '>>INSERTING THE DATA INTO bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\selam\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
		WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@start_time, @end_time )AS NVARCHAR) + 'SECONDS';
		PRINT'--------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '>>TRANCATING THE TABLE bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT '>>INSERTING THE DATA INTO bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\selam\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\loc_a101.csv'
		WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(SECOND,@start_time, @end_time ) AS NVARCHAR) + 'SECONDS';
		PRINT'----------------------------------------------------------'

		SET @start_time = GETDATE();
		PRINT '>>TRANCATING THE TABLE bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT '>>INSERTING THE DATA INTO bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\selam\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_time,@end_time ) AS NVARCHAR)+ 'SECONDS';
		PRINT '--------------------------------------------'
	
	PRINT'============================================================================================================';
	SET @end_batch_time = GETDATE();
	PRINT 'BRONZE LAYER LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @start_batch_time, @end_batch_time) AS NVARCHAR) + 'SECONDS';
	PRINT'============================================================================================================';

	END TRY
	BEGIN CATCH
		PRINT '===============================================================';
		PRINT 'ERROR OCCURED DURING BRONZE LOAD'
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR MESSAGE' + CAST(ERROR_NUMBER()AS NVARCHAR) ;
		PRINT 'ERROR MESSAGE' + CAST(ERROR_STATE()AS NVARCHAR) ;
		PRINT '===============================================================';
		THROW;
	END CATCH
END;
