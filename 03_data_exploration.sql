-- ============================================================
-- UPI TRANSACTIONS - DATA EXPLORATION & BUSINESS QUERIES
-- Author: Atharva
-- Dataset: 20,000 UPI Transaction Records | Year 2024
-- Tool: SQL Server (SSMS)
-- ============================================================

-- -----------------------------------------------
-- Q1: Overall KPI Summary
-- -----------------------------------------------

SELECT
    COUNT(*)                                                        AS Total_Transactions,
    ROUND(SUM(Amount), 2)                                           AS Total_Amount,
    ROUND(AVG(Amount), 2)                                           AS Avg_Transaction_Value,
    ROUND(MAX(Amount), 2)                                           AS Max_Amount,
    ROUND(MIN(Amount), 2)                                           AS Min_Amount,
    SUM(CASE WHEN Status = 'Success' THEN 1 ELSE 0 END)            AS Successful_Transactions,
    SUM(CASE WHEN Status = 'Failed'  THEN 1 ELSE 0 END)            AS Failed_Transactions,
    ROUND(SUM(CASE WHEN Status = 'Failed' THEN Amount ELSE 0 END), 2) AS Total_Failed_Amount
FROM UPI_Transactions;

/*
RESULT:
Total_Transactions : 20,000
Total_Amount       : 19,872,274.03
Avg_Value          : 993.61
Max_Amount         : 1,999.87
Min_Amount         : 0.05
Successful         : 16,000
Failed             : 4,000
Failed_Amount      : 3,996,787.08
*/

-- -----------------------------------------------
-- Q2: Success vs Failure Rate
-- -----------------------------------------------

SELECT
    Status,
    COUNT(*)                                                AS Count,
    ROUND(SUM(Amount), 2)                                   AS Total_Amount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)      AS Percentage
FROM UPI_Transactions
GROUP BY Status;

/*
RESULT:
Success → 16,000 txns (80%) → ₹15,875,486.95
Failed  →  4,000 txns (20%) →  ₹3,996,787.08
*/

-- -----------------------------------------------
-- Q3: Monthly Transaction Trend (2024)
-- -----------------------------------------------

SELECT
    FORMAT(TransactionDate, 'yyyy-MM')          AS Month,
    COUNT(*)                                    AS Transactions,
    ROUND(SUM(Amount), 2)                       AS Total_Amount,
    ROUND(AVG(Amount), 2)                       AS Avg_Amount
FROM UPI_Transactions
GROUP BY FORMAT(TransactionDate, 'yyyy-MM')
ORDER BY Month;

/*
INSIGHT: Consistent ~1,667 transactions/month throughout 2024.
Peak amount: May 2024 (₹17,06,785). 
Lowest:  August 2024 (₹15,98,708).
*/

-- -----------------------------------------------
-- Q4: Transaction Volume & Value by City
-- -----------------------------------------------

SELECT
    City,
    COUNT(*)                    AS Total_Transactions,
    ROUND(SUM(Amount), 2)       AS Total_Amount,
    ROUND(AVG(Amount), 2)       AS Avg_Amount,
    SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) AS Failed_Count
FROM UPI_Transactions
GROUP BY City
ORDER BY Total_Amount DESC;

/*
RESULT:
Mumbai    → ₹50,52,564 | Avg: ₹1,010.51
Delhi     → ₹50,36,738 | Avg: ₹1,007.35
Hyderabad → ₹49,07,634 | Avg: ₹981.53
Bangalore → ₹48,75,336 | Avg: ₹975.07
*/

-- -----------------------------------------------
-- Q5: Transactions by Purpose
-- -----------------------------------------------

SELECT
    Purpose,
    COUNT(*)                AS Total_Transactions,
    ROUND(SUM(Amount), 2)  AS Total_Amount,
    ROUND(AVG(Amount), 2)  AS Avg_Amount
FROM UPI_Transactions
GROUP BY Purpose
ORDER BY Total_Amount DESC;

/*
RESULT:
Travel       → ₹39,98,155 | Avg ₹999.54 (highest avg spend)
Shopping     → ₹39,96,787 | Avg ₹999.20
Others       → ₹39,86,338 | Avg ₹996.58
Bill Payment → ₹39,45,853 | Avg ₹986.46
Food         → ₹39,45,138 | Avg ₹986.28 (lowest avg spend)
*/

-- -----------------------------------------------
-- Q6: Payment Method Performance
-- -----------------------------------------------

SELECT
    PaymentMethod,
    COUNT(*)                                                        AS Total_Transactions,
    ROUND(SUM(Amount), 2)                                           AS Total_Amount,
    SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END)             AS Failed_Count,
    ROUND(SUM(CASE WHEN Status = 'Failed' THEN 1.0 ELSE 0 END)
          / COUNT(*) * 100, 2)                                      AS Failure_Rate_Pct
FROM UPI_Transactions
GROUP BY PaymentMethod
ORDER BY Failure_Rate_Pct DESC;

-- -----------------------------------------------
-- Q7: Device Type Analysis
-- -----------------------------------------------

SELECT
    DeviceType,
    COUNT(*)                AS Total_Transactions,
    ROUND(SUM(Amount), 2)  AS Total_Amount,
    ROUND(AVG(Amount), 2)  AS Avg_Amount,
    SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) AS Failed_Count
FROM UPI_Transactions
GROUP BY DeviceType
ORDER BY Total_Amount DESC;

-- -----------------------------------------------
-- Q8: Instant vs Scheduled Payment Mode
-- -----------------------------------------------

SELECT
    PaymentMode,
    COUNT(*)                AS Total_Transactions,
    ROUND(SUM(Amount), 2)  AS Total_Amount,
    ROUND(AVG(Amount), 2)  AS Avg_Amount,
    SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) AS Failed_Transactions
