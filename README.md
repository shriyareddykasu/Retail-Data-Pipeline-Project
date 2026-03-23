# Online Retail Sales & Customer Behavior Analysis
**An End-to-End Data Engineering and Analytics Project**

## 📌 Executive Summary
This project analyzes a dataset containing 541,909 transactions from a UK-based online retail store. The objective is to transform raw, unstructured transactional data into a cleaned database and eventually into a high-impact Power BI dashboard to drive business decision-making.

## 🛠️ Tech Stack
- **Database:** MySQL (Data Modeling & Heavy Querying)
- **Data Visualization:** Power BI (Planned)
- **Tooling:** GitHub for Version Control, MySQL Workbench

## 📂 Phase 1: Data Pipeline & Ingestion
In this phase, I established a robust ingestion process to migrate raw CSV data into a relational database.

### 1. Schema Design & Data Engineering
During the ingestion process, I identified critical data quality issues that prevented standard loading. I resolved these by:
* **Dynamic Typing:** Modified the schema to use `VARCHAR` for `Invoice` and `Customer ID` to accommodate alphanumeric prefixes (e.g., 'C' for cancellations) and handle missing/null customer data without crashing the pipeline.
* **Precision Parsing:** Utilized `OPTIONALLY ENCLOSED BY '"'` to correctly parse product descriptions containing internal commas, ensuring 100% column alignment.

### 2. Data Reconciliation (Verification)
To ensure data integrity, I performed a row-count reconciliation between the source file and the database.
* **Source Records:** 541,909
* **Database Records:** 541,910 (including header handling)
* **Reconciliation Status:** **Success**

---

## 🔍 Phase 2: Data Auditing & Cleaning
In this phase, I identified outliers and established cleaning parameters to ensure the accuracy of the final analysis.

**Key Cleaning Logic:**
- **Outlier Handling:** Identified extreme quantity values (±80,995) and non-standard pricing.
- **Data Filtering:** Created a SQL `VIEW` to isolate valid transactions by filtering out:
  - Negative quantities (Returns/Cancellations).
  - Zero/Negative prices (Adjustments/Gaps).
  - Null/Blank Customer IDs (to focus on identified customer behavior).
* **Inconsistent Data Handling:** Detected a 60/40 split in date formatting (YYYY-MM-DD vs. MM/DD/YY). 
* **Data Standardization:** Implemented a multi-step SQL transformation using `STR_TO_DATE` and conditional logic (`LIKE`) to unify 541k+ rows into a single `DATETIME` format without data loss.
