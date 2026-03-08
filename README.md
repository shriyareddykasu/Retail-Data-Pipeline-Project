# 🛒 End-to-End Retail Data Analysis Pipeline
**Tech Stack:** MySQL, SQL Workbench, [Future: Power BI]

## 📌 Project Overview
This project involves building a full data pipeline to analyze a retail dataset containing over 540,000 transactions. The goal was to transform raw, "dirty" data into actionable business insights regarding sales performance and customer behavior.

## 🛠️ Phase 1: Data Engineering & Ingestion
- **Challenge:** The dataset was too large for standard import wizards and contained encoding errors.
- **Solution:** Used professional `LOAD DATA INFILE` scripts with `latin1` character sets to bypass security and formatting blocks.
- **Audit:** Conducted a "Boundary Test" using `MIN/MAX` to identify negative quantities and administrative fees.

## 🧹 Phase 2: Data Cleaning (The "Clean Room" Approach)
Instead of deleting data, I created a **SQL View** (`clean_retail_sales`) to filter out:
- Transactions with a Price of $0 (System tests/promotions).
- Administrative entries (Amazon Fees, Bad Debt adjustments).
- Anonymous transactions (Missing Customer IDs).
- **Date Standardization:** Handled multiple date formats using `STR_TO_DATE` and `CASE` logic to ensure 100% data accuracy.

## 📊 Business Key Findings
- **Top Product:** The 'REGENCY CAKESTAND 3 TIER' is the leading revenue driver ($21,000+).
- **Peak Season:** December is the most profitable month, generating over **$569,000** in revenue—nearly triple the amount of the second-highest month. This highlights a heavy reliance on holiday shopping trends.
- **Data Integrity:** Resolved a critical date-formatting issue that was causing $209,000 in sales to be misclassified as "NULL."
