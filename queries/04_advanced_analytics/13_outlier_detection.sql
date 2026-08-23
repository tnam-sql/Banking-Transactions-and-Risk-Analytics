-- ============================================================================
-- Query 13: Outlier Detection by Merchant Category (MCC)
-- ============================================================================
-- Description: Detects transactions that exceed the 95th percentile for their MCC
-- Purpose: Identify potentially fraudulent or unusual transactions
-- Author: Banking Risk Analytics Team
-- Created: 2023
-- ============================================================================

WITH valid_tx AS (
    SELECT t.mcc, t.id, t.client_id, t.amount, t.date
    FROM banking.transactions AS t
    WHERE t.amount > 0
      AND t.errors IS NULL
),
thresholds AS (
    SELECT DISTINCT
        mcc,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount) OVER (PARTITION BY mcc) AS median_amount,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY amount) OVER (PARTITION BY mcc) AS p95_amount
    FROM valid_tx
)
SELECT
    m.description AS merchant_category,
    v.client_id,
    CAST(v.date AS DATE) AS tx_date,
    CAST(v.amount AS DECIMAL(14, 2)) AS amount,
    CAST(th.median_amount AS DECIMAL(14, 2)) AS median_amount,
    CAST(th.p95_amount AS DECIMAL(14, 2)) AS p95_amount,
    CAST(v.amount / NULLIF(th.median_amount, 0) AS DECIMAL(10, 2)) AS times_median
FROM valid_tx AS v
JOIN thresholds AS th ON th.mcc = v.mcc
JOIN banking.mcc_codes AS m ON m.mcc_id = v.mcc
WHERE v.amount > th.p95_amount
ORDER BY times_median DESC, v.amount DESC;
