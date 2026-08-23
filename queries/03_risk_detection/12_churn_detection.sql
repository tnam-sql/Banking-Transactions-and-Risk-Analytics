-- ============================================================================
-- Query 12: Customer Churn Detection (Transaction Gaps)
-- ============================================================================
-- Description: Identifies customers with gaps > 30 days between consecutive transactions
-- Purpose: Early warning system for customer churn
-- Author: Banking Risk Analytics Team
-- Created: 2023
-- ============================================================================

WITH gaps AS (
    SELECT
        t.client_id,
        DATEDIFF(
            DAY,
            LAG(t.date) OVER (PARTITION BY t.client_id ORDER BY t.date),
            t.date
        ) AS gap_days
    FROM banking.transactions AS t
)
SELECT
    client_id,
    MAX(gap_days) AS longest_gap_days,
    COUNT(*) AS gaps_measured
FROM gaps
WHERE gap_days IS NOT NULL
GROUP BY client_id
HAVING MAX(gap_days) > 30
ORDER BY longest_gap_days DESC, client_id;
