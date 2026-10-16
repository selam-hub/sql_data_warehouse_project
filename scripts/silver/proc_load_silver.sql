
/*============================================================================================================
Stored procedure first Truncate silver layer table and then load data form Bronze to Silver layer
Usage: EXCUTE bronze.load_bronze
This SP does not accept any  parameter  or returns any value . 
===============================================================================================================*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time AS DATETIME, @end_time AS DATETIME, @start_batch_time AS DATETIME, @end_batch_time AS DATETIME
    BEGIN TRY
        /*---------------------------------------------------------------------------------------*/
        /*---------------------------------------------------------------------*/
        PRINT 'TIME TAKEN TO INSERTING Data into Silver layer ,silver.crm_cust_info'
        /*---------------------------------------------------------------------*/
        SET @start_batch_time = GETDATE();
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.crm_cust_info
        INSERT INTO silver.crm_cust_info(
                    cst_id,
                    cst_key,
                    cst_firstname,
                    cst_lastname,
                    cst_material_status,
                    cst_gndr,
                    cst_create_date
                    )
        SELECT 
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'single'
             WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'married'
             ELSE 'N/A'
        END cst_material_status,
        CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'femal'
             WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'male'
             ELSE 'N/A'
        END cst_gndr,
        cst_create_date
        FROM (
        SELECT *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as rn
        FROM bronze.crm_cust_info WHERE cst_id IS NOT NULL) t WHERE rn = 1;
        SET @end_time = GETDATE();
	PRINT'============================================================================================================';
        PRINT 'TOTAL TIME IT TAKES ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'Seconds'
	PRINT'============================================================================================================';

        /*---------------------------------------------------------------------*/
        PRINT 'INSERTING Data into Silver layer ,silver.crm_prd_info'
        /*---------------------------------------------------------------------*/
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.crm_prd_info
        INSERT INTO silver.crm_prd_info(
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
        )
        SELECT prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5) ,'-', '_') as cat_id,
        SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
        prd_nm,
        CASE WHEN prd_cost IS NULL THEN 0 ELSE prd_cost END prd_cost ,
        CASE UPPER(TRIM(prd_line)) 
             WHEN 'M' THEN 'Mountain'
             WHEN 'R' THEN 'Road'
             WHEN 'S' THEN 'Other Sales'
             WHEN 'T' THEN 'Touring'
             ELSE 'N/A'
        END AS prd_line,
        prd_start_dt,
        DATEADD(
            DAY, -1,
            LEAD(prd_start_dt) OVER (
                PARTITION BY prd_key
                ORDER BY prd_start_dt
            )
        ) AS prd_end_dt FROM bronze.crm_prd_info
        SET @end_time = GETDATE();
        PRINT'============================================================================================================';
        PRINT 'TOTAL TIME IT TAKES TO INSERT ' + CAST(DATEDIFF(SECOND ,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';
        PRINT'============================================================================================================';
        /*---------------------------------------------------------------------*/
       PRINT 'INSERTING Data into Silver layer ,silver.crm_sales_details'
        /*---------------------------------------------------------------------*/
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.crm_sales_details
        INSERT INTO silver.crm_sales_details(
        sls_ord_num ,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales, 
        sls_quantity,
        sls_price 
        )
        SELECT sls_ord_num ,
        sls_prd_key,
        sls_cust_id,
        CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS NVARCHAR) AS DATE)
        END AS sls_order_dt,
        CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS NVARCHAR) AS DATE)
        END AS sls_ship_dt,
        CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS NVARCHAR) AS DATE)
        END AS sls_due_dt,
        CASE WHEN sls_sales  IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales 
        END AS sls_sales,
        sls_quantity,
        CASE WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales /  NULLIF(sls_quantity ,0)
        ELSE sls_price
        END AS sls_price
        FROM bronze.crm_sales_details 
        PRINT'============================================================================================================';
        PRINT 'TOTAL TIME IT TAKES TO INSERT ' + CAST(DATEDIFF(SECOND ,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';
        PRINT'============================================================================================================';
  
        SET @end_time = GETDATE();
        /*---------------------------------------------------------------------*/
       PRINT 'INSERTING Data into Silver layer ,silver.erp_cust_az12'
        /*---------------------------------------------------------------------*/
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.erp_cust_az12
        INSERT INTO silver.erp_cust_az12(
        cid,
        bdate,
        gen 
        )
        SELECT 
        CASE WHEN cid like 'NAS%' THEN SUBSTRING(cid, 4, len(cid))
             ELSE cid
        END AS  cid,
        CASE WHEN bdate > GETDATE() THEN NULL
              ELSE bdate
        END AS bdate,
        CASE WHEN UPPER(trim(gen)) IN ('F','Female' ) THEN 'Female' 
             WHEN UPPER(trim(gen)) IN ('M', 'Male') THEN 'Male'
             ElSE 'N/A'
        END AS gen
        FROM bronze.erp_cust_az12
        SET @end_time = GETDATE();
        PRINT'============================================================================================================';
        PRINT 'TOTAL TIME IT TAKES TO INSERT ' + CAST(DATEDIFF(SECOND ,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';
        PRINT'============================================================================================================';
  
        /*---------------------------------------------------------------------*/
      PRINT 'INSERTING Data into Silver layer ,silver.erp_loc_a101'
        /*---------------------------------------------------------------------*/
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.erp_loc_a101
        INSERT INTO silver.erp_loc_a101(
        cid,
        cntry
        )
        SELECT 
        REPLACE (cid, '-', '') AS cid, 
        CASE WHEN TRIM(cntry) in ('USA', 'US', 'United States') THEN 'United States'
             WHEN TRIM(cntry) IS NULL OR cntry = '' THEN 'N/A'
             WHEN TRIM(cntry) = 'DE' THEN 'Germany'
             ELSE  TRIM(cntry) 
        END AS cntry
        FROM bronze.erp_loc_a101
        SET @end_time = GETDATE();
        PRINT'============================================================================================================';
        PRINT 'TOTAL TIME IT TAKES TO INSERT ' + CAST(DATEDIFF(SECOND ,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';
        PRINT'============================================================================================================';
  
        /*---------------------------------------------------------------------*/
        PRINT 'INSERTING Data into Silver layer ,silver.erp_px_cat_g1v2'
        /*---------------------------------------------------------------------*/
        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.erp_px_cat_g1v2
        INSERT INTO silver.erp_px_cat_g1v2(
        id ,
        cat,
        subcat,
        maintenance 
        )
        SELECT 
        id,
        trim(cat) as cat,
        trim(subcat) as subcat,
        trim(maintenance ) as maintenance
        FROM bronze.erp_px_cat_g1v2;
        SET @end_time = GETDATE();
        PRINT'============================================================================================================';
        PRINT 'TOTAL TIME IT TAKES TO INSERT ' + CAST(DATEDIFF(SECOND ,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';
        PRINT'============================================================================================================';
        SET @end_batch_time = GETDATE();
        PRINT'============================================================================================================';
        PRINT 'TOTAL BATCH TIME IT TAKES TO INSERT ' + CAST(DATEDIFF(SECOND ,@start_batch_time, @end_batch_time) AS NVARCHAR) + ' SECONDS';
        PRINT'============================================================================================================';
       
    END TRY
    BEGIN CATCH
        PRINT 'ERROR_MESSAGE ' + ERROR_MESSAGE() + 'THIS IS THE ERROR MESSAGE'
        PRINT 'ERROR_MESSAGE ' + ERROR_STATE() + 'THIS IS THE STATE'

    END CATCH
END
