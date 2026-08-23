# Dashboard User Guide

This guide provides detailed instructions for using the Banking Risk Analytics Dashboard.

---

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Dashboard](#running-the-dashboard)
- [Dashboard Pages](#dashboard-pages)
- [Features](#features)
- [Troubleshooting](#troubleshooting)

---

## Overview

The Banking Risk Analytics Dashboard is an interactive web-based application built with Streamlit. It provides real-time visualization and analysis of banking transaction data, customer segmentation, and risk detection metrics.

### Key Features

- **Interactive Charts**: All charts are interactive with zoom, pan, and hover capabilities
- **Multiple Data Sources**: Support for both CSV files and SQL Server databases
- **Real-time Analysis**: Instant calculations and visualizations
- **Responsive Design**: Works on desktop, tablet, and mobile devices
- **Four Main Pages**: Overview, Customer Segmentation, Risk Detection, Advanced Analytics

---

## Installation

### Prerequisites

- Python 3.8 or higher
- pip (Python package manager)
- (Optional) SQL Server with ODBC Driver 17 for database connectivity

### Step 1: Install Dependencies

```bash
# Navigate to project directory
cd "Banking Transactions & Risk Analytics"

# Install required packages
pip install -r requirements.txt
```

### Step 2: Prepare Data

#### Option A: Use CSV Files (Recommended for Quick Start)

Ensure the following CSV files are in the `data/` directory:
- `banking.transactions.csv`
- `banking.cards.csv`
- `banking.users.csv`
- `banking.mcc.csv`

#### Option B: Use SQL Database

1. Set up the database using the setup script:
   ```bash
   sqlcmd -S localhost -U sa -P your_password -i scripts/setup.sql
   ```

2. Import your data into the database tables

3. Configure database connection (see Configuration section)

---

## Configuration

### Environment Variables

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your database credentials:
   ```env
   DATABASE_SERVER=localhost
   DATABASE_NAME=BankingRiskAnalytics
   DATABASE_USERNAME=sa
   DATABASE_PASSWORD=your_password
   ```

### Streamlit Configuration

Create a `.streamlit/config.toml` file for custom settings:

```toml
[theme]
primaryColor = "#1e3a5f"
backgroundColor = "#f5f5f5"
secondaryBackgroundColor = "#ffffff"
textColor = "#262730"
font = "sans serif"

[client]
showErrorDetails = true
maxUploadSize = 200

[logger]
level = "info"
```

---

## Running the Dashboard

### Start the Dashboard

```bash
# From project root directory
streamlit run dashboard/app.py
```

The dashboard will automatically open in your default web browser at:
```
http://localhost:8501
```

### Command Line Options

```bash
# Specify a different port
streamlit run dashboard/app.py --server.port 8502

# Run in headless mode (no browser auto-open)
streamlit run dashboard/app.py --server.headless true

# Enable file watcher for auto-reload
streamlit run dashboard/app.py --server.runOnSave true

# Set maximum upload size
streamlit run dashboard/app.py --server.maxUploadSize 500
```

---

## Dashboard Pages

### 1. Overview Page

**Purpose**: High-level metrics and transaction trends

**Metrics Displayed**:
- Total Transactions
- Total Amount
- Average Transaction
- Error Rate

**Charts**:
- Transaction Volume Over Time (Line chart)
- Transaction Amount Distribution (Histogram)
- Top 10 Merchant Cities (Horizontal bar chart)

**Use Cases**:
- Daily monitoring of transaction volumes
- Identifying unusual patterns in transaction amounts
- Geographic distribution analysis

---

### 2. Customer Segmentation Page

**Purpose**: Analyze customer demographics and credit profiles

**Charts**:
- Credit Score Distribution (Pie chart)
- Credit Score vs Yearly Income (Scatter plot)
- Card Brand Market Share (Pie chart)

**Credit Score Buckets**:
- Poor (< 580)
- Fair (580-669)
- Good (670-739)
- Very Good (740-799)
- Excellent (800+)

**Use Cases**:
- Customer portfolio analysis
- Targeted marketing campaign planning
- Credit limit adjustment decisions

---

### 3. Risk Detection Page

**Purpose**: Identify potential fraud and risk indicators

**Metrics**:
- Suspicious Multi-State Activity (customers with transactions in 3+ states in one day)
- High Value Transactions (>$10,000)
- Failed Transactions
- High Utilization Cards (>80% credit limit)
- At-Risk Customers (>30 day transaction gap)

**Charts**:
- Credit Utilization Distribution (Histogram)

**Risk Indicators**:
- **Multi-State Fraud**: Detects customers making transactions in multiple states on the same day
- **High Utilization**: Identifies cards with credit utilization above 80%
- **Churn Risk**: Customers with gaps >30 days between transactions

**Use Cases**:
- Real-time fraud monitoring
- Credit risk assessment
- Customer retention planning

---

### 4. Advanced Analytics Page

**Purpose**: Deep-dive analysis into spending patterns

**Charts**:
- Top 10 Merchant Categories by Spending (Horizontal bar chart)
- Monthly Spending Trend (Line chart)
- State-wise Spending Distribution (Bar chart with color gradient)

**Use Cases**:
- Understanding customer spending preferences
- Seasonal trend analysis
- Geographic market analysis

---

## Features

### Data Source Selection

The dashboard supports two data sources:

#### CSV Files Mode
- **Pros**: Quick setup, no database required
- **Cons**: Slower for large datasets, no real-time updates
- **Best for**: Development, testing, small datasets

#### SQL Database Mode
- **Pros**: Fast for large datasets, real-time data access
- **Cons**: Requires database setup
- **Best for**: Production, large datasets, real-time monitoring

### Interactive Charts

All charts support:
- **Zoom**: Scroll to zoom in/out
- **Pan**: Click and drag to move around
- **Hover**: Hover over data points for details
- **Download**: Click camera icon to save as PNG

### Responsive Layout

The dashboard automatically adjusts to:
- Desktop screens (1920x1080 and above)
- Tablet devices (768x1024)
- Mobile devices (375x667 and above)

---

## Troubleshooting

### Common Issues

#### Issue: "Database connection error"

**Solution**:
1. Verify SQL Server is running
2. Check ODBC Driver 17 is installed
3. Test connection string in SSMS or Azure Data Studio
4. Ensure firewall allows connections

#### Issue: "Error loading CSV data"

**Solution**:
1. Verify CSV files exist in `data/` directory
2. Check file permissions
3. Ensure CSV format matches expected schema
4. Check for encoding issues (should be UTF-8)

#### Issue: Dashboard runs slowly

**Solution**:
1. Use SQL Database mode instead of CSV for large datasets
2. Add indexes to database tables (see setup.sql)
3. Reduce data range by adding filters
4. Increase system resources (RAM/CPU)

#### Issue: Charts not displaying

**Solution**:
1. Check browser console for JavaScript errors
2. Verify Plotly and Streamlit are installed correctly
3. Try clearing browser cache
4. Ensure data is not empty or NULL

#### Issue: Port 8501 already in use

**Solution**:
```bash
# Use a different port
streamlit run dashboard/app.py --server.port 8502
```

### Performance Optimization

For large datasets (>1M transactions):

1. **Use SQL Database**: Much faster than CSV parsing
2. **Add Indexes**: Ensure all recommended indexes are created
3. **Data Sampling**: Add sampling for initial views
4. **Caching**: Implement Redis caching for frequently accessed data
5. **Pagination**: Add pagination for large result sets

### Browser Compatibility

**Supported Browsers**:
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

**Not Supported**:
- Internet Explorer (any version)

---

## Security Considerations

### Database Credentials

- Never commit `.env` file to version control
- Use strong passwords
- Implement least privilege access
- Rotate credentials regularly
- Use connection encryption (SSL/TLS)

### Data Privacy

- Dashboard runs locally by default
- No data is sent to external servers
- Implement authentication for production deployment
- Use HTTPS for remote access
- Log access for audit trails

---

## Deployment

### Local Deployment

For personal use or small teams:

```bash
streamlit run dashboard/app.py
```

### Cloud Deployment

#### Streamlit Cloud

1. Push code to GitHub
2. Connect repository to Streamlit Cloud
3. Add secrets in Streamlit Cloud dashboard
4. Deploy automatically

#### Docker Deployment

Create `Dockerfile`:

```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8501

CMD ["streamlit", "run", "dashboard/app.py", "--server.port=8501", "--server.address=0.0.0.0"]
```

Build and run:

```bash
docker build -t banking-dashboard .
docker run -p 8501:8501 banking-dashboard
```

---

## Customization

### Adding New Charts

Edit `dashboard/app.py`:

```python
# Add new chart in appropriate page section
st.subheader("Your New Chart")
fig = px.your_chart_type(data, x='column1', y='column2')
st.plotly_chart(fig, use_container_width=True)
```

### Adding New Pages

1. Add new page option in sidebar:
   ```python
   page = st.sidebar.radio(
       "Navigate to",
       ["📊 Overview", "👥 Customer Segmentation", "⚠️ Risk Detection", "📈 Advanced Analytics", "🆕 New Page"]
   )
   ```

2. Add new page section:
   ```python
   elif page == "🆕 New Page":
       st.title("🆕 New Page")
       # Your page content
   ```

### Changing Color Theme

Edit the custom CSS section in `app.py`:

```python
st.markdown("""
<style>
    .main {
        background-color: #your_color;
    }
    h1, h2, h3 {
        color: #your_color;
    }
</style>
""", unsafe_allow_html=True)
```

---

## Support

For issues or questions:
1. Check this documentation
2. Review the main project README
3. Open an issue on GitHub
4. Contact the development team

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2023 | Initial dashboard release |

---

## License

This dashboard is part of the Banking Risk Analytics project and is licensed under the MIT License.
