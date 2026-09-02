/*
================================================================================
Gold Layer Dimension & Fact Views
--------------------------------------------------------------------------------
Purpose:
    Create Gold Layer views for customer and product dimensions,
    and the sales fact table for reporting and analytics.

Warning:
    Views depend on the Silver Layer tables and existing Gold Layer views.

================================================================================
*/

CREATE OR ALTER VIEW gold.dim_customers AS 
SELECT
	ROW_NUMBER() OVER(ORDER BY ci.cst_id) customer_key,
	ci.cst_id customer_id,
	ci.cst_key customer_number,
	ci.cst_firstname first_name,
	ci.cst_lastname last_name,
	la.cntry country,
	ci.cst_marital_status marital_status,
	CASE
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info
		ELSE COALESCE(ca.gen, 'n/a')
	END gender,
	ca.bdate birthdate,
	ci.cst_create_date create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid;

GO

CREATE OR ALTER VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER(ORDER BY pin.prd_start_dt, pin.prd_key) product_key,
	pin.prd_id product_id,
	pin.prd_key product_number,
	pin.prd_nm product_name,
	pin.cat_id category_id,
	pc.cat category,
	pc.subcat subcategory,
	pc.maintenance,
	pin.prd_cost cost,
	pin.prd_line product_line,
	pin.prd_start_dt start_date
FROM silver.crm_prd_info pin
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pin.cat_id = pc.id
WHERE prd_end_dt IS NULL -- Filter out all historical data

GO

CREATE OR ALTER VIEW gold.fact_sales AS
SELECT 
	sls_ord_num order_number,
	c.customer_key,
	p.product_key,
	sls_order_dt order_date,
	sls_ship_dt shipping_date,
	sls_due_dt due_date,
	sls_sales sales_amount,
	sls_quantity quantity,
	sls_price price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_customers c
ON sd.sls_cust_id = c.customer_id
LEFT JOIN gold.dim_products p
ON sd.sls_prd_key = p.product_number
