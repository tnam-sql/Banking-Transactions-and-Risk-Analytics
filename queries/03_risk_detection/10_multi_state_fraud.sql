-- ============================================================================
-- Query 10: Multi-State Fraud Detection
-- ============================================================================
-- Description: Detects suspicious activity where a customer makes transactions 
--              in 3+ different states on the same day
-- Purpose: Fraud detection and security monitoring
-- Author: Banking Risk Analytics Team
-- Created: 2023
-- ============================================================================

SELECT
    t.client_id,
    CAST(t.date AS DATE) AS activity_date,
    COUNT(DISTINCT t.merchant_state) AS distinct_states,
    COUNT(*) AS trans_count,
    CAST(SUM(t.amount) AS DECIMAL(14, 2)) AS total_amount
FROM banking.transactions AS t
WHERE t.merchant_state IS NOT NULL
GROUP BY t.client_id, CAST(t.date AS DATE)
HAVING COUNT(DISTINCT t.merchant_state) >= 3
ORDER BY distinct_states DESC, total_amount DESC, t.client_id;
