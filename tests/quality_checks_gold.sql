/*
================================================================================
Gold Layer Data Quality Checks
--------------------------------------------------------------------------------
Purpose:
    Validate data quality and foreign key integrity in Gold Layer dimensions
    and fact tables.

Checks:
    - Gender consistency in gold.dim_customers.
    - Foreign key integrity in gold.fact_sales.

Warning:
    Review any returned records for missing or inconsistent dimension keys.

Example Execution:
    USE DataWarehouse2;
    GO
================================================================================
*/
-- Quality check dim_customers
SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info
		ELSE COALESCE(ca.gen, 'n/a')
	END new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
ORDER BY 1, 2

-- Quality check fact_sales
-- Foreign Key Integrity (dimensions)
SELECT * FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE s.product_key IS NULL
