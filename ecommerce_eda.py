"""
E-Commerce Sales & Returns Analysis — Python EDA
Author: Pruthviraj Kadam
Tools: Python, Pandas, Matplotlib, Seaborn
Dataset: 5,000 orders | Indian E-commerce Platform
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import seaborn as sns
import warnings
warnings.filterwarnings('ignore')

plt.rcParams.update({
    'figure.facecolor': '#F8F9FA', 'axes.facecolor': '#FFFFFF',
    'axes.spines.top': False, 'axes.spines.right': False,
    'font.family': 'DejaVu Sans', 'axes.titlesize': 13, 'axes.labelsize': 11,
})

df = pd.read_csv('data/ecommerce_orders.csv', parse_dates=['OrderDate'])
df['Month_Num'] = df['OrderDate'].dt.month

print("=" * 55)
print("  E-COMMERCE SALES ANALYSIS — PRUTHVIRAJ KADAM")
print("=" * 55)
print(f"Total Orders   : {len(df):,}")
print(f"Total Revenue  : ₹{df['Revenue'].sum():,.0f}")
print(f"Total Profit   : ₹{df['Profit'].sum():,.0f}")
print(f"Avg Order Value: ₹{df['Revenue'].mean():,.0f}")
print(f"Return Rate    : {df['IsReturned'].mean():.1%}")
print(f"Avg Rating     : {df['CustomerRating'].mean():.2f}/5\n")

# ── FIGURE 1: Executive Dashboard ─────────────────────────────────────────────
fig, axes = plt.subplots(2, 3, figsize=(18, 11))
fig.suptitle('E-Commerce Sales & Returns — Executive Dashboard', fontsize=16, fontweight='bold')
fig.patch.set_facecolor('#F0F4F8')

# 1A: Monthly revenue trend
ax = axes[0, 0]
monthly = df.groupby('Month_Num').agg(Revenue=('Revenue','sum'), Orders=('OrderID','count')).reset_index()
months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
ax.bar(monthly['Month_Num'], monthly['Revenue']/1e6, color='#2196F3', alpha=0.7, edgecolor='white')
ax.plot(monthly['Month_Num'], monthly['Revenue']/1e6, color='#E63946', marker='o', linewidth=2, markersize=5)
ax.set_xticks(range(1,13)); ax.set_xticklabels(months, rotation=45, fontsize=8)
ax.set_ylabel('Revenue (₹ Millions)'); ax.set_title('Monthly Revenue Trend', fontweight='bold')
ax.yaxis.set_major_formatter(mticker.FormatStrFormatter('₹%.1fM'))

# 1B: Revenue by Category
ax = axes[0, 1]
cat_rev = df.groupby('Category')['Revenue'].sum().sort_values(ascending=True)
colors = ['#E63946' if v == cat_rev.max() else '#457B9D' for v in cat_rev.values]
bars = ax.barh(cat_rev.index, cat_rev.values/1e6, color=colors, edgecolor='white', height=0.6)
for bar, val in zip(bars, cat_rev.values):
    ax.text(bar.get_width()+0.1, bar.get_y()+bar.get_height()/2,
            f'₹{val/1e6:.1f}M', va='center', fontsize=9, fontweight='bold')
ax.set_xlabel('Revenue (₹ Millions)'); ax.set_title('Revenue by Category', fontweight='bold')

# 1C: Return rate by category
ax = axes[0, 2]
ret = df.groupby('Category')['IsReturned'].mean().mul(100).sort_values(ascending=False)
colors_r = ['#E63946' if v > 15 else '#2A9D8F' for v in ret.values]
bars = ax.bar(ret.index, ret.values, color=colors_r, edgecolor='white', width=0.6)
for bar, val in zip(bars, ret.values):
    ax.text(bar.get_x()+bar.get_width()/2, bar.get_height()+0.2,
            f'{val:.1f}%', ha='center', fontsize=9, fontweight='bold')
ax.set_ylabel('Return Rate (%)'); ax.set_title('Return Rate by Category', fontweight='bold')
plt.setp(ax.get_xticklabels(), rotation=30, ha='right', fontsize=8)

# 1D: Channel revenue
ax = axes[1, 0]
ch = df.groupby('Channel')['Revenue'].sum().sort_values(ascending=False)
bars = ax.bar(ch.index, ch.values/1e6, color='#457B9D', edgecolor='white', width=0.6)
for bar, val in zip(bars, ch.values):
    ax.text(bar.get_x()+bar.get_width()/2, bar.get_height()+0.05,
            f'₹{val/1e6:.1f}M', ha='center', fontsize=9, fontweight='bold')
ax.set_ylabel('Revenue (₹ Millions)'); ax.set_title('Revenue by Channel', fontweight='bold')
plt.setp(ax.get_xticklabels(), rotation=30, ha='right', fontsize=8)

# 1E: City revenue
ax = axes[1, 1]
city = df.groupby('City')['Revenue'].sum().sort_values(ascending=True)
ax.barh(city.index, city.values/1e6, color='#2A9D8F', edgecolor='white', height=0.6)
for i, (idx, val) in enumerate(city.items()):
    ax.text(val/1e6+0.05, i, f'₹{val/1e6:.1f}M', va='center', fontsize=9)
ax.set_xlabel('Revenue (₹ Millions)'); ax.set_title('Revenue by City', fontweight='bold')

# 1F: Discount impact on margin
ax = axes[1, 2]
disc_bands = ['No Discount', 'Low (1-10%)', 'Medium (11-20%)', 'High (21%+)']
df['DiscBand'] = pd.cut(df['DiscountPct'], bins=[-1,0,10,20,100], labels=disc_bands)
disc = df.groupby('DiscBand', observed=True)['ProfitMarginPct'].mean()
colors_d = ['#2A9D8F','#E9C46A','#F4A261','#E63946']
bars = ax.bar(disc.index, disc.values, color=colors_d, edgecolor='white', width=0.6)
for bar, val in zip(bars, disc.values):
    ax.text(bar.get_x()+bar.get_width()/2, bar.get_height()+0.2,
            f'{val:.1f}%', ha='center', fontsize=10, fontweight='bold')
ax.set_ylabel('Avg Profit Margin (%)'); ax.set_title('Discount Band vs Profit Margin', fontweight='bold')
plt.setp(ax.get_xticklabels(), rotation=20, ha='right', fontsize=8)

plt.tight_layout()
plt.savefig('docs/ecommerce_dashboard.png', dpi=150, bbox_inches='tight', facecolor='#F0F4F8')
plt.close()
print("✅ Saved: docs/ecommerce_dashboard.png")

# ── FIGURE 2: Returns Deep Dive ────────────────────────────────────────────────
fig, axes = plt.subplots(2, 2, figsize=(16, 11))
fig.suptitle('E-Commerce Returns & Customer Analysis', fontsize=15, fontweight='bold')
fig.patch.set_facecolor('#F0F4F8')

# 2A: Return reasons
ax = axes[0, 0]
reasons = df[df['IsReturned']==1]['ReturnReason'].value_counts()
ax.barh(reasons.index, reasons.values, color='#E63946', edgecolor='white', height=0.6)
for i, val in enumerate(reasons.values):
    ax.text(val+1, i, str(val), va='center', fontsize=10, fontweight='bold')
ax.set_xlabel('Number of Returns'); ax.set_title('Return Reasons Breakdown', fontweight='bold')

# 2B: Return rate by payment method
ax = axes[0, 1]
pay = df.groupby('PaymentMethod')['IsReturned'].mean().mul(100).sort_values(ascending=False)
colors_p = ['#E63946' if v > 15 else '#457B9D' for v in pay.values]
bars = ax.bar(pay.index, pay.values, color=colors_p, edgecolor='white', width=0.55)
for bar, val in zip(bars, pay.values):
    ax.text(bar.get_x()+bar.get_width()/2, bar.get_height()+0.2,
            f'{val:.1f}%', ha='center', fontsize=10, fontweight='bold')
ax.set_ylabel('Return Rate (%)'); ax.set_title('Return Rate by Payment Method', fontweight='bold')
plt.setp(ax.get_xticklabels(), rotation=20, ha='right', fontsize=9)

# 2C: Delivery days vs rating heatmap
ax = axes[1, 0]
df['DelivBand'] = pd.cut(df['DeliveryDays'], bins=[0,2,5,8,15],
                          labels=['Express\n(1-2d)', 'Standard\n(3-5d)', 'Slow\n(6-8d)', 'Very Slow\n(9+d)'])
deliv = df.groupby(['DelivBand','CustomerRating'], observed=True).size().unstack(fill_value=0)
sns.heatmap(deliv, annot=True, fmt='d', cmap='RdYlGn', ax=ax,
            linewidths=0.5, cbar_kws={'label':'Order Count'})
ax.set_title('Delivery Speed vs Customer Rating', fontweight='bold')
ax.set_xlabel('Customer Rating (Stars)'); ax.set_ylabel('Delivery Speed')

# 2D: Q-o-Q revenue comparison
ax = axes[1, 1]
qtr = df.groupby('Quarter').agg(Revenue=('Revenue','sum'), Returns=('IsReturned','sum')).reset_index()
x = range(len(qtr))
w = 0.35
b1 = ax.bar([i-w/2 for i in x], qtr['Revenue']/1e6, width=w, label='Revenue (₹M)', color='#457B9D', edgecolor='white')
ax2 = ax.twinx()
ax2.plot(x, qtr['Returns'], color='#E63946', marker='o', linewidth=2, markersize=8, label='Returns Count')
ax.set_xticks(x); ax.set_xticklabels(qtr['Quarter'])
ax.set_ylabel('Revenue (₹ Millions)'); ax2.set_ylabel('Returns Count', color='#E63946')
ax.set_title('Quarterly Revenue vs Returns', fontweight='bold')
ax.legend(loc='upper left', frameon=False, fontsize=9)
ax2.legend(loc='upper right', frameon=False, fontsize=9)

plt.tight_layout()
plt.savefig('docs/ecommerce_returns.png', dpi=150, bbox_inches='tight', facecolor='#F0F4F8')
plt.close()
print("✅ Saved: docs/ecommerce_returns.png")

# ── KEY INSIGHTS ───────────────────────────────────────────────────────────────
print("\n" + "="*55)
print("  KEY BUSINESS INSIGHTS")
print("="*55)
top_cat  = df.groupby('Category')['Revenue'].sum().idxmax()
top_city = df.groupby('City')['Revenue'].sum().idxmax()
top_ch   = df.groupby('Channel')['Revenue'].sum().idxmax()
high_ret = df.groupby('Category')['IsReturned'].mean().idxmax()
cod_ret  = df[df['PaymentMethod']=='COD']['IsReturned'].mean()*100
upi_ret  = df[df['PaymentMethod']=='UPI']['IsReturned'].mean()*100
print(f"\n1. Top revenue category : {top_cat}")
print(f"2. Top city             : {top_city}")
print(f"3. Best channel         : {top_ch}")
print(f"4. Highest return cat   : {high_ret} ({df[df['Category']==high_ret]['IsReturned'].mean():.1%})")
print(f"5. COD return rate      : {cod_ret:.1f}% vs UPI: {upi_ret:.1f}%")
print(f"6. Revenue lost to returns: ₹{df[df['IsReturned']==1]['Revenue'].sum():,.0f}")
print("\n✅ Complete. Load ecommerce_orders.csv into Power BI for dashboard.")
