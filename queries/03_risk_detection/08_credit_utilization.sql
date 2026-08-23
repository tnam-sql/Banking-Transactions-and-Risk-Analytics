-- ============================================================================
-- Query 08: Credit Card Utilization Rate (Last 30 Days)
-- ============================================================================
-- Description: Calculates credit utilization rate for each customer in the last 30 days
-- Purpose: Risk assessment and credit limit management
-- Author: Banking Risk Analytics Team
-- Created: 2023
-- ============================================================================

WITH bounds AS (
    SELECT MAX(date) AS last_ts FROM banking.transactions
),
credit_cards AS (
    SELECT c.id, c.client_id, c.credit_limit
    FROM banking.cards AS c
    WHERE c.card_type = 'Credit'
),
spend_30d AS (
    SELECT
        cc.client_id,
        SUM(t.amount) AS spend
    FROM credit_cards AS cc
    JOIN banking.transactions AS t ON t.card_id = cc.id
    CROSS JOIN bounds AS b
    WHERE t.amount > 0
      AND t.errors IS NULL
      AND t.date >= DATEADD(DAY, -30, b.last_ts)
    GROUP BY cc.client_id
),
limits AS (
    SELECT
        client_id,
        SUM(credit_limit) AS total_limit
    FROM credit_cards
    GROUP BY client_id
)
SELECT
    l.client_id,
    CAST(l.total_limit AS DECIMAL(14, 2)) AS total_credit_limit,
    CAST(ISNULL(s.spend, 0) AS DECIMAL(14, 2)) AS spend_last_30d,
    CAST(100.0 * ISNULL(s.spend, 0) / NULLIF(l.total_limit, 0) AS DECIMAL(6, 2)) AS utilization_pct
FROM limits AS l
LEFT JOIN spend_30d AS s ON s.client_id = l.client_id
ORDER BY utilization_pct DESC, l.client_id;
