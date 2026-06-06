/*
=====================================================================
Quality Checks
=====================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schema. It includes checks for:
    - Null or duplicate primary keys
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
=====================================================================
*/

-- ======================================================
-- CRM CUSTOMER CHECKS
-- ======================================================

-- Check for NULL or duplicate customer IDs
SELECT
cst_id,
COUNT(*) AS cnt
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING cst_id IS NULL
OR COUNT(*) > 1;

-- Check for unwanted spaces in customer names
SELECT *
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
OR cst_lastname != TRIM(cst_lastname);

-- Check standardized marital status and gender values
SELECT DISTINCT
cst_marital_status,
cst_gndr
FROM silver.crm_cust_info;

-- ======================================================
-- CRM PRODUCT CHECKS
-- ======================================================

-- Check duplicate product keys (historical records expected)
SELECT
prd_key,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_key
HAVING COUNT(*) > 1;

-- Check only one active version exists per product
SELECT
prd_key,
COUNT(*)
FROM silver.crm_prd_info
WHERE prd_end_dt IS NULL
GROUP BY prd_key
HAVING COUNT(*) > 1;

-- Check negative product cost
SELECT *
FROM silver.crm_prd_info
WHERE prd_cost < 0;

-- Check standardized product categories
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- ======================================================
-- CRM SALES CHECKS
-- ======================================================

-- Validate order → ship → due date sequence
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
OR sls_ship_dt > sls_due_dt;

-- Validate Sales = Quantity × Price
-- Values must not be NULL, zero, or negative
SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales <= 0
OR sls_quantity <= 0
OR sls_price <= 0;

-- ======================================================
-- ERP CUSTOMER CHECKS
-- ======================================================

-- Check for future birth dates
SELECT *
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();

-- Check gender standardization
SELECT DISTINCT gen
FROM silver.erp_cust_az12;

-- ======================================================
-- ERP LOCATION CHECKS
-- ======================================================

-- Check standardized country values
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ======================================================
-- ERP PRODUCT CATEGORY CHECKS
-- ======================================================

-- Check for NULL IDs or categories
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE id IS NULL
OR cat IS NULL;
