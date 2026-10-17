/*========================================================================*/
/*VIEW gold.dim_customer*/
/*======================================================================*/

CREATE VIEW gold.dim_customer AS
SELECT 
ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
la.cntry AS country,
ci.cst_material_status AS martial_status,
ca.bdate AS birthday,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
     ELSE coalesce(ca.gen, 'n/a')
END gender ,
ci.cst_create_date AS created_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
/*======================================================================*/
/*VIEW  gold.dim_product*/
/*======================================================================*/
CREATE VIEW  gold.dim_product AS
SELECT 
row_number() over (order by pd.prd_key, pd.prd_start_dt) AS product_key,
pd.prd_id AS product_id,
pd.prd_key AS product_number ,
pd.prd_nm AS product_name,
pd.cat_id AS catagory_id,
pc.cat AS catagory_name,
pc.subcat AS subcatagory_name,
pc.maintenance ,
pd.prd_cost AS cost,
pd.prd_line AS product_line,
pd.prd_start_dt AS satrt_date
FROM silver.crm_prd_info AS pd
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pd.cat_id = pc.id
WHERE prd_end_dt IS NULL

/*======================================================================*/
/*VIEW gold.fact_sales*/
/*======================================================================*/

CREATE VIEW gold.fact_sales AS
select
sd.sls_ord_num AS order_number,
pr.product_key ,
cu.customerkey ,
sd.sls_order_dt AS order_date, 
sd.sls_ship_dt AS shiping_date,
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales_amount,
sd.sls_quantity AS quantity,
sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_product AS pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customer AS cu
ON sd.sls_cust_id = cu.customer_id
