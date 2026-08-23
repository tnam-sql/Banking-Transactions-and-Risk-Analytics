---Querry 1 :Tổng số giao dịch phát sinh trong năm 2023---
SELECT COUNT(*) AS TONG_SO_GD2023
FROM banking.transactions
WHERE DATE > =  '2023-01-01' AND DATE < '2024-01-01'

---Querr 2 :Top 5 địa điểm/thành phố có lượng giao dịch cao nhất---
SELECT TOP 5
merchant_city,
COUNT(*) AS LUONG_GD
FROM banking.transactions
WHERE merchant_city IS NOT NULL
GROUP BY merchant_city
ORDER BY LUONG_GD DESC

--Querry 3 : Phân khúc khách hàng theo Điểm tín dụng (Credit Score Bucketing)

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
ORDER BY CHIA_NHOM_CS

---Querry 4 :Thị phần của các hãng phát hành thẻ ---
SELECT 
	card_brand,
	COUNT(*) AS SOLUONG_THE,
	CAST(100.0*COUNT(*)/SUM(COUNT(*)) OVER () AS DECIMAL(5, 2)) AS THE_PTRAM
FROM banking.cards
GROUP BY card_brand
ORDER BY SOLUONG_THE

---Querry 5: Tỷ lệ giao dịch thất bại/lỗi---

