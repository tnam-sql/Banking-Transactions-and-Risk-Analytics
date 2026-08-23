-- ============================================================================
-- Query 05: Transaction Failure/Error Rate
-- ============================================================================
-- Description: Calculates the percentage of failed or errored transactions
-- Purpose: System performance and transaction quality monitoring
-- Author: Banking Risk Analytics Team
-- Created: 2023
-- ============================================================================

SELECT 
    COUNT(*) AS LUONG_GD,
    SUM(CASE WHEN errors IS NOT NULL AND errors <> 'No Error' THEN 1 ELSE 0 END) AS GD_LOI,
    ROUND(
        SUM(CASE WHEN errors IS NOT NULL AND errors <> 'No Error' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS GD_LOI_PTRAM
FROM banking.transactions;
