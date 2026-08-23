-- ============================================================================
-- Query 04: Credit Score Bucketing (Customer Segmentation)
-- ============================================================================
-- Description: Segments customers into credit score ranges with percentages
-- Purpose: Customer risk profiling and portfolio analysis
-- Author: Banking Risk Analytics Team
-- Created: 2023
-- ============================================================================

SELECT
    CASE
        WHEN credit_score < 580 THEN '1.Poor(<580)'
        WHEN credit_score BETWEEN 580 AND 669 THEN '2.Fair(580-669)'
        WHEN credit_score BETWEEN 670 AND 739 THEN '3.Good(670-739)'
        WHEN credit_score BETWEEN 740 AND 799 THEN '4.Very Good(740-799)'
        ELSE '5.Excellent(800+)'
    END AS CHIA_NHOM_CS,
    COUNT(*) AS TONG_KH,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5, 2)) AS PHAN_TRAM
FROM banking.users
GROUP BY 
    CASE
        WHEN credit_score < 580 THEN '1.Poor(<580)'
        WHEN credit_score BETWEEN 580 AND 669 THEN '2.Fair(580-669)'
        WHEN credit_score BETWEEN 670 AND 739 THEN '3.Good(670-739)'
        WHEN credit_score BETWEEN 740 AND 799 THEN '4.Very Good(740-799)'
        ELSE '5.Excellent(800+)'
    END 
ORDER BY CHIA_NHOM_CS;
