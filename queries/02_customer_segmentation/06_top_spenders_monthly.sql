-- ============================================================================
-- Query 06: Top 10 Monthly Spenders
-- ============================================================================
-- Description: Identifies the top 10 customers with highest monthly spending
-- Purpose: High-value customer identification and targeting
-- Author: Banking Risk Analytics Team
-- Created: 2023
-- ============================================================================

WITH tieu_hangthang AS (
    SELECT 
        client_id,
        DATEFROMPARTS(YEAR(date), MONTH(date), 1) AS month_start,
        SUM(amount) AS spend
    FROM banking.transactions 
    WHERE amount > 0
    GROUP BY client_id, DATEFROMPARTS(YEAR(date), MONTH(date), 1)
)
SELECT TOP 10
    client_id,
    FORMAT(month_start, 'yyyy-MM') AS year_month,
    CAST(spend AS DECIMAL(14, 2)) AS spends,
    gender,
    CAST(yearly_income AS DECIMAL(12, 2)) AS thunhap_nam
FROM tieu_hangthang AS tieu 
JOIN banking.users AS u ON u.id = tieu.client_id
ORDER BY spends DESC, client_id;
