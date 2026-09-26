# Building the Power BI Dashboard

## 1. Load the Data

Power BI Desktop → **Get Data** → **Text/CSV** → select the cleaned output from
`01_data_cleaning.ipynb` (e.g. `data/ngx_prices_clean.csv`, which should include `trade_date`,
`close`, `daily_return`, and `is_anomaly` columns produced across the notebooks).

## 2. Recommended Pages

**Page 1 — Overview**
- KPI cards: Latest Close, YTD Return %, Total Anomalies Detected, Data Range
- Line chart: Close price over the full date range

**Page 2 — Trend & Volatility**
- Line chart: Close price with a rolling 30-day moving average overlay
- Line chart: Rolling 30-day volatility (standard deviation of daily returns)

**Page 3 — Forecast**
- Line chart: Actual close price vs. ARIMA/Prophet forecast for the held-out test period
  (you'll need to bring in your forecast output CSV from notebook 03 as a second table)
- KPI cards: MAE, RMSE, MAPE for each model

**Page 4 — Anomaly Detection**
- Line chart: Close price with anomaly days highlighted (use a scatter overlay: line chart for
  price, plus a scatter/point visual filtered to `is_anomaly = 1` layered on top)
- Table: List of flagged anomaly dates with the price and return on that day
- Bar chart: Anomaly count by year, to show if they cluster around specific periods

## 3. Recommended DAX Measures

```dax
Latest Close = 
CALCULATE(MAX(ngx_prices_clean[close]), 
    ngx_prices_clean[trade_date] = MAX(ngx_prices_clean[trade_date]))

YTD Return % = 
DIVIDE(
    [Latest Close] - CALCULATE(MIN(ngx_prices_clean[close]), YEAR(ngx_prices_clean[trade_date]) = YEAR(TODAY())),
    CALCULATE(MIN(ngx_prices_clean[close]), YEAR(ngx_prices_clean[trade_date]) = YEAR(TODAY()))
)

Total Anomalies = 
CALCULATE(COUNTROWS(ngx_prices_clean), ngx_prices_clean[is_anomaly] = 1)

Avg Daily Volatility = 
STDEV.P(ngx_prices_clean[daily_return])
```

## 4. Add a Business-Insight Text Box

On the Overview page, summarize the top finding (e.g. "X anomaly days detected, clustering
around [period], coinciding with [macro event if known]") and one practical recommendation
for how a risk desk might use this signal.

## 5. Save and Screenshot

Save as `NGX_Dashboard.pbix` in this folder, and export screenshots of each page to
`../visuals/` since GitHub can't render `.pbix` files directly.
