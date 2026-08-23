# Query Documentation

This document provides detailed documentation for all 15 SQL queries in the Banking Risk Analytics project.

---

## Table of Contents

- [01. Basic Analytics](#01-basic-analytics)
- [02. Customer Segmentation](#02-customer-segmentation)
- [03. Risk Detection](#03-risk-detection)
- [04. Advanced Analytics](#04-advanced-analytics)

---

## 01. Basic Analytics

### Query 01: Total Transactions 2023

**File**: `queries/01_basic_analytics/01_total_transactions_2023.sql`

**Purpose**: Count all transactions that occurred in the calendar year 2023.

**Business Use Case**: 
- Yearly transaction volume reporting
- Baseline metric for year-over-year comparisons
- Input for annual performance dashboards

**Technical Details**:
- Filters transactions between `2023-01-01` and `2024-01-01`
- Simple COUNT aggregation
- Returns single value: `TONG_SO_GD2023`

**Output Schema**:
| Column | Type | Description |
|--------|------|-------------|
| TONG_SO_GD2023 | BIGINT | Total number of transactions in 2023 |

**Performance Notes**:
- Requires index on `date` column for optimal performance
- O(n) complexity with date filter

---

### Query 02: Top 5 Merchant Cities

**File**: `queries/01_basic_analytics/02_top_merchant_cities.sql`

**Purpose**: Identify the top 5 cities with the highest transaction volume.

**Business Use Case**:
- Geographic market analysis
- Regional business development planning
- Merchant partnership prioritization

**Technical Details**:
- Groups by `merchant_city`
- Filters NULL cities
- Orders by transaction count descending
- Returns top 5 results

**Output Schema**:
| Column | Type | Description |
|--------|------|-------------|
| merchant_city | VARCHAR | City name |
| LUONG_GD | BIGINT | Number of transactions |

**Performance Notes**:
- Requires index on `merchant_city` column
- GROUP BY operation on potentially large dataset

---

### Query 03: Card Brand Market Share

**File**: `queries/01_basic_analytics/03_card_brand_market_share.sql`

**Purpose**: Calculate market share distribution across card brands/issuers.

**Business Use Case**:
- Portfolio composition analysis
- Partnership negotiation insights
- Market positioning strategy

**Technical Details**:
- Groups by `card_brand`
- Uses window function for percentage calculation
- Handles division by zero with SUM() OVER()

**Output Schema**:
| Column | Type | Description |
|--------|------|-------------|
| card_brand | VARCHAR | Card issuer/brand name |
| SOLUONG_THE | BIGINT | Number of cards |
| THE_PTRAM | DECIMAL(5,2) | Percentage of total cards |

**Performance Notes**:
- Window function adds slight overhead
- Requires index on `card_brand` column

---

## 02. Customer Segmentation

### Query 04: Credit Score Bucketing

**File**: `queries/02_customer_segmentation/04_credit_score_bucketing.sql`

**Purpose**: Segment customers into standard credit score ranges with distribution percentages.

**Business Use Case**:
- Risk portfolio assessment
- Targeted marketing campaigns
- Credit limit adjustment decisions

**Technical Details**:
- Uses CASE statement for 5-tier bucketing:
  - Poor: < 580
  - Fair: 580-669
  - Good: 670-739
  - Very Good: 740-799
  - Excellent: 800+
- Calculates percentage using window function

**Output Schema**:
| Column | Type | Description |
|--------|------|-------------|
| CHIA_NHOM_CS | VARCHAR | Credit score category |
| TONG_KH | BIGINT | Number of customers |
| PHAN_TRAM | DECIMAL(5,2) | Percentage of total customers |

**Performance Notes**:
- CASE statement repeated in GROUP BY (required for SQL Server)
- Full table scan on users table

---

### Query 05: Transaction Failure Rate

**File**: `queries/02_customer_segmentation/05_transaction_failure_rate.sql`

**Purpose**: Calculate the percentage of transactions that failed or had errors.

**Business Use Case**:
- System health monitoring
- Payment gateway performance tracking
- Customer experience optimization

**Technical Details**:
- Counts total transactions
- Counts transactions with non-NULL, non-'No Error' errors
- Calculates percentage with 2 decimal precision

**Output Schema**:
| Column | Type | Description |
|--------|------|-------------|
| LUONG_GD | BIGINT | Total transactions |
| GD_LOI | BIGINT | Failed transactions |
| GD_LOI_PTRAM | DECIMAL(?,2) | Failure percentage |

**Performance Notes**:
- Single pass through transactions table
- CASE aggregation is efficient

---

### Query 06: Top Monthly Spenders

**File**: `queries/02_customer_segmentation/06_top_spenders_monthly.sql`

**Code**: Uses CTE to aggregate monthly spending, then joins with user demographics.

**Purpose**: Identify the top 10 customers by monthly spending with demographic context.

**Business Use Case**:
- VIP customer identification
- Personalized offer targeting
- Retention program prioritization

**Technical Details**:
- CTE `tieu_hangthang` aggregates spending by client_id and month
- Joins with users table for demographics
- Filters positive amounts only
- Returns top 10 by spend amount

**Output Schema**:
| Column | Type | Description |
|--------|------|-------------|
| client_id | INT | Customer identifier |
| year_month | VARCHAR | Month in YYYY-MM format |
| spends | DECIMAL(14,2) | Total monthly spend |
| gender | VARCHAR | Customer gender |
| thunhap_nam | DECIMAL(12,2) | Yearly income |

**Performance Notes**:
- Requires indexes on: transactions(client_id, date), users(id)
- CTE improves readability and performance

---

### Query 07: Top Merchant Categories

**File**: `queries/02_customer_segmentation/07_top_merchant_categories.sql`

**Purpose**: Identify top 10 merchant categories by total spending volume.

**Business Use Case**:
- Spending pattern analysis
- Category-based marketing
- Merchant category optimization

**Technical Details**:
- Joins transactions with MCC codes
- Filters positive amounts and successful transactions
- Groups by merchant category description
- Orders by total spend descending

**Output Schema**:
| Column | Type | Description |
|--------|------|-------------|
| category_merchant | VARCHAR | Merchant category description |
| giao_dich | BIGINT | Number of transactions |
| chi_tieu | DECIMAL(14,2) | Total spending amount |

**Performance Notes**:
- Requires join indexes on transactions.mcc and mcc_codes.mcc_id
- Large aggregation on filtered dataset

---

## 03. Risk Detection

### Query 08: Credit Utilization Rate

**File**: `queries/03_risk_detection/08_credit_utilization.sql`

**Purpose**: Calculate credit card utilization rate for each customer over the last 30 days.

**Business Use Case**:
- Credit risk assessment
- Limit increase decisions
- Over-limit alert configuration

**Technical Details**:
- Uses multiple CTEs for modular logic:
  - `bounds`: Gets latest transaction date
  - `credit_cards`: Filters for credit cards only
  - `spend_30d`: Aggregates last 30 days spending
  - `limits`: Sums credit limits per customer
- Calculates utilization as (spend / limit) * 100
- Handles NULL values and division by zero

**Output Schema**:
| Column | Type | Description |
|--------|------|-------------|
| client_id | INT | Customer identifier |
| total_credit_limit | DECIMAL(14,2) | Total available credit |
| spend_last_30d | DECIMAL(14,2) | Amount spent in last 30 days |
| utilization_pct | DECIMAL(6,2) | Credit utilization percentage |

**Performance Notes**:
- Complex query with multiple CTEs
- Requires indexes on: cards(card_type, client_id), transactions(card_id, date)
- Date range filter is critical for performance

---

### Query 09: Inactive Cards Detection

**File**: `queries/03_risk_detection/09_inactive_cards.sql`

**Purpose**: Identify cards opened more than 2 years ago with no transaction history.

**Business Use Case**:
- Dormant account management
- Cost reduction (close unused accounts)
- Fraud detection (never-used cards)

**Technical Details**:
- Uses CTE to get latest transaction date as reference
- Filters cards opened > 2 years ago
- Uses NOT EXISTS to check for any transactions
- Returns card details for review

**Output Schema**:
| Column | Type | Description |
|--------|------|-------------|
| card_id | INT | Card identifier |
| client_id | INT | Customer identifier |
| card_brand | VARCHAR | Card issuer |
| card_type | VARCHAR | Card type |
| acct_open_date | DATE | Account open date |
| credit_limit | DECIMAL(14,2) | Credit limit |

**Performance Notes**:
- NOT EXISTS is efficient with proper indexes
- Requires index on transactions(card_id)
- Date comparison uses dynamic reference point

---

### Query 10: Multi-State Fraud Detection

**File**: `queries/03_risk_detection/10_multi_state_fraud.sql`

**Purpose**: Detect suspicious activity where a customer makes transactions in 3+ different states on the same day.

**Business Use Case**:
- Real-time fraud alerting
- Security investigation prioritization
- Card blocking decisions

**Technical Details**:
- Groups by client_id and date
- Counts distinct merchant states
- Filters for >= 3 distinct states
- Aggregates transaction count and total amount

**Output Schema**:
| Column | Type | Description |
|--------|------|-------------|
| client_id | INT | Customer identifier |
| activity_date | DATE | Date of suspicious activity |
| distinct_states | INT | Number of different states |
| trans_count | BIGINT | Number of transactions |
| total_amount | DECIMAL(14,2) | Total transaction amount |

**Performance Notes**:
- Requires index on transactions(client_id, date, merchant_state)
- DISTINCT COUNT can be expensive on large datasets
- HAVING clause filters after aggregation

---

### Query 12: Churn Detection (Transaction Gaps)

**File**: `queries/03_risk_detection/12_churn_detection.sql`

**Purpose**: Identify customers with gaps > 30 days between consecutive transactions.

**Business Use Case**:
- Churn prediction modeling
- Retention campaign targeting
- Customer lifecycle management

**Technical Details**:
- Uses LAG window function to calculate gaps between consecutive transactions
- Partitions by client_id, ordered by date
- Calculates gap in days using DATEDIFF
- Filters for maximum gap > 30 days

**Output Schema**:
| Column | Type | Description |
|--------|------|-------------|
| client_id | INT | Customer identifier |
| longest_gap_days | INT | Longest gap between transactions |
| gaps_measured | BIGINT | Number of gaps analyzed |

**Performance Notes**:
- Window function requires sorting by date
- Requires index on transactions(client_id, date)
- Efficient for customers with regular transaction patterns

---

## 04. Advanced Analytics

### Query 11: Monthly Running Total

**File**: `queries/04_advanced_analytics/11_monthly_running_total.sql`

**Purpose**: Calculate monthly spending per customer with cumulative running total over 24 months.

**Business Use Case**:
- Spending trend analysis
- Budget tracking
- Annual spending projections

**Technical Details**:
- CTE `bounds` gets last month as reference point
- CTE `monthly` aggregates spending by month
- Uses window function with ROWS UNBOUNDED PRECEDING for running total
- Analyzes last 24 months of data

**Output Schema**:
| Column | Type | Description |
|--------|------|-------------|
| client_id | INT | Customer identifier |
| year_month | VARCHAR | Month in YYYY-MM format |
| monthly_spend | DECIMAL(14,2) | Spending for the month |
| cumulative_spend | DECIMAL(16,2) | Running total to date |

**Performance Notes**:
- Window function with frame specification
- Requires index on transactions(client_id, date)
- Date range filter limits data volume

---

### Query 13: Outlier Detection by MCC

**File**: `queries/04_advanced_analytics/13_outlier_detection.sql`

**Purpose**: Detect transactions exceeding the 95th percentile for their merchant category.

**Business Use Case**:
- Fraud detection (unusual spending patterns)
- Transaction review prioritization
- Anomaly investigation

**Technical Details**:
- CTE `valid_tx` filters valid transactions
- CTE `thresholds` calculates median and 95th percentile per MCC
- Uses PERCENTILE_CONT window function
- Joins with MCC codes for category descriptions
- Filters transactions > p95 threshold

**Output Schema**:
| Column | Type | Description |
|--------|------|-------------|
| merchant_category | VARCHAR | Merchant category description |
| client_id | INT | Customer identifier |
| tx_date | DATE | Transaction date |
| amount | DECIMAL(14,2) | Transaction amount |
| median_amount | DECIMAL(14,2) | Median for category |
| p95_amount | DECIMAL(14,2) | 95th percentile for category |
| times_median | DECIMAL(10,2) | Multiple of median |

**Performance Notes**:
- PERCENTILE_CONT is computationally expensive
- Requires index on transactions(mcc, amount)
- Consider materializing thresholds for large datasets

---

### Query 14: Credit Score vs Spending Correlation

**File**: `queries/04_advanced_analytics/14_credit_score_correlation.sql`

**Purpose**: Analyze correlation between credit scores and spending patterns using quintiles.

**Business Use Case**:
- Credit scoring model validation
- Risk-based pricing decisions
- Portfolio segmentation

**Technical Details**:
- CTE `monthly_spend` aggregates monthly spending
- CTE `per_customer` calculates average monthly spend per customer
- CTE `banded` joins with users and creates quintiles using NTILE
- Groups by quintile for aggregate statistics

**Output Schema**:
| Column | Type | Description |
|--------|------|-------------|
| score_quintile | INT | Quintile number (1-5) |
| min_score | INT | Minimum credit score in quintile |
| max_score | INT | Maximum credit score in quintile |
| customers | BIGINT | Number of customers |
| avg_monthly_spend | DECIMAL(14,2) | Average monthly spending |
| avg_yearly_income | DECIMAL(14,2) | Average yearly income |

**Performance Notes**:
- Multiple CTEs with joins
- NTILE requires sorting by credit_score
- Requires indexes on users(id, credit_score)

---

### Query 15: State x Category Heatmap

**File**: `queries/04_advanced_analytics/15_state_category_heatmap.sql`

**Purpose**: Create a heatmap matrix of spending patterns across top 10 states and top 10 merchant categories.

**Business Use Case**:
- Geographic spending analysis
- Category performance by region
- Market penetration analysis

**Technical Details**:
- CTE `valid_tx` filters valid transactions with state data
- CTE `top_states` identifies top 10 states by spend
- CTE `top_categories` identifies top 10 MCCs by spend
- Joins all CTEs to create intersection matrix
- Groups by state and category

**Output Schema**:
| Column | Type | Description |
|--------|------|-------------|
| merchant_state | VARCHAR | US state code |
| merchant_category | VARCHAR | Merchant category description |
| total_amount | DECIMAL(16,2) | Total spending |
| transaction_count | BIGINT | Number of transactions |

**Performance Notes**:
- Multiple CTEs with TOP 10 filters
- Requires indexes on transactions(merchant_state, mcc, amount)
- Efficient due to pre-filtering to top 10 in each dimension

---

## Performance Optimization Recommendations

### Index Strategy

1. **transactions table**:
   - `(date)` - for date range queries
   - `(client_id, date)` - for customer-level time series
   - `(card_id, date)` - for card-level analysis
   - `(mcc, amount)` - for category-based analytics
   - `(merchant_state, amount)` - for geographic analysis

2. **users table**:
   - `(id)` - primary key
   - `(credit_score)` - for segmentation

3. **cards table**:
   - `(id)` - primary key
   - `(client_id)` - for customer joins
   - `(card_type)` - for credit card filtering

4. **mcc_codes table**:
   - `(mcc_id)` - primary key

### Query Execution Tips

1. Use `SET STATISTICS IO ON` and `SET STATISTICS TIME ON` to analyze query performance
2. Consider materialized views for frequently run aggregations
3. Use query hints only when necessary after thorough testing
4. Monitor execution plans for missing index suggestions

---

## Data Quality Considerations

### Assumptions

1. All monetary values are in the same currency
2. Dates are in UTC or consistent timezone
3. NULL merchant_state indicates online/international transactions
4. Credit scores follow standard FICO ranges
5. Error codes are consistent across the dataset

### Known Limitations

1. Queries assume SQL Server 2019+ compatibility
2. Some queries may need adjustment for different database platforms
3. Large datasets may require partitioning strategies
4. Real-time fraud detection may need stored procedures

---

## Version History

- **v1.0** (2023): Initial release with 15 queries
- All queries optimized for SQL Server 2019+

---

## Contact

For questions or issues with these queries, please refer to the main project README or open an issue in the repository.
