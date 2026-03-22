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

-- 5. VERIFICATION
-- This should return exactly 541,910.
SELECT COUNT(*) AS Total_Rows_Loaded FROM online_retail;
