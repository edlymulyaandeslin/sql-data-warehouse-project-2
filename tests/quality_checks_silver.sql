/*
================================================================================
Bronze to Silver Data Quality Checks
--------------------------------------------------------------------------------
Purpose:
    Validate CRM & ERP data quality before loading into the Silver Layer.

Warning:
    Review and fix any returned records before running the Silver load process.

Example Execution:
    Run this script in the DataWarehouse2 database.
================================================================================
*/

/*
	DATA QUALITY CHECK 
	From: bronze.crm_cust_info
	To: silver.crm_cust_info
*/
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- Check for unwanted Spaces
-- Expectation: No Results
SELECT
cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname !=  TRIM(cst_firstname)

-- Data Standarization & Consistency
-- Expectation: No Results
SELECT DISTINCT
cst_gndr
FROM bronze.crm_cust_info


/*
	DATA QUALITY CHECK 
	From: bronze.crm_prd_info
	To: silver.crm_prd_info
*/

-- Check NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
	prd_id,
	COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check unwanted spaces
-- Expectation: No Results
SELECT
prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for NULLs or Negative Numbers
-- Expectation: No Results
SELECT
prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Data Standarization & Consistency
SELECT DISTINCT
prd_line	
FROM bronze.crm_prd_info

-- Check for Invalid Date Orders
SELECT
	prd_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt,
	DATEADD(DAY, -1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)) new_end_dt
FROM bronze.crm_prd_info
WHERE prd_key IN ('CO-RF-FR-R92R-52', 'CL-JE-LJ-0192-X')


/*
	DATA QUALITY CHECK 
	From: bronze.crm_sales_details
	To: silver.crm_sales_details
*/

-- Check unwanted spaces
-- Expectation: No Results
SELECT
sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- Check for Invalid Dates
SELECT
NULLIF(sls_due_dt, 0)
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
OR LEN(sls_due_dt) != 8
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101

-- Check for Invalid Date Orders
SELECT
sls_order_dt,
sls_ship_dt,
sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check data consistency: between sales, quantity, and price
-- >> sales = quantity * price
-- >> values must not be NULL, zero, or negative.
SELECT DISTINCT
sls_sales old_sales,
sls_quantity,
sls_price old_price,
CASE
	WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END sls_sales,
CASE
	WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
	ELSE sls_price
END sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price 


/*
	DATA QUALITY CHECK 
	From: bronze.erp_cust_az12
	To: silver.erp_cust_az12
*/

-- Identify Out-of-range Dates
SELECT DISTINCT
bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data standarization and consistency
SELECT DISTINCT
gen
FROM bronze.erp_cust_az12


/*
	DATA QUALITY CHECK 
	From: bronze.erp_loc_a101
	To: silver.erp_loc_a101
*/

-- Data standarization and consistency
SELECT DISTINCT
cntry old_cntry,
CASE
	WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
	ELSE TRIM(cntry)
END cntry
FROM bronze.erp_loc_a101
ORDER BY cntry


/*
	DATA QUALITY CHECK 
	From: bronze.erp_px_cat_g1v2
	To: silver.erp_px_cat_g1v2
*/

-- Check unwanted spaces
SELECT
*
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data standarization and consistency
SELECT DISTINCT
cat
FROM bronze.erp_px_cat_g1v2
