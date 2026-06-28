-- ============================================================
-- UPI TRANSACTIONS - DATA CLEANING
-- Author: Atharva
-- Dataset: 20,000 UPI Transaction Records | 20 Columns
-- Tool: SQL Server (SSMS)
-- ============================================================

-- -----------------------------------------------
-- STEP 1: Load & Preview Raw Data
-- -----------------------------------------------

SELECT TOP 10 * FROM UPI_Transactions;

-- Total record count
SELECT COUNT(*) AS TotalRecords FROM UPI_Transactions;
-- Expected: 20,000

-- -----------------------------------------------
-- STEP 2: Check Column Metadata
-- -----------------------------------------------

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'UPI_Transactions'
ORDER BY ORDINAL_POSITION;

-- -----------------------------------------------
-- STEP 3: Check for Duplicate Transaction IDs
-- -----------------------------------------------

SELECT 
    TransactionID,
    COUNT(*) AS Frequency
FROM UPI_Transactions
GROUP BY TransactionID
HAVING COUNT(*) > 1;
-- Result: 0 duplicates found — data is clean on this front

-- -----------------------------------------------
-- STEP 4: Check for NULL Values in All Columns
-- -----------------------------------------------

SELECT
    SUM(CASE WHEN TransactionID          IS NULL THEN 1 ELSE 0 END) AS Null_TransactionID,
    SUM(CASE WHEN TransactionDate        IS NULL THEN 1 ELSE 0 END) AS Null_TransactionDate,
    SUM(CASE WHEN Amount                 IS NULL THEN 1 ELSE 0 END) AS Null_Amount,
    SUM(CASE WHEN BankNameSent           IS NULL THEN 1 ELSE 0 END) AS Null_BankNameSent,
    SUM(CASE WHEN BankNameReceived       IS NULL THEN 1 ELSE 0 END) AS Null_BankNameReceived,
    SUM(CASE WHEN RemainingBalance       IS NULL THEN 1 ELSE 0 END) AS Null_RemainingBalance,
    SUM(CASE WHEN City                   IS NULL THEN 1 ELSE 0 END) AS Null_City,
    SUM(CASE WHEN Gender                 IS NULL THEN 1 ELSE 0 END) AS Null_Gender,
    SUM(CASE WHEN TransactionType        IS NULL THEN 1 ELSE 0 END) AS Null_TransactionType,
    SUM(CASE WHEN Status                 IS NULL THEN 1 ELSE 0 END) AS Null_Status,
    SUM(CASE WHEN TransactionTime        IS NULL THEN 1 ELSE 0 END) AS Null_TransactionTime,
    SUM(CASE WHEN DeviceType             IS NULL THEN 1 ELSE 0 END) AS Null_DeviceType,
    SUM(CASE WHEN PaymentMethod          IS NULL THEN 1 ELSE 0 END) AS Null_PaymentMethod,
    SUM(CASE WHEN MerchantName           IS NULL THEN 1 ELSE 0 END) AS Null_MerchantName,
    SUM(CASE WHEN Purpose                IS NULL THEN 1 ELSE 0 END) AS Null_Purpose,
    SUM(CASE WHEN CustomerAge            IS NULL THEN 1 ELSE 0 END) AS Null_CustomerAge,
    SUM(CASE WHEN PaymentMode            IS NULL THEN 1 ELSE 0 END) AS Null_PaymentMode,
    SUM(CASE WHEN Currency               IS NULL THEN 1 ELSE 0 END) AS Null_Currency,
    SUM(CASE WHEN CustomerAccountNumber  IS NULL THEN 1 ELSE 0 END) AS Null_CustomerAccount,
    SUM(CASE WHEN MerchantAccountNumber  IS NULL THEN 1 ELSE 0 END) AS Null_MerchantAccount
FROM UPI_Transactions;
-- Result: 0 NULLs across all 20 columns — dataset is complete

-- -----------------------------------------------
-- STEP 5: Check for Invalid Amounts
-- -----------------------------------------------

-- Zero or negative amounts
SELECT COUNT(*) AS ZeroOrNegativeAmounts
FROM UPI_Transactions
WHERE Amount <= 0;
-- Result: 0 invalid amounts

-- Amounts suspiciously small (< 1)
SELECT COUNT(*) AS TinyAmounts, MIN(Amount) AS MinAmount
FROM UPI_Transactions
WHERE Amount < 1;

-- -----------------------------------------------
-- STEP 6: Validate Status Column Values
-- -----------------------------------------------

SELECT Status, COUNT(*) AS Count
FROM UPI_Transactions
GROUP BY Status;
-- Expected: only 'Success' and 'Failed'
-- Success: 16,000 | Failed: 4,000