SELECT 
	COUNT(*) AS LUONG_GD,
	SUM(CASE WHEN errors IS NOT NULL AND errors <> 'No Error' THEN 1 ELSE 0 END) AS GD_LOI,
	ROUND(
        SUM(CASE WHEN errors IS NOT NULL AND errors <> 'No Error' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS GD_LOI_PTRAM
FROM banking.transactions

---Querry 6 : Top 10 khách tiêu nhiều nhất trong 1 tháng---
WITH tieu_hangthang AS (
	SELECT 
		client_id,
		DATEFROMPARTS(YEAR(date),MONTH(DATE),1) AS month_start,
		sum(amount) AS spend
	FROM banking.transactions 
	WHERE amount > 0
	GROUP BY client_id,DATEFROMPARTS(YEAR(date),MONTH(DATE),1)
	)
SELECT TOP 10
	client_id,
	FORMAT(month_start,'YYYY-MM') AS year_month,
	CAST(spend AS decimal(14,2)) AS spends,
	gender,
	CAST(yearly_income AS decimal(12,2)) AS thunhap_nam
FROM tieu_hangthang AS tieu 
JOIN banking.users AS u
	on u.id = tieu.client_id
order by spends desc , client_id

---Querry 7 :  top 10 category merchant có khách chi tiêu nhiều nhất ---


SELECT TOP 10
		m.description as category_merchant,
		count(*) as giao_dich,
		cast(sum(amount) as decimal(14,2)) as chi_tieu
FROM banking.transactions as t
JOIN banking.mcc_codes as m
	on t.mcc  = m.mcc_id
where t.amount >  0
and t.errors IS NULL
GROUP BY m.description
order by chi_tieu desc 

---Querry 8 : tỷ lệ sử dụng hạn mức thẻ tín dụng của từng khách trong 30 ngày gần nhất---
WITH bounds AS (
  SELECT MAX(date) AS last_ts FROM banking.transactions
),
credit_cards AS (
  SELECT c.id, c.client_id, c.credit_limit
  FROM banking.cards AS c
  WHERE c.card_type = 'Credit'
),
spend_30d AS (
  SELECT
    cc.client_id,
    SUM(t.amount) AS spend
  FROM credit_cards AS cc
  JOIN banking.transactions AS t
    ON t.card_id = cc.id
  CROSS JOIN bounds AS b
  WHERE t.amount > 0
    AND t.errors IS NULL
    AND t.date >= DATEADD(DAY, -30, b.last_ts)
  GROUP BY cc.client_id
),

limits AS (
  SELECT
    client_id,
    sum(credit_limit) AS total_limit
  FROM credit_cards
  GROUP BY client_id
  )
SELECT
	 l.client_id,
  CAST(l.total_limit AS DECIMAL(14, 2)) AS total_credit_limit,
  CAST(ISNULL(s.spend, 0) AS DECIMAL(14, 2)) AS spend_last_30d,
  CAST(100.0 * ISNULL(s.spend, 0) / NULLIF(l.total_limit, 0) AS DECIMAL(6, 2)) AS utilization_pct
FROM limits AS l
LEFT JOIN spend_30d AS s
  ON s.client_id = l.client_id
ORDER BY utilization_pct DESC, l.client_id;
  
  --- Querry 9 :danh sách thẻ đã mở hơn 2 năm nhưng chưa từng có giao dịch nào ---
  WITH bounds AS (
  SELECT MAX(date) AS last_ts FROM banking.transactions
)
SELECT
  c.id AS card_id,
  c.client_id,
  c.card_brand,
  c.card_type,
  c.acct_open_date,
  CAST(c.credit_limit AS DECIMAL(14, 2)) AS credit_limit
FROM banking.cards AS c
CROSS JOIN bounds AS b
WHERE c.acct_open_date < DATEADD(YEAR, -2, b.last_ts)
  AND NOT EXISTS (
    SELECT 1
    FROM banking.transactions AS t
    WHERE t.card_id = c.id
  )
ORDER BY c.acct_open_date, c.id;

---Querry 10 :Fraud Signal - một ngày quẹt ở nhiều bang---
SELECT
	t.client_id,
	CAST(t.date AS DATE) as activity_date,
	COUNT(DISTINCT t.merchant_state) AS distinct_states,
	COUNT(*) as trans_count,
	CAST(SUM(t.amount) as DECIMAL(14,2)) AS total_amount
FROM banking.transactions AS t
WHERE t.merchant_state IS NOT NULL
GROUP BY t.client_id, CAST(t.date AS DATE)
HAVING COUNT(DISTINCT t.merchant_state) >= 3
ORDER BY distinct_states DESC, total_amount DESC, t.client_id;

---Querry 11 : chi tiêu hàng tháng + running total---
WITH bounds AS (
  SELECT DATEFROMPARTS(YEAR(MAX(date)), MONTH(MAX(date)), 1) AS last_month
  FROM banking.transactions
),
monthly AS (
  SELECT
    t.client_id,
    DATEFROMPARTS(YEAR(t.date), MONTH(t.date), 1) AS month_start,
    SUM(t.amount) AS monthly_spend
  FROM banking.transactions AS t
  CROSS JOIN bounds AS b
  WHERE t.amount > 0
    AND t.errors IS NULL
    AND t.date >= DATEADD(MONTH, -23, b.last_month)
  GROUP BY t.client_id, DATEFROMPARTS(YEAR(t.date), MONTH(t.date), 1)
)
SELECT
  client_id,
  FORMAT(month_start, 'yyyy-MM') AS year_month,
  CAST(monthly_spend AS DECIMAL(14, 2)) AS monthly_spend,
  CAST(
    SUM(monthly_spend) OVER (
      PARTITION BY client_id
      ORDER BY month_start
      ROWS UNBOUNDED PRECEDING
    ) AS DECIMAL(16, 2)
  ) AS cumulative_spend
FROM monthly
ORDER BY client_id, month_start;

---Querry 12 : tìm khách hàng có khoảng cách giữa 2 giao dịch liền kề dài hơn 30 ngày — dấu hiệu sắp churn---
WITH gaps AS (
  SELECT
    t.client_id,
    DATEDIFF(
      DAY,
      LAG(t.date) OVER (PARTITION BY t.client_id ORDER BY t.date),
      t.date
    ) AS gap_days
  FROM banking.transactions AS t
)
SELECT
  client_id,
  MAX(gap_days) AS longest_gap_days,
  COUNT(*) AS gaps_measured
FROM gaps
WHERE gap_days IS NOT NULL
GROUP BY client_id
HAVING MAX(gap_days) > 30
ORDER BY longest_gap_days DESC, client_id;

---Querry 13:Phát hiện giao dịch outline theo MCC---
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
JOIN thresholds AS th
  ON th.mcc = v.mcc
JOIN banking.mcc_codes AS m
  ON m.mcc_id = v.mcc
WHERE v.amount > th.p95_amount
ORDER BY times_median DESC, v.amount DESC;

---Querry 14 : Credit Score vs Spending Colleration
WITH monthly_spend AS (
  SELECT
    t.client_id,
    DATEFROMPARTS(YEAR(t.date), MONTH(t.date), 1) AS month_start,
    SUM(t.amount) AS spend
  FROM banking.transactions AS t
  WHERE t.amount > 0
    AND t.errors IS NULL
  GROUP BY t.client_id, DATEFROMPARTS(YEAR(t.date), MONTH(t.date), 1)
),
per_customer AS (
  SELECT
    client_id,
    AVG(spend) AS avg_monthly_spend
  FROM monthly_spend
  GROUP BY client_id
),
banded AS (
  SELECT
    u.id AS client_id,
    u.credit_score,
    u.yearly_income,
    p.avg_monthly_spend,
    NTILE(5) OVER (ORDER BY u.credit_score, u.id) AS score_quintile
  FROM banking.users AS u
  JOIN per_customer AS p
    ON p.client_id = u.id
)
SELECT
  score_quintile,
  MIN(credit_score) AS min_score,
  MAX(credit_score) AS max_score,
  COUNT(*) AS customers,
  CAST(AVG(avg_monthly_spend) AS DECIMAL(14, 2)) AS avg_monthly_spend,
  CAST(AVG(yearly_income) AS DECIMAL(14, 2)) AS avg_yearly_income
FROM banded
GROUP BY score_quintile
ORDER BY score_quintile;

---Querry 15 : heatmap state x category merchant
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
JOIN top_states AS s
  ON s.merchant_state = v.merchant_state
JOIN top_categories AS c
  ON c.mcc = v.mcc
JOIN banking.mcc_codes AS m
  ON m.mcc_id = v.mcc
GROUP BY v.merchant_state, m.description
ORDER BY v.merchant_state, total_amount DESC;