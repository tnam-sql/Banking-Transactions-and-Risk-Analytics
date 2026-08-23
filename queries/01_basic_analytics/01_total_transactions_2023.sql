-- ============================================================================
-- Query 01: Total Transactions in 2023
-- ============================================================================
-- Description: Counts the total number of transactions that occurred in 2023
-- Purpose: Basic transaction volume analysis for yearly reporting
-- Author: Banking Risk Analytics Team
-- Created: 2023
-- ============================================================================

SELECT 
    COUNT(*) AS TONG_SO_GD2023
FROM banking.transactions
WHERE date >= '2023-01-01' 
  AND date < '2024-01-01';
