-- ============================================================================
-- Query 02: Top 5 Merchant Cities by Transaction Volume
-- ============================================================================
-- Description: Identifies the top 5 cities with the highest transaction counts
-- Purpose: Geographic analysis of transaction distribution
-- Author: Banking Risk Analytics Team
-- Created: 2023
-- ============================================================================

SELECT TOP 5
    merchant_city,
    COUNT(*) AS LUONG_GD
FROM banking.transactions
WHERE merchant_city IS NOT NULL
GROUP BY merchant_city
ORDER BY LUONG_GD DESC;