-- Check for case inconsistencies or trailing spaces
SELECT DISTINCT 
    Status,
    LEN(Status) AS Len,
    LEN(LTRIM(RTRIM(Status))) AS TrimmedLen
FROM UPI_Transactions;

-- Fix inconsistent casing if any (safe update)
UPDATE UPI_Transactions
SET Status = LTRIM(RTRIM(Status));

-- -----------------------------------------------
-- STEP 7: Validate Categorical Columns
-- -----------------------------------------------

-- Transaction Types
SELECT TransactionType, COUNT(*) AS Count FROM UPI_Transactions GROUP BY TransactionType;
-- Transfer: 10,000 | Payment: 10,000

-- Device Types
SELECT DeviceType, COUNT(*) AS Count FROM UPI_Transactions GROUP BY DeviceType;
-- Mobile, Tablet, Laptop — balanced distribution

-- Payment Methods
SELECT PaymentMethod, COUNT(*) AS Count FROM UPI_Transactions GROUP BY PaymentMethod;
-- Phone Number, QR Code, UPI ID — ~6,667 each

-- Payment Modes
SELECT PaymentMode, COUNT(*) AS Count FROM UPI_Transactions GROUP BY PaymentMode;
-- Instant: 10,000 | Scheduled: 10,000

-- Currencies
SELECT Currency, COUNT(*) AS Count FROM UPI_Transactions GROUP BY Currency;
-- USD, EUR, GBP, INR — 5,000 each

-- -----------------------------------------------
-- STEP 8: Validate Age Range
-- -----------------------------------------------

SELECT 
    MIN(CustomerAge) AS MinAge,
    MAX(CustomerAge) AS MaxAge,
    AVG(CustomerAge) AS AvgAge
FROM UPI_Transactions;
-- Range: 20–59 | Avg: 39.5 — realistic age range

-- -----------------------------------------------
-- STEP 9: Validate Date Range
-- -----------------------------------------------

SELECT 
    MIN(TransactionDate) AS EarliestDate,
    MAX(TransactionDate) AS LatestDate,
    COUNT(DISTINCT TransactionDate) AS UniqueDates
FROM UPI_Transactions;
-- Full year 2024: Jan 1 to Dec 30

-- -----------------------------------------------
-- STEP 10: Trim Whitespace on Text Columns
-- -----------------------------------------------

UPDATE UPI_Transactions
SET 
    BankNameSent     = LTRIM(RTRIM(BankNameSent)),
    BankNameReceived = LTRIM(RTRIM(BankNameReceived)),
    City             = LTRIM(RTRIM(City)),
    Gender           = LTRIM(RTRIM(Gender)),
    MerchantName     = LTRIM(RTRIM(MerchantName)),
    Purpose          = LTRIM(RTRIM(Purpose)),
    PaymentMethod    = LTRIM(RTRIM(PaymentMethod)),
    PaymentMode      = LTRIM(RTRIM(PaymentMode)),
    DeviceType       = LTRIM(RTRIM(DeviceType)),
    Currency         = LTRIM(RTRIM(Currency));

-- -----------------------------------------------
-- STEP 11: Add Derived Columns for Analysis
-- -----------------------------------------------

-- Add Month column for time-series analysis
ALTER TABLE UPI_Transactions ADD TransactionMonth VARCHAR(10);
UPDATE UPI_Transactions
SET TransactionMonth = FORMAT(TransactionDate, 'yyyy-MM');

-- Add Age Group bucket for demographic analysis
ALTER TABLE UPI_Transactions ADD AgeGroup VARCHAR(10);
UPDATE UPI_Transactions
SET AgeGroup = 
    CASE 
        WHEN CustomerAge BETWEEN 20 AND 29 THEN '20-29'
        WHEN CustomerAge BETWEEN 30 AND 39 THEN '30-39'
        WHEN CustomerAge BETWEEN 40 AND 49 THEN '40-49'
        WHEN CustomerAge BETWEEN 50 AND 59 THEN '50-59'
    END;

-- Add High Value Transaction flag (Amount > 1500)
ALTER TABLE UPI_Transactions ADD IsHighValue BIT;
UPDATE UPI_Transactions
SET IsHighValue = CASE WHEN Amount > 1500 THEN 1 ELSE 0 END;

-- -----------------------------------------------
-- STEP 12: Final Cleaned Data Verification
-- -----------------------------------------------

SELECT TOP 5 * FROM UPI_Transactions;
SELECT COUNT(*) AS FinalRowCount FROM UPI_Transactions;
-- All 20,000 rows retained — no data was dropped during cleaning
