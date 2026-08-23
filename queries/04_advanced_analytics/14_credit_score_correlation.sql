-- ============================================================================
-- Query 14: Credit Score vs Spending Correlation Analysis
-- ============================================================================
-- Description: Analyzes correlation between credit scores and spending patterns
-- Purpose: Understand relationship between creditworthiness and spending behavior
-- Author: Banking Risk Analytics Team
-- Created: 2023
-- ============================================================================

WITH monthly_spend AS (
    SELECT
        t.client_id,
        DATEFROMPARTS(YEAR(t.date), MONTH(t.date), 1) AS month_start,
        SUM(t.amount) AS spend
    FROM banking.transactions AS t
    WHERE t.amount > 0
      AND t.errors IS NULL
    GROUP BY t.client_id, DATEFROMPARTS(YEAR(t.date), MONTH(t.date), 1)
),
per_customer AS (
    SELECT
        client_id,
        AVG(spend) AS avg_monthly_spend
    FROM monthly_spend
    GROUP BY client_id
),
banded AS (
    SELECT
        u.id AS client_id,
        u.credit_score,
        u.yearly_income,
        p.avg_monthly_spend,
        NTILE(5) OVER (ORDER BY u.credit_score, u.id) AS score_quintile
    FROM banking.users AS u
    JOIN per_customer AS p ON p.client_id = u.id
)
SELECT
    score_quintile,
    MIN(credit_score) AS min_score,
    MAX(credit_score) AS max_score,
    COUNT(*) AS customers,
    CAST(AVG(avg_monthly_spend) AS DECIMAL(14, 2)) AS avg_monthly_spend,
    CAST(AVG(yearly_income) AS DECIMAL(14, 2)) AS avg_yearly_income
FROM banded
GROUP BY score_quintile
ORDER BY score_quintile;
