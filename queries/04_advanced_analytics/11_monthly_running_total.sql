-- ============================================================================
-- Query 11: Monthly Spending with Running Total
-- ============================================================================
-- Description: Calculates monthly spending per customer with cumulative running total
-- Purpose: Track spending trends and patterns over time
-- Author: Banking Risk Analytics Team
-- Created: 2023
-- ============================================================================

WITH bounds AS (
    SELECT DATEFROMPARTS(YEAR(MAX(date)), MONTH(MAX(date)), 1) AS last_month
    FROM banking.transactions
),
monthly AS (
    SELECT
        t.client_id,
        DATEFROMPARTS(YEAR(t.date), MONTH(t.date), 1) AS month_start,
        SUM(t.amount) AS monthly_spend
    FROM banking.transactions AS t
    CROSS JOIN bounds AS b
    WHERE t.amount > 0
      AND t.errors IS NULL
      AND t.date >= DATEADD(MONTH, -23, b.last_month)
    GROUP BY t.client_id, DATEFROMPARTS(YEAR(t.date), MONTH(t.date), 1)
)
SELECT
    client_id,
    FORMAT(month_start, 'yyyy-MM') AS year_month,
    CAST(monthly_spend AS DECIMAL(14, 2)) AS monthly_spend,
    CAST(
        SUM(monthly_spend) OVER (
            PARTITION BY client_id
            ORDER BY month_start
            ROWS UNBOUNDED PRECEDING
        ) AS DECIMAL(16, 2)
    ) AS cumulative_spend
FROM monthly
ORDER BY client_id, month_start;
