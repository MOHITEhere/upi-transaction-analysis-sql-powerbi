# UPI Transactions — Data Insights Report
**Dataset:** 20,000 UPI Transaction Records | **Period:** January–December 2024  
**Author:** Atharva | **Tool:** SQL Server + Power BI

---

## Dataset Overview

| Metric | Value |
|---|---|
| Total Records | 20,000 |
| Total Columns | 20 |
| Time Period | Jan 2024 – Dec 2024 |
| Total Transaction Value | ₹1,98,72,274 |
| Average Transaction Value | ₹993.61 |
| Null Values | 0 (clean dataset) |
| Duplicate Transactions | 0 |

---

## Insight 1 — 1 in 5 Transactions Fails, Losing ₹40 Lakh

**20% of all transactions (4,000 out of 20,000) failed**, resulting in ₹39,96,787 in unprocessed value.

- Success: 16,000 transactions → ₹1,58,75,487
- Failed: 4,000 transactions → ₹39,96,787 blocked

> **Business Impact:** A 20% failure rate is significantly high for a UPI platform. Industry benchmarks target below 1%. This warrants immediate investigation into infrastructure and network reliability.

---

## Insight 2 — Mumbai and Delhi Lead in Transaction Value

City-wise breakdown reveals a clear north-south divide in spending power:

| City | Total Amount | Avg Per Transaction |
|---|---|---|
| Mumbai | ₹50,52,565 | ₹1,010.51 |
| Delhi | ₹50,36,739 | ₹1,007.35 |
| Hyderabad | ₹49,07,634 | ₹981.53 |
| Bangalore | ₹48,75,336 | ₹975.07 |

> **Business Impact:** Mumbai and Delhi users spend ~3.6% more per transaction than Bangalore users. Marketing and cashback campaigns should prioritise these cities for maximum ROI.

---

## Insight 3 — Travel Generates the Highest Average Spend

Purpose-wise analysis shows Travel has the highest average transaction value:

| Purpose | Total Amount | Avg Amount |
|---|---|---|
| Travel | ₹39,98,156 | ₹999.54 |
| Shopping | ₹39,96,787 | ₹999.20 |
| Others | ₹39,86,339 | ₹996.58 |
| Bill Payment | ₹39,45,854 | ₹986.46 |
| Food | ₹39,45,139 | ₹986.28 |

> **Business Impact:** IRCTC (travel) and Flipkart (shopping) drive the highest revenue per transaction. Partnerships or reward points for these categories would encourage repeat high-value usage.

---

## Insight 4 — 40–49 Age Group Spends the Most

Spending power peaks in the 40–49 age bracket — users in their prime earning years:

| Age Group | Avg Transaction |
|---|---|
| 20–29 | ₹985.49 |
| 30–39 | ₹996.81 |
| **40–49** | **₹1,002.17** ← Highest |
| 50–59 | ₹989.99 |

> **Business Impact:** While younger users (20–29) transact frequently, the 40–49 group transacts with the highest value. Premium product features and investment-related payment options should target this segment.

---

## Insight 5 — High Value Transactions (>₹1,500) Contribute 43.5% of Total Revenue

Only 24.7% of transactions are high-value (>₹1,500), yet they contribute nearly **half of all revenue**:

| Metric | Value |
|---|---|
| High Value Count | 4,940 (24.7%) |
| High Value Total | ₹86,44,375 |
| % of Total Revenue | **43.5%** |

> **Business Impact:** Protecting and nurturing this 24.7% of users is critical. Priority customer support, zero-failure SLA, and loyalty rewards for high-value users would significantly retain revenue.

---

## Insight 6 — All Banks Show Equal 20% Failure Rate

Every bank in the dataset has an identical 20% failure rate — a pattern that strongly suggests the failures are **platform-side, not bank-side**:

| Bank | Transactions | Failure Rate |
|---|---|---|
| SBI Bank | 5,000 | 20.0% |
| HDFC Bank | 5,000 | 20.0% |
| ICICI Bank | 5,000 | 20.0% |
| Axis Bank | 5,000 | 20.0% |

> **Business Impact:** Since all banks fail at the same rate, the bottleneck is the UPI platform itself — possibly timeout handling, server load, or transaction routing logic. The fix is on the infrastructure side, not the banking integration.

---

## Insight 7 — Instant vs Scheduled Payments Are Nearly Equal

| Payment Mode | Count | Total Amount | Avg Amount |
|---|---|---|---|
| Instant | 10,000 | ₹99,27,901 | ₹992.79 |
| Scheduled | 10,000 | ₹99,44,372 | ₹994.44 |

> **Business Impact:** Scheduled payments have a marginally higher average (₹1.65 more). This suggests scheduled payments are used for slightly larger, planned transactions like EMIs or bill payments.

---

## Insight 8 — Payment Methods Are Evenly Distributed

| Method | Count |
|---|---|
| Phone Number | 6,667 |
| QR Code | 6,667 |
| UPI ID | 6,666 |

> **Business Impact:** No single payment method dominates, indicating the user base is diverse in its UPI literacy. QR Code adoption at 33% suggests strong merchant ecosystem penetration.

---

## Insight 9 — Device Usage Is Balanced Across Mobile, Tablet, Laptop

| Device | Count |
|---|---|
| Tablet | 6,667 |
| Laptop | 6,667 |
| Mobile | 6,666 |

> **Business Impact:** The almost equal split across devices is unusual — typically 80%+ of UPI transactions happen on mobile. This dataset may represent a B2B or enterprise UPI use case in addition to consumer transactions.

---

## Insight 10 — Dataset Has Zero Data Quality Issues

| Check | Result |
|---|---|
| Null values | 0 |
| Duplicate Transaction IDs | 0 |
| Negative amounts | 0 |
| Zero amounts | 0 |
| Invalid date range | 0 |
| Inconsistent categories | 0 |

> **Conclusion:** The dataset is production-ready with no cleaning required beyond whitespace trimming. All categorical columns are consistent and balanced.

---

## Summary for Stakeholders

| Area | Finding | Recommendation |
|---|---|---|
| Reliability | 20% failure rate = ₹40L lost | Audit platform infrastructure |
| Geography | Mumbai & Delhi highest spenders | Focus marketing in metro cities |
| Demographics | Age 40–49 highest value users | Create premium tier for this group |
| Revenue | Top 25% of txns = 43.5% revenue | Protect high-value users with priority service |
| Merchants | IRCTC & Flipkart top earners | Expand merchant partnerships in travel & e-commerce |
| Payments | All methods equally adopted | Maintain multi-method UPI support |
