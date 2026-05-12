# 🚗 Vehicle Health & Maintenance Analysis System

> **End-to-End Data Analytics Project** | Python · SQL Server · Power BI

---

## 📌 Project Overview

A full-stack data analytics solution built to simulate and analyze a real-world fleet management scenario across 500 vehicles, 200 drivers, and 5 Indian metro cities. The project spans the complete data lifecycle — from synthetic data generation and cleaning in Python, through relational querying in SQL, to executive-ready dashboards in Power BI.

**Total dataset:** 15,000+ rows across 5 normalized tables  
**Timeframe modeled:** January 2021 – 2024  
**Domain:** Fleet Operations & Predictive Maintenance

---

## 🎯 Business Problem

Fleet managers operating large vehicle pools struggle with:
- Identifying high-risk vehicles before breakdowns occur
- Tracking overdue maintenance and its correlation to operational cost
- Monitoring fuel efficiency degradation across brands and fuel types
- Prioritizing unresolved alerts by severity in real time

This project builds the analytical infrastructure to answer all four challenges with data.

---

## 🛠️ Tech Stack

| Layer | Tool | Purpose |
|---|---|---|
| Data Generation & Cleaning | Python (Pandas, NumPy, Faker) | Synthetic data, null injection, feature engineering |
| Data Warehouse | PostgreSQL (SQL Server syntax) | Relational schema, 20 analytical queries |
| Visualization | Power BI + DAX | 4-page interactive dashboard |

---

## 📁 Project Structure

```
vehicle-maintenance-analytics/
│
├── data/
│   ├── raw/                    # Synthetically generated CSVs
│   │   ├── vehicles.csv
│   │   ├── drivers.csv
│   │   ├── maintenance.csv
│   │   ├── fuel_logs.csv
│   │   └── alerts.csv
│   └── clean/                  # Cleaned & feature-engineered CSVs
│
├── notebooks/
│   └── Data_Analytics.ipynb    # Full Python pipeline (generation + cleaning)
│
├── sql/
│   └── SQL_Queries.sql         # 20 analytical queries (basic → advanced)
│
├── powerbi/
│   └── Vehicle_Dashboard.pbix  # 4-page interactive Power BI report
│
└── README.md
```

---

## 🐍 Phase 1 — Data Generation & Cleaning (Python)

### Dataset Schema

| Table | Rows | Key Columns |
|---|---|---|
| `vehicles` | 500 | vehicle_id, make, fuel_type, odometer_km, city |
| `drivers` | 200 | driver_id, driver_name, experience |
| `maintenance` | 6,000 | service_type, cost_inr, overdue_flag, vendor |
| `fuel_logs` | 7,000 | litres, km_driven, km_per_litre, cost_inr |
| `alerts` | 1,300 | alert_type, severity, resolved, fault_code |

### Data Cleaning Steps

For each table, the pipeline intentionally injects nulls (3–6% per column) and applies systematic cleaning:

- **Duplicates:** `drop_duplicates()` across all tables
- **Null handling:** Median imputation for numeric columns (cost_inr, odometer_km, litres), mode/default fill for categoricals
- **Type enforcement:** `pd.to_datetime()` with `errors='coerce'`, `pd.to_numeric()` with coercion
- **Outlier capping:** Maintenance costs capped at 99th percentile; fuel efficiency filtered to 5–35 km/l range
- **String normalization:** `.str.strip().str.title()` / `.str.upper()` on all categorical text fields

### Feature Engineering

| Table | New Features |
|---|---|
| vehicles | `vehicle_age`, `age_group` (bins: New/Mid/Old/VeryOld) |
| maintenance | `service_year`, `service_month`, `month_name`, `quarter` |
| fuel_logs | `fill_year`, `fill_month`, `cost_per_km`, recalculated `km_per_litre` |
| alerts | `alert_year`, `alert_month`, `status` (Open/Resolved) |

**Final cleaned rows:** 500 + 200 + 5,820 + 6,614 + 1,300 = **14,434 rows** (after deduplication and null-date drops)

---

## 🗄️ Phase 2 — SQL Analysis (PostgreSQL)

20 queries progressing from basic aggregations to advanced window functions, covering:

### Query Categories

**Basic Aggregations (Q1–Q5)**
- Fleet count and average odometer by fuel type
- Total and average maintenance cost by service type
- Top 10 most expensive vehicles
- Monthly maintenance cost trend (24-month window)
- Overdue service rate by vehicle make

**Joins & Multi-table (Q6–Q12)**
- Average fuel efficiency (km/l) and total fuel cost by brand
- Alert count breakdown by severity (HIGH / MEDIUM / LOW)
- Top 10 drivers by overdue service count
- Vehicles with unresolved HIGH-severity alerts by city
- Yearly maintenance cost comparison
- Maintenance cost distribution by city
- Fuel cost trend and efficiency by year

**Window Functions (Q13–Q15)**
- Cumulative maintenance cost per vehicle over time (`SUM OVER PARTITION BY`)
- Vehicle cost rank using `RANK() OVER`
- Month-over-month cost change using `LAG()`

**Advanced & CTEs (Q16–Q20)**
- Vehicles with zero maintenance records (LEFT JOIN + IS NULL)
- Most common fault codes with open-issue counts
- Fuel efficiency segmented by fuel type and year
- Fleet health summary using dual CTEs (`maint_summary` + `alert_summary`)
- Quarterly cost share with percentage contribution

