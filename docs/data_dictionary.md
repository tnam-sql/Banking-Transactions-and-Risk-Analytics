# Data Dictionary

This document provides detailed information about the data structures used in the Banking Risk Analytics project.

---

## Table of Contents

- [Database Schema Overview](#database-schema-overview)
- [Table Definitions](#table-definitions)
- [Field Descriptions](#field-descriptions)
- [Relationships](#relationships)
- [Data Quality Rules](#data-quality-rules)

---

## Database Schema Overview

The project uses four main tables in the `banking` schema:

1. **banking.transactions** - Transaction records
2. **banking.users** - Customer information
3. **banking.cards** - Card details and limits
4. **banking.mcc_codes** - Merchant category codes

---

## Table Definitions

### banking.transactions

**Purpose**: Stores all transaction records including successful and failed transactions.

**Primary Key**: `id`

**Indexes**:
- `idx_date` on `date`
- `idx_client_date` on `(client_id, date)`
- `idx_card_date` on `(card_id, date)`
- `idx_mcc_amount` on `(mcc, amount)`
- `idx_state_amount` on `(merchant_state, amount)`

**Record Count**: ~1M+ records

---

### banking.users

**Purpose**: Stores customer demographic and financial information.

**Primary Key**: `id`

**Indexes**:
- `idx_credit_score` on `credit_score`

**Record Count**: ~10K+ records

---

### banking.cards

**Purpose**: Stores card details including credit limits and card types.

**Primary Key**: `id`

**Indexes**:
- `idx_client_id` on `client_id`
- `idx_card_type` on `card_type`

**Record Count**: ~5K+ records

---

### banking.mcc_codes

**Purpose**: Reference table for Merchant Category Codes (MCC).

**Primary Key**: `mcc_id`

**Record Count**: ~100+ records

---

## Field Descriptions

### banking.transactions

| Field | Type | Nullable | Description | Example |
|-------|------|----------|-------------|---------|
| id | BIGINT | NO | Unique transaction identifier | 123456789 |
| date | DATETIME | NO | Transaction timestamp | 2023-06-15 14:30:00 |
| client_id | INT | NO | Foreign key to users table | 1001 |
| card_id | INT | NO | Foreign key to cards table | 5001 |
| amount | DECIMAL(14,2) | NO | Transaction amount (positive = debit, negative = credit) | 150.00 |
| mcc | INT | YES | Merchant Category Code | 5411 |
| merchant_city | VARCHAR(100) | YES | City where transaction occurred | New York |
| merchant_state | VARCHAR(2) | YES | State code (US) or country code | NY |
| errors | VARCHAR(255) | YES | Error message if transaction failed | 'Insufficient funds' or 'No Error' |

**Notes**:
- `amount` can be negative for refunds/credits
- `errors` = 'No Error' or NULL indicates successful transaction
- `merchant_state` is NULL for online/international transactions
- `mcc` references the mcc_codes table

---

### banking.users

| Field | Type | Nullable | Description | Example |
|-------|------|----------|-------------|---------|
| id | INT | NO | Unique customer identifier | 1001 |
| credit_score | INT | NO | Credit score (typically 300-850) | 720 |
| yearly_income | DECIMAL(12,2) | NO | Annual income in USD | 75000.00 |
| gender | VARCHAR(10) | YES | Customer gender | 'Male', 'Female' |
| birth_date | DATE | YES | Date of birth | 1985-03-15 |

**Notes**:
- `credit_score` follows FICO scoring model (300-850 range)
- `yearly_income` is gross annual income
- Gender field may be NULL depending on data collection policies

---

### banking.cards

| Field | Type | Nullable | Description | Example |
|-------|------|----------|-------------|---------|
| id | INT | NO | Unique card identifier | 5001 |
| client_id | INT | NO | Foreign key to users table | 1001 |
| card_brand | VARCHAR(50) | NO | Card issuer/brand | 'Visa', 'Mastercard', 'Amex' |
| card_type | VARCHAR(20) | NO | Type of card | 'Credit', 'Debit' |
| credit_limit | DECIMAL(14,2) | YES | Credit limit (NULL for debit cards) | 10000.00 |
| acct_open_date | DATE | NO | Date account was opened | 2020-01-15 |

**Notes**:
- `credit_limit` is only applicable for 'Credit' card types
- `card_brand` values should be consistent across the dataset
- A customer may have multiple cards

---

### banking.mcc_codes

| Field | Type | Nullable | Description | Example |
|-------|------|----------|-------------|---------|
| mcc_id | INT | NO | Merchant Category Code | 5411 |
| description | VARCHAR(255) | NO | Description of the category | 'Grocery Stores' |

**Notes**:
- MCC codes are standardized by the industry
- Common categories include:
  - 5411: Grocery Stores
  - 5812: Restaurants
  - 5541: Service Stations
  - 4121: Taxi and Limousines

---

## Relationships

### Entity Relationship Diagram

```
banking.users (1) ----< (N) banking.cards
                          |
                          | (1)
                          |
                          v
                    (N) banking.transactions
                          |
                          | (N)
                          |
                          v
                    banking.mcc_codes
```

### Relationship Details

1. **users → cards**: One-to-many
   - One user can have multiple cards
   - Each card belongs to exactly one user
   - Join condition: `users.id = cards.client_id`

2. **cards → transactions**: One-to-many
   - One card can have many transactions
   - Each transaction uses exactly one card
   - Join condition: `cards.id = transactions.card_id`

3. **users → transactions**: One-to-many
   - One user can have many transactions (through cards)
   - Each transaction belongs to exactly one user
   - Join condition: `users.id = transactions.client_id`

4. **mcc_codes → transactions**: One-to-many
   - One MCC code can appear in many transactions
   - Each transaction references at most one MCC
   - Join condition: `mcc_codes.mcc_id = transactions.mcc`

---

## Data Quality Rules

### Validation Rules

1. **transactions table**:
   - `date` must be between account open date and current date
   - `amount` should not be zero
   - `client_id` and `card_id` must reference valid records
   - `mcc` must reference valid mcc_codes if not NULL

2. **users table**:
   - `credit_score` should be between 300 and 850
   - `yearly_income` should be positive
   - `birth_date` should indicate customer is 18+ years old

3. **cards table**:
   - `credit_limit` should be positive for credit cards
   - `credit_limit` should be NULL for debit cards
   - `acct_open_date` should not be in the future

### Data Integrity Checks

```sql
-- Check for orphaned transactions
SELECT COUNT(*) FROM banking.transactions t
WHERE NOT EXISTS (SELECT 1 FROM banking.users u WHERE u.id = t.client_id)
   OR NOT EXISTS (SELECT 1 FROM banking.cards c WHERE c.id = t.card_id);

-- Check for invalid credit scores
SELECT COUNT(*) FROM banking.users
WHERE credit_score < 300 OR credit_score > 850;

-- Check for cards with invalid credit limits
SELECT COUNT(*) FROM banking.cards
WHERE card_type = 'Credit' AND (credit_limit IS NULL OR credit_limit <= 0);

-- Check for transactions with invalid MCC
SELECT COUNT(*) FROM banking.transactions t
WHERE t.mcc IS NOT NULL 
  AND NOT EXISTS (SELECT 1 FROM banking.mcc_codes m WHERE m.mcc_id = t.mcc);
```

---

## Data Loading

### CSV File Structure

The data files are located in the `data/` directory:

- `banking.transactions.csv` - Transaction records
- `banking.users.csv` - Customer information
- `banking.cards.csv` - Card details
- `banking.mcc.csv` - Merchant category codes

### Loading Script Example

```sql
-- Create tables if they don't exist
-- (See scripts/setup.sql for complete DDL)

-- Load data from CSV files
BULK INSERT banking.mcc_codes
FROM 'data/banking.mcc.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

BULK INSERT banking.users
FROM 'data/banking.users.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

BULK INSERT banking.cards
FROM 'data/banking.cards.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

BULK INSERT banking.transactions
FROM 'data/banking.transactions.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);
```

---

## Data Retention

### Archival Strategy

- **Active Data**: Last 24 months of transactions
- **Archive Data**: Transactions older than 24 months
- **Reference Data**: Users, cards, and MCC codes retained indefinitely

### Partitioning Recommendation

For large-scale deployments, consider partitioning the transactions table by date:

```sql
-- Example partitioning by year
CREATE PARTITION FUNCTION pf_TransactionDate (DATE)
AS RANGE RIGHT FOR VALUES (
    '2022-01-01', '2023-01-01', '2024-01-01'
);

CREATE PARTITION SCHEME ps_TransactionDate
AS PARTITION pf_TransactionDate
ALL TO ([PRIMARY]);
```

---

## Security Considerations

### Sensitive Data

The following fields contain sensitive information and should be protected:

- `users.yearly_income` - Financial information
- `users.credit_score` - Credit information
- `cards.credit_limit` - Financial information
- `transactions.amount` - Transaction amounts

### Access Control

Recommend implementing role-based access control:

- **analyst_role**: Read-only access to aggregated data
- **risk_role**: Read access to individual transactions for fraud detection
- **admin_role**: Full access for maintenance

### Data Masking

For reporting purposes, consider masking sensitive fields:

```sql
-- Example: Mask last 4 digits of card IDs in reports
SELECT 
    client_id,
    CONCAT('XXXX-XXXX-XXXX-', RIGHT(card_id, 4)) AS masked_card_id,
    amount
FROM banking.transactions;
```

---

## Glossary

| Term | Definition |
|------|------------|
| MCC | Merchant Category Code - 4-digit code classifying merchants |
| CTE | Common Table Expression - Temporary result set in SQL |
| Utilization | Ratio of credit used to credit limit available |
| Churn | Customer stopping use of service |
| Quintile | Division of data into 5 equal parts |
| Percentile | Value below which a percentage of data falls |

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2023 | Initial data dictionary |

---

## Contact

For questions about data structures or to report data quality issues, please refer to the main project README or open an issue in the repository.