FROM UPI_Transactions
GROUP BY PaymentMode;

/*
RESULT:
Instant   → 10,000 txns | ₹99,27,901 | Avg ₹992.79
Scheduled → 10,000 txns | ₹99,44,372 | Avg ₹994.44
*/

-- -----------------------------------------------
-- Q9: Bank-wise Sending Analysis
-- -----------------------------------------------

SELECT
    BankNameSent,
    COUNT(*)                                                        AS Total_Sent,
    ROUND(SUM(Amount), 2)                                           AS Total_Amount_Sent,
    ROUND(AVG(Amount), 2)                                           AS Avg_Amount,
    SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END)             AS Failed_Count,
    ROUND(SUM(CASE WHEN Status = 'Failed' THEN 1.0 ELSE 0 END)
          / COUNT(*) * 100, 2)                                      AS Failure_Rate_Pct
FROM UPI_Transactions
GROUP BY BankNameSent
ORDER BY Total_Amount_Sent DESC;

/*
INSIGHT: All 4 banks (SBI, HDFC, ICICI, Axis) have identical 20% failure rate.
Each bank handled exactly 5,000 transactions — perfectly balanced dataset.
*/

-- -----------------------------------------------
-- Q10: Gender-wise Spending Pattern
-- -----------------------------------------------

SELECT
    Gender,
    COUNT(*)                AS Total_Transactions,
    ROUND(SUM(Amount), 2)  AS Total_Amount,
    ROUND(AVG(Amount), 2)  AS Avg_Amount
FROM UPI_Transactions
GROUP BY Gender;

-- -----------------------------------------------
-- Q11: Age Group Analysis
-- -----------------------------------------------

SELECT
    CASE 
        WHEN CustomerAge BETWEEN 20 AND 29 THEN '20-29'
        WHEN CustomerAge BETWEEN 30 AND 39 THEN '30-39'
        WHEN CustomerAge BETWEEN 40 AND 49 THEN '40-49'
        WHEN CustomerAge BETWEEN 50 AND 59 THEN '50-59'
    END                     AS AgeGroup,
    COUNT(*)                AS Total_Transactions,
    ROUND(AVG(Amount), 2)  AS Avg_Transaction_Value,
    ROUND(SUM(Amount), 2)  AS Total_Amount
FROM UPI_Transactions
GROUP BY 
    CASE 
        WHEN CustomerAge BETWEEN 20 AND 29 THEN '20-29'
        WHEN CustomerAge BETWEEN 30 AND 39 THEN '30-39'
        WHEN CustomerAge BETWEEN 40 AND 49 THEN '40-49'
        WHEN CustomerAge BETWEEN 50 AND 59 THEN '50-59'
    END
ORDER BY AgeGroup;

/*
RESULT:
20-29 → Avg ₹985.49 (lowest spenders)
30-39 → Avg ₹996.81
40-49 → Avg ₹1,002.17 (highest spenders — peak earning years)
50-59 → Avg ₹989.99
*/

-- -----------------------------------------------
-- Q12: Top Merchants by Transaction Value
-- -----------------------------------------------

SELECT
    MerchantName,
    COUNT(*)                AS Total_Transactions,
    ROUND(SUM(Amount), 2)  AS Total_Revenue,
    ROUND(AVG(Amount), 2)  AS Avg_Order_Value,
    SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) AS Failed_Payments
FROM UPI_Transactions
GROUP BY MerchantName
ORDER BY Total_Revenue DESC;

/*
RESULT:
IRCTC    → ₹39,98,155 (Travel — highest revenue)
Flipkart → ₹39,96,787 (Shopping)
Amazon   → ₹39,86,338 (Others/Shopping)
Swiggy   → ₹39,45,853 (Food/Bill Pay)
Zomato   → ₹39,45,138 (Food — lowest)
*/

-- -----------------------------------------------
-- Q13: High Value Transaction Analysis (Amount > 1500)
-- -----------------------------------------------

SELECT
    COUNT(*)                                            AS High_Value_Count,
    ROUND(SUM(Amount), 2)                               AS High_Value_Total,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM UPI_Transactions), 2) AS Pct_of_Transactions,
    ROUND(SUM(Amount) * 100.0 / (SELECT SUM(Amount) FROM UPI_Transactions), 2) AS Pct_of_Total_Amount
FROM UPI_Transactions
WHERE Amount > 1500;

/*
RESULT:
4,940 high-value transactions (24.7% of count)
contribute ₹86,44,375 (43.5% of total value)
*/

-- -----------------------------------------------
-- Q14: Currency Distribution
-- -----------------------------------------------

SELECT
    Currency,
    COUNT(*)                AS Total_Transactions,
    ROUND(SUM(Amount), 2)  AS Total_Amount,
    ROUND(AVG(Amount), 2)  AS Avg_Amount
FROM UPI_Transactions
GROUP BY Currency
ORDER BY Total_Amount DESC;

-- -----------------------------------------------
-- Q15: Failure Analysis — Failed Transactions by Purpose
-- -----------------------------------------------

SELECT
    Purpose,
    SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END)             AS Failed_Count,
    ROUND(SUM(CASE WHEN Status = 'Failed' THEN Amount ELSE 0 END), 2) AS Failed_Amount,
    ROUND(SUM(CASE WHEN Status = 'Failed' THEN 1.0 ELSE 0 END)
          / COUNT(*) * 100, 2)                                      AS Failure_Rate_Pct
FROM UPI_Transactions
GROUP BY Purpose
ORDER BY Failed_Amount DESC;
