-- ============================================================================
-- Query 03: Card Brand Market Share
-- ============================================================================
-- Description: Calculates the market share of each card brand/issuer
-- Purpose: Understanding card issuer distribution in the portfolio
-- Author: Banking Risk Analytics Team
-- Created: 2023
-- ============================================================================

SELECT 
    card_brand,
    COUNT(*) AS SOLUONG_THE,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5, 2)) AS THE_PTRAM
FROM banking.cards
GROUP BY card_brand
ORDER BY SOLUONG_THE;
