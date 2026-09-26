# NGX Market Forecasting & Anomaly Detection

A time series forecasting project on the Nigerian Exchange Group (NGX) All-Share Index,
combining classical forecasting (ARIMA, Prophet) with anomaly detection to flag unusual
trading days. Built as a direct extension of undergraduate thesis research on NGX volatility
prediction — this project applies forecasting rather than volatility classification, and adds
a practical anomaly-detection layer aimed at a risk/trading desk use case.

## Business Framing

> **Can historical NGX price behavior be used to forecast near-term index movement, and can
> unusual trading days be flagged automatically for risk monitoring?**

A bank or asset manager doesn't just want a chart of "the index went up" — they want two
concrete things: (1) a forecast of where the market is likely headed in the near term, and
(2) an early-warning signal when a trading day behaves abnormally (crash risk, unusual
volume, policy-shock reaction). This project builds both.

## Dataset

NGX All-Share Index historical daily data (Open, High, Low, Close, Volume), sourced from
Investing.com's Nigeria Stock Exchange historical data.

## Project Structure

```
ngx-forecasting-anomaly-detection/
├── README.md
├── requirements.txt
├── data/
│   └── ngx_all_share_index.csv       # not committed to git
├── notebooks/
│   ├── 01_data_cleaning.ipynb        # load, handle missing trading days, set datetime index
│   ├── 02_exploratory_analysis.ipynb # trend, seasonality, volatility clustering, stationarity
│   ├── 03_forecasting.ipynb          # ARIMA + Prophet, compared on a held-out test period
│   └── 04_anomaly_detection.ipynb    # flag unusual trading days
├── sql/
│   └── ngx_queries.sql               # descriptive queries on the cleaned price data
├── dashboard/
│   └── README.md                     # instructions for building the Power BI dashboard
├── visuals/
│   ├── price_trend.png
│   ├── rolling_volatility.png
│   ├── forecast_comparison.png
│   └── anomalies_flagged.png
└── reports/
    └── NGX_Insights.md               # findings + recommendations (export to PDF)
```

## Steps to Run

1. **Set up environment**
   ```bash
   python -m venv venv
   source venv/bin/activate        # Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

2. **Download the data** and place it in `data/ngx_all_share_index.csv`

3. **Run the notebooks in order** — `01` → `02` → `03` → `04`

4. **Build the dashboard** — follow `dashboard/README.md`

5. **Write up findings** in `reports/NGX_Insights.md`, export to PDF

## Why This Project Is Different From a Typical "Stock Prediction" Portfolio Project

Most beginner time series projects either (a) predict next-day price with a black-box LSTM and
report an impressive-looking but meaningless R², or (b) skip stationarity testing entirely.
This project deliberately does the fundamentals properly:
- **Stationarity testing (ADF test)** before fitting ARIMA — confirmed the raw price series is
  non-stationary (p = 1.0000) but becomes stationary after first-differencing (p ≈ 0.0000),
  justifying ARIMA(p, 1, q)
- **Time-respecting train/test split** — never a random split for time series data, since that
  leaks future information into training
- **Multiple models compared honestly** — including reporting where a more "sophisticated"
  model (Prophet) underperformed a simpler one (ARIMA), and explaining why, rather than only
  reporting whichever result looks best
- **Anomaly detection as a distinct, practically-motivated layer** — not just "here's a
  forecast," but "here's how you'd use this for risk monitoring"

## Key Results

Evaluated on a 30-day held-out test period (2026):

| Model | MAE | RMSE | MAPE |
|---|---|---|---|
| ARIMA(1,1,1) | 2,829.21 | 3,537.14 | **1.17%** |
| Prophet (tuned) | 38,877.71 | 38,966.09 | 15.95% |

**ARIMA substantially outperformed Prophet** on this test period. The test window falls within
a period of near-parabolic price growth (the index rose roughly 5x, from ~50,000 to ~250,000,
between 2023 and 2026). ARIMA's short-horizon persistence behavior extrapolates recent
momentum effectively in this kind of strongly trending regime, while Prophet's
changepoint-based trend model is inherently more conservative about continuing an accelerating
trend — leading to systematic underforecasting. Increasing Prophet's `changepoint_prior_scale`
from 0.05 to 0.5 (allowing a more flexible trend) only marginally improved its MAPE (16.30% →
15.95%), confirming the gap is structural to how each model handles this kind of trend, not a
tuning issue.

Volatility clustering was also evident in the exploratory analysis: the sharpest sustained
volatility appears in 2015-2016, a smaller cluster around 2020 (coinciding with the global
COVID-19 market shock), and a renewed spike in 2023-2024 — notably coinciding with the start
of the index's dramatic price appreciation. Despite reaching all-time-high price levels
through 2025-2026, volatility during this period has moderated back toward 2012-2019 levels,
suggesting the rally itself has been comparatively orderly rather than chaotic.

**Anomalies detected:** 103 trading days flagged as anomalous out of 3,619 total (2.85%),
using a combined z-score and Isolation Forest approach (77 flagged by z-score, 72 by
Isolation Forest, with 98.4% agreement between the two methods and 46 days flagged by both).
Anomalies appear throughout the sample rather than concentrated in a single period, but
notably cluster around the 2023-2024 rally onset and extend into 2025-2026 as the index
reached all-time highs — consistent with the volatility spike identified in the exploratory
analysis. The most extreme single-day moves include a **+8.31%** surge on 2015-04-01, a
**+6.23%** move on 2020-11-12, and a **-5.47%** drop on 2025-11-11 — the platform's largest
single-day decline in the dataset, occurring even as the index sat near record highs.

## Tech Stack

Python, Pandas, NumPy, Statsmodels, Prophet, Scikit-learn (Isolation Forest), Matplotlib,
Seaborn, Jupyter Notebook, SQL, Power BI

## Author

Michael Adedayo — [LinkedIn] · [GitHub]

*This project extends the analytical foundation of my undergraduate thesis, "Volatility Prediction Using Machine Learning Models: A Case Study of the Nigerian Exchange Group (NGX)."*