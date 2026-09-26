# NGX Market Forecasting & Anomaly Detection — Insights & Recommendations

## Business Question

Can historical NGX price behavior be used to forecast near-term index movement, and can
unusual trading days be flagged automatically for risk monitoring?

## Methodology

Analysis of NGX All-Share Index daily closing prices from 2012 to 2026 (3,619 trading days).
Stationarity was tested using the Augmented Dickey-Fuller (ADF) test before fitting ARIMA. Two
forecasting approaches — ARIMA and Prophet — were trained on all but the final 30 trading days,
which were held out as a test set (never randomly split, since time series data requires
respecting chronological order). Anomaly detection was applied using a combined z-score and
Isolation Forest approach to flag statistically unusual trading days.

## Findings

### 1. Forecast Accuracy
ARIMA(1,1,1) achieved substantially lower forecast error than Prophet on the held-out test
period, with MAE of 2,829.21 and RMSE of 3,537.14 (MAPE of 1.17%), compared to Prophet's MAE
of 38,877.71 and RMSE of 38,966.09 (MAPE of 15.95%). This suggests ARIMA's short-horizon
persistence behavior extrapolated recent price momentum effectively during a period of
near-parabolic growth, while Prophet's changepoint-based trend model was more conservative
about continuing an accelerating trend — leading to systematic underforecasting. Increasing
Prophet's trend flexibility (`changepoint_prior_scale` from 0.05 to 0.5) only marginally
improved its MAPE (16.30% → 15.95%), confirming the gap is structural to how each model
handles strongly trending regimes rather than a tuning issue.

### 2. Volatility Patterns
Rolling 30-day volatility showed clear clustering across three periods: the sharpest sustained
volatility occurred in 2015-2016 (peaking near 0.024), a smaller cluster appeared around 2020
(coinciding with the global COVID-19 market shock), and a renewed spike emerged in 2023-2024 —
notably coinciding with the start of the index's dramatic price appreciation from roughly
50,000 to 250,000. Despite reaching all-time-high price levels through 2025-2026, volatility
during this period moderated back toward 2012-2019 levels, suggesting the rally itself has
been comparatively orderly rather than chaotic.

### 3. Anomalies Detected
103 trading days were flagged as anomalous out of 3,619 total — 2.85% of all trading days
(77 flagged by the z-score method, 72 by Isolation Forest, with 98.4% agreement between the
two and 46 days flagged by both). Anomalies appear throughout the full sample rather than
concentrating in one period, but show a visible increase in frequency from 2023 onward,
coinciding with the index's near-parabolic rally. The most extreme single-day moves were a
+8.31% surge on 2015-04-01, a +6.23% gain on 2020-11-12, and a -5.47% drop on 2025-11-11 — the
latter occurring while the index was trading near all-time highs (₦141,327), making it the
largest single-day decline in the dataset.

## Recommendations

1. **Use the ARIMA forecast as a directional signal, not a precise price target.** A MAPE of
   1.17% indicates the model captures near-term direction and magnitude well over a 30-day
   horizon, but forecasting accuracy at this level should still inform trend-following risk
   assessment rather than precise trading decisions, especially given how sensitive both
   models were to the underlying trend regime.

2. **Deploy the combined anomaly-detection approach as an early-warning layer for risk
   monitoring.** With anomaly frequency increasing during the 2023-2026 rally and the largest
   single-day drop in the dataset occurring near an all-time high, a similar system running in
   near-real-time could flag unusual market behavior — particularly sharp reversals at market
   peaks — faster than manual chart review would catch it.

3. **Re-run and re-fit periodically, and re-evaluate Prophet if the trend regime changes.**
   Prophet's underperformance was specific to this period's near-parabolic growth; if the
   market enters a calmer, more range-bound regime, Prophet's seasonality handling may become
   more competitive with ARIMA. Recommend re-fitting both models on a rolling basis (e.g.
   monthly or quarterly) rather than treating this as a one-time comparison.

4. **Favor ARIMA as the primary forecasting model going forward, with Prophet retained for
   comparison.** Given the scale of ARIMA's outperformance in this analysis, it should be the
   default model for near-term forecasting, while Prophet remains useful as a secondary check
   in periods where trend behavior is less extreme.

## Limitations

This analysis uses price and volume data only — it does not incorporate macroeconomic
indicators (inflation, interest rates, oil prices, which materially affect the Nigerian
market), news sentiment, or order-book depth, all of which would likely improve forecast
accuracy. The anomaly detection approach flags statistical outliers in price movement; it does
not distinguish between anomalies caused by genuine market stress versus data artifacts (e.g.
thin holiday trading days), and the specific macro drivers behind the flagged anomaly dates
(e.g. 2025-11-11) have not been independently verified against news events.