-- ======================================================================
-- PROJECT: End-to-End Online Retail Data Analysis
-- PHASE 1: Data Ingestion & Auditing
-- PHASE 2: Data Cleaning & Standardization
-- ======================================================================

-- ----------------------------------------------------------------------
-- STEP 1: DATABASE SETUP & DATA INGESTION
-- ----------------------------------------------------------------------
USE retail_project;

DROP TABLE IF EXISTS online_retail;
CREATE TABLE online_retail (
    Invoice VARCHAR(20),
    StockCode VARCHAR(20),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate VARCHAR(30),
    Price DECIMAL(10,2),
    `Customer ID` VARCHAR(20), -- Corrected name with space for initial import
    Country VARCHAR(50)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/online_retail_II.csv'
INTO TABLE online_retail
CHARACTER SET latin1
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ----------------------------------------------------------------------
-- STEP 2: DATA AUDITING (DETECTIVE WORK)
-- ----------------------------------------------------------------------
-- Checking boundaries for Price and Quantity
SELECT 
    MIN(Quantity) AS Min_Qty, MAX(Quantity) AS Max_Qty,
    MIN(Price) AS Min_Price, MAX(Price) AS Max_Price
FROM online_retail;

-- Finding non-product entries
SELECT DISTINCT Description 
FROM online_retail 
WHERE Description LIKE '%FEE%' OR Description LIKE '%ADJUST%';

-- ----------------------------------------------------------------------
-- STEP 3: DATA CLEANING & DATE STANDARDIZATION
-- ----------------------------------------------------------------------
-- Creating a view to fix dates and filter out "noise" (trash)
CREATE OR REPLACE VIEW clean_retail_sales AS
SELECT 
    Invoice, 
    StockCode, 
    Description, 
    Quantity, 
    -- Handling dual date formats: MM/DD/YY and YYYY-MM-DD
    CASE 
        WHEN InvoiceDate LIKE '%/%' THEN STR_TO_DATE(InvoiceDate, '%m/%d/%y %H:%i')
        ELSE STR_TO_DATE(InvoiceDate, '%Y-%m-%d %H:%i')
    END AS Cleaned_Date,
    Price, 
    `Customer ID`, 
    Country
FROM online_retail
WHERE Price > 0 
  AND `Customer ID` IS NOT NULL 
  AND `Customer ID` != ''
  AND Description NOT LIKE '%FEE%' 
  AND Description NOT LIKE '%ADJUST%';

-- ----------------------------------------------------------------------
-- STEP 4: BUSINESS INTELLIGENCE (ANALYSIS)
-- ----------------------------------------------------------------------

-- Q1: Top 5 Most Profitable Products
SELECT 
    Description, 
    SUM(Quantity * Price) AS Total_Revenue
FROM clean_retail_sales
GROUP BY Description
ORDER BY Total_Revenue DESC
LIMIT 5;

-- Q2: Time Analysis (Monthly Revenue Trends)
-- This query now uses the 'Cleaned_Date' to avoid NULL values
SELECT 
    MONTH(Cleaned_Date) AS Sales_Month, 
    SUM(Quantity * Price) AS Monthly_Revenue
FROM clean_retail_sales
GROUP BY MONTH(Cleaned_Date)
ORDER BY Monthly_Revenue DESC;

-- ======================================================================
-- END OF SCRIPT
-- ======================================================================
-- ----------------------------------------------------------------------
-- PHASE 3: ADVANCED BUSINESS INSIGHTS
-- ----------------------------------------------------------------------

-- 1. Customer Loyalty: Finding the "Whales" (Top 5 Spenders)
-- Logic: We group by ID and sum the total spend to find high-value clients.
SELECT 
    `Customer ID`, 
    SUM(Quantity * Price) AS Total_Spent
FROM clean_retail_sales
GROUP BY `Customer ID`
ORDER BY Total_Spent DESC
LIMIT 5;

-- 2. Product Popularity vs. Revenue
-- Why: To see which items are "Volume Drivers" (Sold a lot) 
-- vs "Revenue Drivers" (Made the most money).
SELECT 
    Description, 
    SUM(Quantity) AS Total_Units_Sold,
    SUM(Quantity * Price) AS Total_Revenue
FROM clean_retail_sales
GROUP BY Description
ORDER BY Total_Units_Sold DESC
LIMIT 10;
-- ======================================================================
-- END OF SCRIPT
-- ======================================================================


