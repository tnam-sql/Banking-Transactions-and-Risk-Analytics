-- ============================================================================
-- Banking Risk Analytics - Database Setup Script
-- ============================================================================
-- Description: Creates the database schema and tables for the project
-- Usage: Run this script in SQL Server Management Studio or Azure Data Studio
-- Author: Banking Risk Analytics Team
-- Version: 1.0
-- ============================================================================

-- Drop database if exists (uncomment to recreate)
-- DROP DATABASE IF EXISTS BankingRiskAnalytics;
-- GO

-- Create database
-- CREATE DATABASE BankingRiskAnalytics;
-- GO

-- USE BankingRiskAnalytics;
-- GO

-- ============================================================================
-- Create Schema
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'banking')
BEGIN
    EXEC('CREATE SCHEMA banking');
END
GO

-- ============================================================================
-- Create Tables
-- ============================================================================

-- MCC Codes Reference Table
IF OBJECT_ID('banking.mcc_codes', 'U') IS NOT NULL
    DROP TABLE banking.mcc_codes;
GO

CREATE TABLE banking.mcc_codes (
    mcc_id INT PRIMARY KEY,
    description VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- Users Table
IF OBJECT_ID('banking.users', 'U') IS NOT NULL
    DROP TABLE banking.users;
GO

CREATE TABLE banking.users (
    id INT PRIMARY KEY IDENTITY(1,1),
    credit_score INT NOT NULL CHECK (credit_score BETWEEN 300 AND 850),
    yearly_income DECIMAL(12,2) NOT NULL CHECK (yearly_income > 0),
    gender VARCHAR(10),
    birth_date DATE,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- Cards Table
IF OBJECT_ID('banking.cards', 'U') IS NOT NULL
    DROP TABLE banking.cards;
GO

CREATE TABLE banking.cards (
    id INT PRIMARY KEY IDENTITY(1,1),
    client_id INT NOT NULL,
    card_brand VARCHAR(50) NOT NULL,
    card_type VARCHAR(20) NOT NULL CHECK (card_type IN ('Credit', 'Debit')),
    credit_limit DECIMAL(14,2) NULL,
    acct_open_date DATE NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_cards_client FOREIGN KEY (client_id) REFERENCES banking.users(id),
    CONSTRAINT chk_credit_limit CHECK (
        (card_type = 'Credit' AND credit_limit IS NOT NULL AND credit_limit > 0) OR
        (card_type = 'Debit' AND credit_limit IS NULL)
    )
);
GO

-- Transactions Table
IF OBJECT_ID('banking.transactions', 'U') IS NOT NULL
    DROP TABLE banking.transactions;
GO

CREATE TABLE banking.transactions (
    id BIGINT PRIMARY KEY IDENTITY(1,1),
    date DATETIME NOT NULL,
    client_id INT NOT NULL,
    card_id INT NOT NULL,
    amount DECIMAL(14,2) NOT NULL CHECK (amount <> 0),
    mcc INT NULL,
    merchant_city VARCHAR(100) NULL,
    merchant_state VARCHAR(2) NULL,
    errors VARCHAR(255) NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_transactions_client FOREIGN KEY (client_id) REFERENCES banking.users(id),
    CONSTRAINT fk_transactions_card FOREIGN KEY (card_id) REFERENCES banking.cards(id),
    CONSTRAINT fk_transactions_mcc FOREIGN KEY (mcc) REFERENCES banking.mcc_codes(mcc_id)
);
GO

-- ============================================================================
-- Create Indexes
-- ============================================================================

-- Transactions indexes
CREATE INDEX idx_transactions_date ON banking.transactions(date);
GO

CREATE INDEX idx_transactions_client_date ON banking.transactions(client_id, date);
GO

CREATE INDEX idx_transactions_card_date ON banking.transactions(card_id, date);
GO

CREATE INDEX idx_transactions_mcc_amount ON banking.transactions(mcc, amount);
GO

CREATE INDEX idx_transactions_state_amount ON banking.transactions(merchant_state, amount);
GO

-- Users indexes
CREATE INDEX idx_users_credit_score ON banking.users(credit_score);
GO

-- Cards indexes
CREATE INDEX idx_cards_client_id ON banking.cards(client_id);
GO

CREATE INDEX idx_cards_card_type ON banking.cards(card_type);
GO

-- ============================================================================
-- Create Views for Common Queries
-- ============================================================================

-- View: Valid transactions (successful, positive amount)
IF OBJECT_ID('banking.v_valid_transactions', 'V') IS NOT NULL
    DROP VIEW banking.v_valid_transactions;
GO

CREATE VIEW banking.v_valid_transactions AS
SELECT 
    id,
    date,
    client_id,
    card_id,
    amount,
    mcc,
    merchant_city,
    merchant_state
FROM banking.transactions
WHERE amount > 0 
  AND (errors IS NULL OR errors = 'No Error');
GO

-- View: Credit cards only
IF OBJECT_ID('banking.v_credit_cards', 'V') IS NOT NULL
    DROP VIEW banking.v_credit_cards;
GO

CREATE VIEW banking.v_credit_cards AS
SELECT 
    id,
    client_id,
    card_brand,
    credit_limit,
    acct_open_date
FROM banking.cards
WHERE card_type = 'Credit';
GO

-- View: Customer summary
IF OBJECT_ID('banking.v_customer_summary', 'V') IS NOT NULL
    DROP VIEW banking.v_customer_summary;
GO

CREATE VIEW banking.v_customer_summary AS
SELECT 
    u.id AS client_id,
    u.credit_score,
    u.yearly_income,
    u.gender,
    COUNT(DISTINCT c.id) AS card_count,
    SUM(CASE WHEN c.card_type = 'Credit' THEN c.credit_limit ELSE 0 END) AS total_credit_limit,
    COUNT(t.id) AS transaction_count,
    SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END) AS total_debit_amount,
    SUM(CASE WHEN t.amount < 0 THEN ABS(t.amount) ELSE 0 END) AS total_credit_amount
FROM banking.users u
LEFT JOIN banking.cards c ON u.id = c.client_id
LEFT JOIN banking.transactions t ON u.id = t.client_id
GROUP BY u.id, u.credit_score, u.yearly_income, u.gender;
GO

-- ============================================================================
-- Create Stored Procedures
-- ============================================================================

-- Stored Procedure: Get customer spending trend
IF OBJECT_ID('banking.sp_get_customer_spending_trend', 'P') IS NOT NULL
    DROP PROCEDURE banking.sp_get_customer_spending_trend;
GO

CREATE PROCEDURE banking.sp_get_customer_spending_trend
    @client_id INT,
    @months INT = 12
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        DATEFROMPARTS(YEAR(t.date), MONTH(t.date), 1) AS month_start,
        FORMAT(DATEFROMPARTS(YEAR(t.date), MONTH(t.date), 1), 'yyyy-MM') AS year_month,
        SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END) AS debit_amount,
        SUM(CASE WHEN t.amount < 0 THEN ABS(t.amount) ELSE 0 END) AS credit_amount,
        COUNT(*) AS transaction_count
    FROM banking.transactions t
    WHERE t.client_id = @client_id
      AND t.date >= DATEADD(MONTH, -@months, GETDATE())
    GROUP BY DATEFROMPARTS(YEAR(t.date), MONTH(t.date), 1)
    ORDER BY month_start;
