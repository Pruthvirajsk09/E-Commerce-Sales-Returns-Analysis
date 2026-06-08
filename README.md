# 🛒 E-Commerce Sales & Returns Analysis

**Tools:** SQL (MySQL) · Python · Power BI  
**Domain:** E-Commerce / Retail Analytics  
**Dataset:** 5,000 orders · 22 attributes · Jan–Dec 2024  
**Author:** Pruthviraj Kadam  
🔗 [LinkedIn](https://www.linkedin.com/in/pruthviraj-kadam-patil/) | [GitHub](https://github.com/Pruthvirajsk09)

---

## 📌 Problem Statement

An Indian e-commerce platform is losing revenue due to high product return rates and unclear understanding of which categories, cities, and channels are actually profitable. The business needs a data-driven view of sales performance and return patterns to make pricing, marketing, and logistics decisions.

---

## 🎯 Business Objectives

| # | Business Question | Tool Used |
|---|---|---|
| 1 | Which category drives the most revenue? | SQL GROUP BY + Power BI Bar Chart |
| 2 | Which products have dangerously high return rates? | SQL CASE WHEN + Python Chart |
| 3 | Does COD payment cause more returns than UPI? | SQL comparison query |
| 4 | Which city and channel performs best? | SQL + Power BI Map/Bar |
| 5 | How do discounts affect profit margins? | SQL bands + Power BI Matrix |

---

## 📊 Key Findings

| Insight | Finding |
|---|---|
| Total Revenue | ₹9.47 Crore across 5,000 orders |
| Top Revenue Category | Electronics |
| Highest Return Rate | Fashion — 19.2% return rate |
| Revenue Lost to Returns | ₹1.63 Crore |
| COD vs UPI Returns | COD 21.7% vs UPI 13.5% — 60% higher |
| Best Acquisition Channel | Organic Search |
| Top City by Revenue | Delhi |
| High Discount Impact | 21%+ discount reduces margin significantly |

---

## 🗂️ Project Structure

```
ecommerce-sales-analysis/
│
├── data/
│   └── ecommerce_orders.csv       ← 5,000 order records
│
├── sql/
│   └── ecommerce_analysis.sql     ← 15+ SQL queries
│
├── ecommerce_eda.py               ← Python EDA + visualizations
│
├── docs/
│   ├── ecommerce_dashboard.png    ← Executive dashboard
│   ├── ecommerce_returns.png      ← Returns deep dive
│   ├── powerbi_page1.png          ← Power BI Page 1
│   ├── powerbi_page2.png          ← Power BI Page 2
│   └── powerbi_page3.png          ← Power BI Page 3
│
└── README.md
```

---

## 🛠️ Tool 1 — SQL (MySQL)

**Sections covered:**
- Business KPIs — total revenue, profit, AOV, return rate
- Monthly and quarterly revenue trends
- Category and subcategory performance
- Discount band impact on profit margin
- Return analysis — by category, reason, payment method
- City and channel performance
- Customer segmentation — one-time vs repeat vs loyal
- Advanced — LAG for MoM growth, window functions, CTEs

**Key query — Month over Month Revenue Growth:**
```sql
WITH monthly_revenue AS (
    SELECT Month, MIN(OrderDate) AS month_start,
           ROUND(SUM(Revenue), 0) AS revenue
    FROM ecommerce_orders GROUP BY Month
),
with_lag AS (
    SELECT Month, revenue,
           LAG(revenue) OVER (ORDER BY month_start) AS prev_month_revenue
    FROM monthly_revenue
)
SELECT Month, revenue, prev_month_revenue,
    ROUND((revenue - prev_month_revenue) * 100.0 / prev_month_revenue, 2) AS mom_growth_pct
FROM with_lag
WHERE prev_month_revenue IS NOT NULL;
```

**Why LAG here?** LAG is a window function that fetches the value from the previous row. This lets us compare current month revenue against last month in a single query — not possible with simple GROUP BY alone.

---

## 🐍 Tool 2 — Python

**Libraries:** Pandas, NumPy, Matplotlib, Seaborn

```python
import pandas as pd
df = pd.read_csv('data/ecommerce_orders.csv')

# Data profiling
print(df.shape)           # 5000 rows, 22 columns
print(df.isnull().sum())  # 0 missing values

# Key findings
print(f"Total Revenue : ₹{df['Revenue'].sum():,.0f}")
print(f"Return Rate   : {df['IsReturned'].mean():.1%}")
print(f"Avg Order Val : ₹{df['Revenue'].mean():,.0f}")

# Return rate by category
df.groupby('Category')['IsReturned'].mean().mul(100).sort_values(ascending=False)

# COD vs UPI return rate
df.groupby('PaymentMethod')['IsReturned'].mean().mul(100)
```

**6 Charts generated:**
1. Monthly revenue trend (bar + line combo)
2. Revenue by category
3. Return rate by category
4. Revenue by channel
5. Delivery speed vs customer rating heatmap
6. Quarterly revenue vs returns dual axis

### Python Dashboard Preview
![Executive Dashboard](docs/ecommerce_dashboard.png)
![Returns Analysis](docs/ecommerce_returns.png)

---

## 📊 Tool 3 — Power BI

**Power Query columns added:**
- `DiscountBand` — No Discount / Low / Medium / High
- `DeliverySpeed` — Express / Standard / Slow / Very Slow
- `RevenueFlag` — 1/0 for calculations

**DAX Measures:**
```dax
Total Revenue = SUM(ecommerce_orders[Revenue])

Return Rate % =
DIVIDE(
    CALCULATE(COUNTROWS(ecommerce_orders), ecommerce_orders[IsReturned] = 1),
    COUNTROWS(ecommerce_orders), 0
) * 100

Avg Order Value = AVERAGE(ecommerce_orders[Revenue])

Revenue Lost to Returns =
CALCULATE(SUM(ecommerce_orders[Revenue]), ecommerce_orders[IsReturned] = 1)
```

**Page 1 — Executive Overview**
- KPI Cards: Total Revenue, Total Profit, AOV, Return Rate %
- Bar chart: Revenue by Category
- Line chart: Monthly Revenue Trend
- Slicers: Category, City, Channel, Quarter

**Page 2 — Returns Analysis**
- Bar chart: Return rate by Category
- Bar chart: Return rate by Payment Method
- Bar chart: Return reasons breakdown
- Matrix: Category × Discount Band return rate heatmap

**Page 3 — City & Channel Performance**
- Bar chart: Revenue by City
- Bar chart: Revenue by Channel
- Scatter: Discount % vs Profit Margin
- Table: Top 10 customers by revenue

---

## 💡 Business Recommendations

1. **Reduce COD dependency** — COD return rate (21.7%) is 60% higher than UPI (13.5%). Incentivize prepaid orders with small discounts.
2. **Fashion category intervention** — 19.2% return rate. Improve size guides and product photos.
3. **Cap high discounts** — Orders with 21%+ discount have significantly lower margins. Set 20% maximum discount policy.
4. **Invest in Organic Search** — Top performing channel. SEO content for high-margin categories.

---

## 🚀 How to Run

```bash
git clone https://github.com/Pruthvirajsk09/ecommerce-sales-analysis
pip install pandas numpy matplotlib seaborn
python ecommerce_eda.py
```

---

## 📬 Connect

**Pruthviraj Kadam** | 📧 pruthvirajkadam009@gmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/pruthviraj-kadam-patil/) | [GitHub](https://github.com/Pruthvirajsk09)
