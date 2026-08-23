-- ============================================================================
-- Query 15: State x Merchant Category Heatmap
-- ============================================================================
-- Description: Creates a heatmap of spending patterns across states and merchant categories
-- Purpose: Geographic and category-based spending analysis
-- Author: Banking Risk Analytics Team
-- Created: 2023
-- ============================================================================

WITH valid_tx AS (
    SELECT t.merchant_state, t.mcc, t.amount
    FROM banking.transactions AS t
    WHERE t.amount > 0
      AND t.errors IS NULL
      AND t.merchant_state IS NOT NULL
),
top_states AS (
    SELECT TOP (10) merchant_state
    FROM valid_tx
    GROUP BY merchant_state
    ORDER BY SUM(amount) DESC, merchant_state
),
top_categories AS (
    SELECT TOP (10) mcc
    FROM valid_tx
    GROUP BY mcc
    ORDER BY SUM(amount) DESC, mcc
)
SELECT
    v.merchant_state,
    m.description AS merchant_category,
    CAST(SUM(v.amount) AS DECIMAL(16, 2)) AS total_amount,
    COUNT(*) AS transaction_count
FROM valid_tx AS v
JOIN top_states AS s ON s.merchant_state = v.merchant_state
JOIN top_categories AS c ON c.mcc = v.mcc
JOIN banking.mcc_codes AS m ON m.mcc_id = v.mcc
GROUP BY v.merchant_state, m.description
ORDER BY v.merchant_state, total_amount DESC;