END
GO

-- Stored Procedure: Get fraud alerts
IF OBJECT_ID('banking.sp_get_fraud_alerts', 'P') IS NOT NULL
    DROP PROCEDURE banking.sp_get_fraud_alerts;
GO

CREATE PROCEDURE banking.sp_get_fraud_alerts
    @days_back INT = 7
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Multi-state fraud detection
    SELECT 
        'MULTI_STATE' AS alert_type,
        t.client_id,
        CAST(t.date AS DATE) AS activity_date,
        COUNT(DISTINCT t.merchant_state) AS distinct_states,
        COUNT(*) AS trans_count,
        CAST(SUM(t.amount) AS DECIMAL(14,2)) AS total_amount
    FROM banking.transactions t
    WHERE t.merchant_state IS NOT NULL
      AND t.date >= DATEADD(DAY, -@days_back, GETDATE())
    GROUP BY t.client_id, CAST(t.date AS DATE)
    HAVING COUNT(DISTINCT t.merchant_state) >= 3
    
    UNION ALL
    
    -- High amount outlier detection
    SELECT 
        'HIGH_AMOUNT' AS alert_type,
        v.client_id,
        CAST(v.date AS DATE) AS activity_date,
        1 AS distinct_states,
        1 AS trans_count,
        CAST(v.amount AS DECIMAL(14,2)) AS total_amount
    FROM banking.transactions v
    WHERE v.amount > 10000  -- Threshold for high amount
      AND v.date >= DATEADD(DAY, -@days_back, GETDATE())
    
    ORDER BY activity_date DESC, total_amount DESC;
END
GO

-- ============================================================================
-- Grant Permissions (adjust as needed for your environment)
-- ============================================================================
-- GRANT SELECT ON banking.mcc_codes TO analyst_role;
-- GRANT SELECT ON banking.users TO analyst_role;
-- GRANT SELECT ON banking.cards TO analyst_role;
-- GRANT SELECT ON banking.transactions TO analyst_role;
-- GRANT SELECT ON banking.v_valid_transactions TO analyst_role;
-- GRANT SELECT ON banking.v_credit_cards TO analyst_role;
-- GRANT SELECT ON banking.v_customer_summary TO analyst_role;
-- GRANT EXECUTE ON banking.sp_get_customer_spending_trend TO analyst_role;
-- GRANT EXECUTE ON banking.sp_get_fraud_alerts TO risk_role;
-- GO

-- ============================================================================
-- Setup Complete
-- ============================================================================
PRINT 'Database setup completed successfully.';
PRINT 'Schema: banking';
PRINT 'Tables: mcc_codes, users, cards, transactions';
PRINT 'Views: v_valid_transactions, v_credit_cards, v_customer_summary';
PRINT 'Stored Procedures: sp_get_customer_spending_trend, sp_get_fraud_alerts';
GO
