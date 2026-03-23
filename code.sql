-- ======================================================================
-- PROJECT: End-to-End Online Retail Data Analysis
-- PHASE 1: DATA INGESTION (VERIFIED & RECONCILED)
-- ======================================================================

-- 1. DATABASE SETUP
USE retail_project;

-- 2. SCHEMA ADJUSTMENT 
-- We modified these to VARCHAR because the raw data contains letters 
-- in Invoices (e.g., 'C' for cancellations) and blanks in Customer IDs.
ALTER TABLE online_retail MODIFY COLUMN Invoice VARCHAR(20);
ALTER TABLE online_retail MODIFY COLUMN `Customer ID` VARCHAR(20);

-- 3. CLEAN START
-- Clearing the partial 32k load to prevent duplicates.
TRUNCATE TABLE online_retail;

-- 4. HIGH-INTEGRITY IMPORT
-- Using OPTIONALLY ENCLOSED BY to handle commas inside product descriptions.
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/online_retail_II.csv'
INTO TABLE online_retail
CHARACTER SET latin1
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
-- ======================================================================
-- PHASE 2: DATA CLEANING (CREATING A SALES VIEW)
-- ======================================================================
-- We create a VIEW to filter out 'trash' data without deleting it from the source.
-- Filters: Only positive quantities, prices > 0, and valid Customer IDs.

CREATE OR REPLACE VIEW cleaned_retail_data AS
SELECT *
FROM online_retail
WHERE Quantity > 0 
  AND Price > 0 
  AND `Customer ID` IS NOT NULL 
  AND `Customer ID` <> '';
-- 5. VERIFICATION
-- This should return exactly 541,910.
SELECT COUNT(*) AS Total_Rows_Loaded FROM online_retail;
-- ======================================================================
-- PHASE 2.2: HANDLING INCONSISTENT DATE FORMATS
-- ======================================================================
-- The dataset contained mixed formats (YYYY-MM-DD and MM/DD/YY).
-- We used a temporary column to standardize both formats before replacing the original.

-- 1. Create temporary holder
ALTER TABLE online_retail ADD COLUMN Temp_Date DATETIME;

-- 2. Standardize 'Dash' format (YYYY-MM-DD)
UPDATE online_retail 
SET Temp_Date = STR_TO_DATE(InvoiceDate, '%Y-%m-%d %H:%i')
WHERE InvoiceDate LIKE '%-%';

-- 3. Standardize 'Slash' format (MM/DD/YY)
UPDATE online_retail 
SET Temp_Date = STR_TO_DATE(InvoiceDate, '%m/%d/%y %H:%i')
WHERE InvoiceDate LIKE '%/%';

-- 4. Replace the old column with the cleaned version
ALTER TABLE online_retail DROP COLUMN InvoiceDate;
ALTER TABLE online_retail RENAME COLUMN Temp_Date TO InvoiceDate;

-- 5. Refresh the Cleaned View to use the new DATETIME column
CREATE OR REPLACE VIEW cleaned_retail_data AS
SELECT 
    Invoice, StockCode, Description, Quantity, 
    InvoiceDate, Price, `Customer ID`, Country
FROM online_retail
WHERE Quantity > 0 
  AND Price > 0 
  AND `Customer ID` IS NOT NULL 
  AND `Customer ID` <> '';
-- ======================================================================
-- PHASE 3: BUSINESS ANALYSIS
-- ======================================================================
-- 1. Top 10 Products by Revenue (Excluding non-product entries like Postage)
SELECT 
    Description, 
    SUM(Quantity) AS Total_Quantity_Sold, 
    SUM(Quantity * Price) AS Total_Revenue
FROM cleaned_retail_data
WHERE Description NOT LIKE '%POSTAGE%'
GROUP BY Description
ORDER BY Total_Revenue DESC
LIMIT 10;
-- 2. Top 10 Customers by Revenue and Order Frequency
SELECT 
    `Customer ID`, 
    COUNT(DISTINCT Invoice) AS Total_Orders, 
    SUM(Quantity * Price) AS Total_Spent
FROM cleaned_retail_data
GROUP BY `Customer ID`
ORDER BY Total_Spent DESC
LIMIT 10;
