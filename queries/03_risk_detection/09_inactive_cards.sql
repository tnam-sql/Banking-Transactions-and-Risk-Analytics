-- ============================================================================
-- Query 09: Inactive Cards (Opened > 2 Years, No Transactions)
-- ============================================================================
-- Description: Lists cards opened more than 2 years ago with no transaction history
-- Purpose: Identify dormant accounts for potential closure or reactivation
-- Author: Banking Risk Analytics Team
-- Created: 2023
-- ============================================================================

WITH bounds AS (
    SELECT MAX(date) AS last_ts FROM banking.transactions
)
SELECT
    c.id AS card_id,
    c.client_id,
    c.card_brand,
    c.card_type,
    c.acct_open_date,
    CAST(c.credit_limit AS DECIMAL(14, 2)) AS credit_limit
FROM banking.cards AS c
CROSS JOIN bounds AS b
WHERE c.acct_open_date < DATEADD(YEAR, -2, b.last_ts)
  AND NOT EXISTS (
    SELECT 1
    FROM banking.transactions AS t
    WHERE t.card_id = c.id
  )
ORDER BY c.acct_open_date, c.id;
