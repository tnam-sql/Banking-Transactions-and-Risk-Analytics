-- ============================================================================
-- Query 07: Top 10 Merchant Categories by Spending
-- ============================================================================
-- Description: Identifies top merchant categories where customers spend the most
-- Purpose: Understanding customer spending patterns and preferences
-- Author: Banking Risk Analytics Team
-- Created: 2023
-- ============================================================================

SELECT TOP 10
    m.description AS category_merchant,
    COUNT(*) AS giao_dich,
    CAST(SUM(amount) AS DECIMAL(14, 2)) AS chi_tieu
FROM banking.transactions AS t
JOIN banking.mcc_codes AS m ON t.mcc = m.mcc_id
WHERE t.amount > 0
  AND t.errors IS NULL
GROUP BY m.description
ORDER BY chi_tieu DESC;