---

## 📊 Phase 3 — Power BI Dashboard

Four interconnected report pages built with DAX measures and cross-page filters.

### Page 1 — Vehicle Health & Maintenance Analysis (Overview)

**KPI Cards:**
- Total Vehicles: **500**
- Total Services: **6K**
- Total Maintenance Cost: **₹59.83M**
- Overdue %: **28.64%** (highlighted in amber as a risk signal)

**Visuals:**
- Horizontal bar chart: Total Maintenance Cost by Make (Hyundai & Toyota lead at ~₹9.5M each)
- Donut chart: Fleet composition by Fuel Type (Petrol 44.97% · Diesel 39.81% · CNG 15.23%)

**Key Insight:** Nearly 1 in 3 services is overdue, representing a significant operational risk.

---

### Page 2 — Maintenance Analysis (Deep Dive)

**KPI Cards:**
- Total Maintenance Cost: ₹59.83M
- Average Service Cost per Vehicle: ₹10.28K

**Visuals:**
- Bar chart: Top 10 vehicles by total maintenance cost (VH214 leads at ₹270K)
- Bar chart: Maintenance cost by service type — costs evenly distributed ₹6.8M–₹8.0M across all 8 service types
- Table: Top 10 high-risk vehicles ranked by Overdue % and Vehicle Risk Score (VH344 at 71.4% overdue, risk score 50.9)

**Key Insight:** High-risk vehicles are concentrated in Pune, Delhi, and Kolkata — indicating location-based operational inefficiencies.

---

### Page 3 — Fuel Efficiency

**KPI Cards:**
- Avg Fuel Efficiency: **13.78 km/l**
- Total Fuel Cost: **₹24.79M**
- Cost per KM: **₹8.21**

**Visuals:**
- Bar chart: Average distance per vehicle by make (Toyota leads at 109K km)
- Bar chart: Fuel efficiency by mileage segment (peaks at 100K–150K at 12.45 km/l)
- Matrix table: Fuel type comparison — CNG has highest avg efficiency (14.18 km/l), Petrol lowest (13.55)
- Bar chart: Operating cost per KM by brand (Mahindra highest at ₹8.4, Ford lowest at ₹8.1)

**Key Insight:** Fuel cost per KM is stable across all brands (₹8.1–₹8.4), indicating consistent fleet utilization regardless of make.

---

### Page 4 — Alerts & Risk Management

**KPI Cards:**
- Total Alerts: **843**
- Open Alerts: **457**
- Critical Open Alerts: **122**

**Visuals:**
- Table: Top 10 drivers by overdue % (Kevin Dewan at 55.56% — highest risk driver)
- Donut chart: Alert severity split (HIGH 29.77% · MEDIUM 40.93% · LOW 29.3%)
- Bar chart: Alert distribution by fuel type (Petrol 315, Diesel 313, CNG 146, Electric 69)
- Table: Top 10 high-risk vehicles by Vehicle Risk Score (VH247 at 62.8%)

**Key Insight:** 457 open alerts with 122 classified as HIGH severity indicate a critical backlog requiring immediate triage.

---

## 📈 Key Business Findings

| Finding | Metric |
|---|---|
| Fleet overdue service rate | 28.64% — nearly 1 in 3 services delayed |
| Highest-cost vehicle | VH214 at ₹2,70,000 total maintenance |
| Highest-risk vehicle | VH344 — 71.4% overdue, Pune (Hyundai) |
| Most overdue driver | Kevin Dewan — 55.56% overdue rate |
| Optimal mileage band | 100K–150K km yields best fuel efficiency (12.45 km/l) |
| Unresolved critical alerts | 122 HIGH-severity alerts still open |
| Cost distribution | Service costs spread evenly across all 8 types (~₹7M–₹8M each) |

---

## ▶️ How to Run

### Python (Data Generation & Cleaning)
```bash
pip install pandas numpy faker
jupyter notebook notebooks/Data_Analytics.ipynb
```
Run cells sequentially: Data Generation → Data Cleaning → exports to `data/clean/`

### SQL
Load the cleaned CSVs into your PostgreSQL or SQL Server instance, then execute queries from `sql/SQL_Queries.sql` in order.

### Power BI
Open `powerbi/Vehicle_Dashboard.pbix` in Power BI Desktop. Refresh data source paths to point to your `data/clean/` directory.

---

## 🧠 Skills Demonstrated

- Synthetic dataset design with realistic distributions and domain constraints
- Multi-table data cleaning pipeline with null injection and systematic treatment
- Feature engineering (binning, datetime decomposition, ratio derivation)
- SQL window functions: `RANK()`, `LAG()`, `SUM() OVER (PARTITION BY ...)`
- CTE-based multi-step aggregation
- Power BI DAX measures for KPIs, risk scoring, and overdue percentage
- Cross-page filtering and drill-through in Power BI
- Translating raw data patterns into actionable fleet management insights

---

## 👤 Author

**V. Manikanta**  
Data Analyst | Innomatics Research Labs  
📧 vmanikanta1015@gmail.com  
🔗 [linkedin.com/in/manikanta1015](https://linkedin.com/in/manikanta1015)

---

*Project built as part of end-to-end data analytics training at Innomatics Research Labs.*
