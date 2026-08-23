# Banking Transactions & Risk Analytics

<div align="center">

![Project Status](https://img.shields.io/badge/status-active-success.svg)
![SQL](https://img.shields.io/badge/SQL-Server-blue.svg)
![Streamlit](https://img.shields.io/badge/Streamlit-1.28+-red.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

**A comprehensive SQL-based analytics framework for banking transaction analysis and risk detection with interactive dashboard**

[Documentation](#documentation) • [Quick Start](#quick-start) • [Dashboard](#dashboard) • [Queries](#queries) • [Contributing](#contributing)

</div>

---

## 📊 Overview

This project provides a complete SQL analytics solution for banking transaction data, focusing on risk detection, customer segmentation, and business intelligence. It includes 15 optimized SQL queries covering various aspects of financial analytics.

### Key Features

- **Transaction Analysis**: Comprehensive analysis of banking transactions
- **Risk Detection**: Fraud detection and risk assessment algorithms
- **Customer Segmentation**: Credit score bucketing and customer profiling
- **Advanced Analytics**: Running totals, correlation analysis, and heatmaps
- **Performance Optimized**: All queries optimized for large-scale datasets
- **Interactive Dashboard**: Real-time visualization with Streamlit
- **Multiple Data Sources**: Support for CSV files and SQL Server databases

---

## 🗂️ Project Structure

```
banking-risk-analytics/
│
├── data/                          # Raw data files
│   ├── banking.cards.csv
│   ├── banking.mcc.csv
│   ├── banking.users.csv
│   └── banking.transactions.csv
│
├── queries/                       # Organized SQL queries
│   ├── 01_basic_analytics/       # Basic transaction analysis
│   │   ├── 01_total_transactions_2023.sql
│   │   ├── 02_top_merchant_cities.sql
│   │   └── 03_card_brand_market_share.sql
│   │
│   ├── 02_customer_segmentation/ # Customer analysis
│   │   ├── 04_credit_score_bucketing.sql
│   │   ├── 05_transaction_failure_rate.sql
│   │   ├── 06_top_spenders_monthly.sql
│   │   └── 07_top_merchant_categories.sql
│   │
│   ├── 03_risk_detection/        # Fraud and risk detection
│   │   ├── 08_credit_utilization.sql
│   │   ├── 09_inactive_cards.sql
│   │   ├── 10_multi_state_fraud.sql
│   │   └── 12_churn_detection.sql
│   │
│   └── 04_advanced_analytics/    # Advanced analytics
│       ├── 11_monthly_running_total.sql
│       ├── 13_outlier_detection.sql
│       ├── 14_credit_score_correlation.sql
│       └── 15_state_category_heatmap.sql
│
├── docs/                          # Documentation
│   ├── query_documentation.md
│   ├── data_dictionary.md
│   └── dashboard_guide.md
│
├── scripts/                       # Utility scripts
│   └── setup.sql
│
├── dashboard/                     # Interactive Streamlit dashboard
│   └── app.py
│
├── ERD.pdf                        # Entity Relationship Diagram
├── requirements.txt               # Python dependencies
├── .env.example                   # Environment configuration template
├── .gitignore                     # Git ignore rules
├── LICENSE                        # MIT License
└── README.md                      # This file
```

---

## 🚀 Quick Start

### Prerequisites

- SQL Server 2019 or later
- SSMS (SQL Server Management Studio) or Azure Data Studio
- Python 3.8+ (for optional data processing)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/banking-risk-analytics.git
   cd banking-risk-analytics
   ```

2. **Set up the database**
   ```sql
   -- Run the setup script
   :r scripts/setup.sql
   ```

3. **Import data**
   - Use the provided CSV files in the `data/` directory
   - Follow the data dictionary in `docs/data_dictionary.md`

### Running Queries

Execute individual queries from the `queries/` directory:

```sql
-- Example: Run credit score bucketing
:r queries/02_customer_segmentation/04_credit_score_bucketing.sql
```

---

## � Dashboard

### Overview

The project includes an interactive Streamlit dashboard for real-time visualization and analysis of banking data.

### Dashboard Features

- **4 Main Pages**: Overview, Customer Segmentation, Risk Detection, Advanced Analytics
- **Interactive Charts**: All charts support zoom, pan, and hover
- **Multiple Data Sources**: CSV files or SQL Server database
- **Real-time Metrics**: Key performance indicators updated instantly
- **Responsive Design**: Works on desktop, tablet, and mobile

### Quick Start with Dashboard

1. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **Prepare data**
   - Place CSV files in the `data/` directory, OR
   - Set up SQL database using `scripts/setup.sql`

3. **Configure database (if using SQL)**
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials
   ```

4. **Run the dashboard**
   ```bash
   streamlit run dashboard/app.py
   ```

5. **Open browser**
   The dashboard will open at `http://localhost:8501`

### Dashboard Pages

#### 📊 Overview
- Total transactions, amounts, and error rates
- Transaction volume over time
- Transaction amount distribution
- Top merchant cities

#### 👥 Customer Segmentation
- Credit score distribution
- Credit score vs income analysis
- Card brand market share

#### ⚠️ Risk Detection
- Multi-state fraud detection
- High-value transaction alerts
- Credit utilization analysis
- Churn risk indicators

#### 📈 Advanced Analytics
- Top merchant categories by spending
- Monthly spending trends
- State-wise spending distribution

### Documentation

For detailed dashboard documentation, see [docs/dashboard_guide.md](docs/dashboard_guide.md).

---

## �📋 Queries Overview

### 01. Basic Analytics

| Query | Description | Purpose |
|-------|-------------|---------|
| 01 | Total Transactions 2023 | Count all transactions in 2023 |
| 02 | Top Merchant Cities | Top 5 cities by transaction volume |
| 03 | Card Brand Market Share | Market share by card issuer |

### 02. Customer Segmentation

| Query | Description | Purpose |
|-------|-------------|---------|
| 04 | Credit Score Bucketing | Segment customers by credit score |
| 05 | Transaction Failure Rate | Calculate error/failure rate |
| 06 | Top Monthly Spenders | Top 10 customers by monthly spend |
| 07 | Top Merchant Categories | Top categories by spending |

### 03. Risk Detection

| Query | Description | Purpose |
|-------|-------------|---------|
| 08 | Credit Utilization | Credit limit usage analysis |
| 09 | Inactive Cards | Cards opened >2 years with no transactions |
| 10 | Multi-State Fraud | Detect suspicious multi-state activity |
| 12 | Churn Detection | Identify customers at risk of churning |

### 04. Advanced Analytics

| Query | Description | Purpose |
|-------|-------------|---------|
| 11 | Monthly Running Total | Cumulative spending over time |
| 13 | Outlier Detection | Detect unusual transactions by MCC |
| 14 | Credit Score Correlation | Correlation between score and spending |
| 15 | State-Category Heatmap | Spending patterns by state & category |

---

## 📚 Documentation

### Data Dictionary

Detailed information about data structures is available in [docs/data_dictionary.md](docs/data_dictionary.md).

### Query Documentation

Each query includes:
- Business purpose
- Technical description
- Input parameters
- Output schema
- Performance notes

See [docs/query_documentation.md](docs/query_documentation.md) for details.

---

## 🔧 Technical Details

### Database Schema

The project uses the following main tables:

- **banking.transactions**: Transaction records
- **banking.users**: Customer information
- **banking.cards**: Card details and limits
- **banking.mcc_codes**: Merchant category codes

### Performance Considerations

- All queries use appropriate indexes
- CTEs (Common Table Expressions) for readability
- Window functions for advanced analytics
- Optimized for datasets with millions of records

---

## 📊 Sample Results

### Credit Score Distribution
```
CHIA_NHOM_CS        | TONG_KH | PHAN_TRAM
--------------------|---------|----------
1.Poor(<580)        | 1,234   | 12.34
2.Fair(580-669)     | 2,345   | 23.45
3.Good(670-739)     | 3,456   | 34.56
4.Very Good(740-799)| 2,012   | 20.12
5.Excellent(800+)   | 953     | 9.53
```

### Fraud Detection Example
```
CLIENT_ID | ACTIVITY_DATE | DISTINCT_STATES | TRANS_COUNT | TOTAL_AMOUNT
----------|---------------|-----------------|-------------|-------------
12345     | 2023-06-15    | 4               | 12          | 4,500.00
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow SQL best practices
- Add comments for complex logic
- Update documentation for new queries
- Test on sample data before submitting

---

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👥 Authors

- **Your Name** - Initial work

---

## 🙏 Acknowledgments

- Banking data provided by [Source]
- Inspired by industry best practices in financial analytics

---

## 📞 Contact

For questions or support:
- Open an issue on GitHub
- Email: your.email@example.com

---

<div align="center">

**Built with ❤️ for the data analytics community**

[⬆ Back to Top](#banking-transactions--risk-analytics)

</div>
