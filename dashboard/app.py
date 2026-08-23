"""
Banking Risk Analytics Dashboard
==================================
Interactive Streamlit dashboard for banking transaction analysis and risk detection
"""

import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pyodbc
from datetime import datetime, timedelta
import os

# Page configuration
st.set_page_config(
    page_title="Banking Risk Analytics Dashboard",
    page_icon="🏦",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS
st.markdown("""
<style>
    .main {
        background-color: #f5f5f5;
    }
    .stMetric {
        background-color: white;
        padding: 15px;
        border-radius: 10px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    h1, h2, h3 {
        color: #1e3a5f;
    }
</style>
""", unsafe_allow_html=True)

# Database connection function
def get_connection():
    """Create database connection"""
    try:
        conn = pyodbc.connect(
            f"DRIVER={{ODBC Driver 17 for SQL Server}};"
            f"SERVER={st.secrets['database']['server']};"
            f"DATABASE={st.secrets['database']['database']};"
            f"UID={st.secrets['database']['username']};"
            f"PWD={st.secrets['database']['password']}"
        )
        return conn
    except Exception as e:
        st.error(f"Database connection error: {e}")
        return None

# Query functions
def run_query(query, params=None):
    """Execute SQL query and return DataFrame"""
    conn = get_connection()
    if conn is None:
        return pd.DataFrame()
    
    try:
        df = pd.read_sql(query, conn, params=params)
        return df
    except Exception as e:
        st.error(f"Query execution error: {e}")
        return pd.DataFrame()
    finally:
        conn.close()

# Load data from CSV files (fallback if database not available)
def load_csv_data():
    """Load data from CSV files"""
    data_dir = "data"
    
    try:
        transactions = pd.read_csv(f"{data_dir}/banking.transactions.csv")
        cards = pd.read_csv(f"{data_dir}/banking.cards.csv")
        users = pd.read_csv(f"{data_dir}/banking.users.csv")
        mcc = pd.read_csv(f"{data_dir}/banking.mcc.csv")
        
        # Add id column to cards DataFrame (CSV doesn't have it)
        cards['id'] = range(1, len(cards) + 1)
        
        # Add id column to users DataFrame if needed
        if 'id' not in users.columns:
            users['id'] = range(1, len(users) + 1)
        
        return transactions, cards, users, mcc
    except Exception as e:
        st.error(f"Error loading CSV data: {e}")
        return None, None, None, None

# Sidebar
st.sidebar.title("🏦 Banking Risk Analytics")
st.sidebar.markdown("---")

# Data source selection
data_source = st.sidebar.radio(
    "Data Source",
    ["CSV Files", "SQL Database"],
    help="Choose data source for the dashboard"
)

# Database configuration (hidden by default)
if data_source == "SQL Database":
    with st.sidebar.expander("Database Configuration"):
        server = st.text_input("Server", "localhost")
        database = st.text_input("Database", "BankingRiskAnalytics")
        username = st.text_input("Username", "sa")
        password = st.text_input("Password", type="password")
        
        if st.button("Test Connection"):
            try:
                conn = pyodbc.connect(
                    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
                    f"SERVER={server};"
                    f"DATABASE={database};"
                    f"UID={username};"
                    f"PWD={password}"
                )
                st.success("Connection successful!")
                conn.close()
            except Exception as e:
                st.error(f"Connection failed: {e}")

# Page navigation
page = st.sidebar.radio(
    "Navigate to",
    ["📊 Overview", "👥 Customer Segmentation", "⚠️ Risk Detection", "📈 Advanced Analytics"],
    label_visibility="collapsed"
)

st.sidebar.markdown("---")
st.sidebar.markdown("### About")
st.sidebar.info("""
This dashboard provides comprehensive analytics for banking transactions, customer segmentation, and risk detection.
""")

# Load data
if data_source == "CSV Files":
    transactions, cards, users, mcc = load_csv_data()
    if transactions is not None:
        # Convert date column
        transactions['date'] = pd.to_datetime(transactions['date'])
else:
    transactions = None

# Main content
if page == "📊 Overview":
    st.title("📊 Dashboard Overview")
    st.markdown("---")
    
    if transactions is None:
        st.warning("No data available. Please check your data source.")
    else:
        # Key metrics
        col1, col2, col3, col4 = st.columns(4)
        
        total_transactions = len(transactions)
        total_amount = transactions['amount'].sum()
        avg_transaction = transactions['amount'].mean()
        error_rate = (transactions['errors'].notna() & (transactions['errors'] != 'No Error')).sum() / total_transactions * 100
        
        col1.metric("Total Transactions", f"{total_transactions:,.0f}")
        col2.metric("Total Amount", f"${total_amount:,.2f}")
        col3.metric("Avg Transaction", f"${avg_transaction:.2f}")
        col4.metric("Error Rate", f"{error_rate:.2f}%")
        
        st.markdown("---")
        
        # Charts
        col1, col2 = st.columns(2)
        
        # Transaction volume over time
        with col1:
            st.subheader("Transaction Volume Over Time")
            transactions['date_only'] = transactions['date'].dt.date
            daily_volume = transactions.groupby('date_only').size().reset_index(name='count')
            
            fig = px.line(daily_volume, x='date_only', y='count', 
                         title='Daily Transaction Count',
                         labels={'date_only': 'Date', 'count': 'Transactions'})
            fig.update_layout(height=400)
            st.plotly_chart(fig, use_container_width=True)
        
        # Transaction amount distribution
        with col2:
            st.subheader("Transaction Amount Distribution")
            fig = px.histogram(transactions[transactions['amount'] > 0], 
                             x='amount',
                             title='Transaction Amount Distribution',
                             nbins=50,
                             labels={'amount': 'Amount ($)'})
            fig.update_layout(height=400)
            st.plotly_chart(fig, use_container_width=True)
        
        st.markdown("---")
        
        # Top merchant cities
        st.subheader("Top 10 Merchant Cities by Transaction Volume")
        top_cities = transactions[transactions['merchant_city'].notna()].groupby('merchant_city').size().nlargest(10)
        
        fig = px.bar(x=top_cities.values, y=top_cities.index,
                     orientation='h',
                     title='Top 10 Merchant Cities',
                     labels={'x': 'Transaction Count', 'y': 'City'})
        fig.update_layout(height=400)
        st.plotly_chart(fig, use_container_width=True)

elif page == "👥 Customer Segmentation":
    st.title("👥 Customer Segmentation")
    st.markdown("---")
    
    if users is None:
        st.warning("No user data available.")
    else:
        # Credit score distribution
        col1, col2 = st.columns(2)
        
        with col1:
            st.subheader("Credit Score Distribution")
            
            # Create credit score buckets
            def credit_score_bucket(score):
                if score < 580:
                    return 'Poor (<580)'
                elif score < 670:
                    return 'Fair (580-669)'
                elif score < 740:
                    return 'Good (670-739)'
                elif score < 800:
                    return 'Very Good (740-799)'
                else:
                    return 'Excellent (800+)'
            
            users['credit_bucket'] = users['credit_score'].apply(credit_score_bucket)
            score_dist = users['credit_bucket'].value_counts().sort_index()
            
            fig = px.pie(values=score_dist.values, names=score_dist.index,
                        title='Credit Score Distribution',
                        hole=0.4)
            fig.update_traces(textposition='inside', textinfo='percent+label')
            st.plotly_chart(fig, use_container_width=True)
        
        with col2:
            st.subheader("Credit Score vs Income")
            fig = px.scatter(users, x='credit_score', y='yearly_income',
                           title='Credit Score vs Yearly Income',
                           labels={'credit_score': 'Credit Score', 
                                  'yearly_income': 'Yearly Income ($)'},
                           color='credit_bucket',
                           opacity=0.6)
            fig.update_layout(height=400)
            st.plotly_chart(fig, use_container_width=True)
        
        st.markdown("---")
        
        # Card brand market share
        if cards is not None:
            st.subheader("Card Brand Market Share")
            card_brands = cards['card_brand'].value_counts()
            
            fig = px.pie(values=card_brands.values, names=card_brands.index,
                        title='Card Brand Distribution',
                        hole=0.4)
            fig.update_traces(textposition='inside', textinfo='percent+label')
            st.plotly_chart(fig, use_container_width=True)

elif page == "⚠️ Risk Detection":
    st.title("⚠️ Risk Detection")
    st.markdown("---")
    
    if transactions is None:
        st.warning("No transaction data available.")
    else:
        # Fraud detection metrics
        col1, col2, col3 = st.columns(3)
        
        # Multi-state transactions (potential fraud)
        multi_state = transactions[transactions['merchant_state'].notna()].groupby(
            ['client_id', transactions['date'].dt.date]
        )['merchant_state'].nunique()
        suspicious = multi_state[multi_state >= 3]
        
        col1.metric("Suspicious Multi-State Activity", f"{len(suspicious):,}")
        
        # High value transactions
        high_value = transactions[transactions['amount'] > 10000]
        col2.metric("High Value Transactions (> $10K)", f"{len(high_value):,}")
        
        # Failed transactions
        failed = transactions[transactions['errors'].notna() & (transactions['errors'] != 'No Error')]
        col3.metric("Failed Transactions", f"{len(failed):,}")
        
        st.markdown("---")
        
        # Credit utilization (if cards data available)
        if cards is not None and transactions is not None:
            st.subheader("Credit Utilization Analysis")
            
            credit_cards = cards[cards['card_type'] == 'Credit']
            if len(credit_cards) > 0:
                # Calculate utilization
                card_spend = transactions[transactions['amount'] > 0].groupby('card_id')['amount'].sum()
                utilization = pd.DataFrame({
                    'card_id': credit_cards['id'],
                    'credit_limit': credit_cards['credit_limit'],
                    'spend': card_spend.reindex(credit_cards['id'], fill_value=0)
                })
                utilization['utilization_pct'] = (utilization['spend'] / utilization['credit_limit'] * 100).round(2)
                
                # High utilization cards (> 80%)
                high_util = utilization[utilization['utilization_pct'] > 80]
                
                col1, col2 = st.columns(2)
                
                with col1:
                    st.metric("High Utilization Cards (>80%)", f"{len(high_util)}")
                
                with col2:
                    avg_util = utilization['utilization_pct'].mean()
                    st.metric("Average Utilization", f"{avg_util:.2f}%")
                
                # Utilization distribution
                fig = px.histogram(utilization, x='utilization_pct',
                                 title='Credit Utilization Distribution',
                                 nbins=30,
                                 labels={'utilization_pct': 'Utilization (%)'})
                fig.update_layout(height=400)
                st.plotly_chart(fig, use_container_width=True)
        
        st.markdown("---")
        
        # Transaction gap analysis (churn detection)
        st.subheader("Customer Churn Risk (Transaction Gaps)")
        
        if transactions is not None:
            # Calculate gaps between transactions for each customer
            transactions_sorted = transactions.sort_values(['client_id', 'date'])
            transactions_sorted['prev_date'] = transactions_sorted.groupby('client_id')['date'].shift(1)
            transactions_sorted['gap_days'] = (transactions_sorted['date'] - transactions_sorted['prev_date']).dt.days
            
            # Customers with gaps > 30 days
            churn_risk = transactions_sorted[transactions_sorted['gap_days'] > 30]['client_id'].unique()
            
            col1, col2 = st.columns(2)
            col1.metric("At-Risk Customers (>30 day gap)", f"{len(churn_risk):,}")
            
            avg_gap = transactions_sorted[transactions_sorted['gap_days'].notna()]['gap_days'].mean()
            col2.metric("Average Transaction Gap", f"{avg_gap:.1f} days")

elif page == "📈 Advanced Analytics":
    st.title("📈 Advanced Analytics")
    st.markdown("---")
    
    if transactions is None or mcc is None:
        st.warning("Data not available for advanced analytics.")
    else:
        # Merchant category analysis
        st.subheader("Top Merchant Categories by Spending")
        
        # Join with MCC codes
        tx_with_mcc = transactions.merge(mcc, left_on='mcc', right_on='mcc_id', how='left')
        category_spend = tx_with_mcc[tx_with_mcc['amount'] > 0].groupby('description')['amount'].sum().nlargest(10)
        
        fig = px.bar(x=category_spend.values, y=category_spend.index,
                     orientation='h',
                     title='Top 10 Merchant Categories by Spending',
                     labels={'x': 'Total Spending ($)', 'y': 'Category'})
        fig.update_layout(height=500)
        st.plotly_chart(fig, use_container_width=True)
        
        st.markdown("---")
        
        # Monthly spending trend
        st.subheader("Monthly Spending Trend")
        
        transactions['month'] = transactions['date'].dt.to_period('M')
        monthly_spend = transactions[transactions['amount'] > 0].groupby('month')['amount'].sum().reset_index()
        monthly_spend['month'] = monthly_spend['month'].astype(str)
        
        fig = px.line(monthly_spend, x='month', y='amount',
                     title='Monthly Spending Trend',
                     labels={'month': 'Month', 'amount': 'Total Spending ($)'},
                     markers=True)
        fig.update_layout(height=400)
        st.plotly_chart(fig, use_container_width=True)
        
        st.markdown("---")
        
        # State-wise spending heatmap
        if transactions['merchant_state'].notna().sum() > 0:
            st.subheader("State-wise Spending Distribution")
            
            state_spend = transactions[transactions['merchant_state'].notna() & 
                                      (transactions['amount'] > 0)].groupby('merchant_state')['amount'].sum().nlargest(15)
            
            fig = px.bar(x=state_spend.index, y=state_spend.values,
                         title='Top 15 States by Spending',
                         labels={'x': 'State', 'y': 'Total Spending ($)'},
                         color=state_spend.values,
                         color_continuous_scale='Viridis')
            fig.update_layout(height=400)
            st.plotly_chart(fig, use_container_width=True)

# Footer
st.markdown("---")
st.markdown("""
<div style='text-align: center; color: #666;'>
    <p>Built with ❤️ using Streamlit | Banking Risk Analytics Dashboard</p>
</div>
""", unsafe_allow_html=True)
