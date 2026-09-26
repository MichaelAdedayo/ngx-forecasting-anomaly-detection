-- ============================================================================
-- NGX Market Forecasting & Anomaly Detection — SQL Queries
-- Assumes a table `ngx_prices` loaded from the cleaned CSV, with columns:
-- trade_date, open, high, low, close, volume, daily_return, is_anomaly
-- ============================================================================


-- ----------------------------------------------------------------------------
-- Q1: Yearly summary — average close, volatility (stddev of daily return), volume
-- ----------------------------------------------------------------------------
SELECT
    strftime('%Y', trade_date) AS year,
    ROUND(AVG(close), 2) AS avg_close,
    ROUND(MIN(close), 2) AS min_close,
    ROUND(MAX(close), 2) AS max_close,
    ROUND(AVG(daily_return) * 100, 3) AS avg_daily_return_pct,
    ROUND(
        (AVG(daily_return * daily_return) - AVG(daily_return) * AVG(daily_return)), 6
    ) AS return_variance,
    SUM(volume) AS total_volume
FROM ngx_prices
GROUP BY year
ORDER BY year;


-- ----------------------------------------------------------------------------
-- Q2: Largest single-day moves (up and down) — sanity check against anomaly flags
-- ----------------------------------------------------------------------------
SELECT trade_date, close, daily_return, is_anomaly
FROM ngx_prices
ORDER BY daily_return DESC
LIMIT 10;

SELECT trade_date, close, daily_return, is_anomaly
FROM ngx_prices
ORDER BY daily_return ASC
LIMIT 10;


-- ----------------------------------------------------------------------------
-- Q3: Anomaly frequency by year — are unusual trading days clustered in
-- particular periods (e.g. crisis years)?
-- ----------------------------------------------------------------------------
SELECT
    strftime('%Y', trade_date) AS year,
    COUNT(*) AS total_trading_days,
    SUM(CASE WHEN is_anomaly = 1 THEN 1 ELSE 0 END) AS anomaly_days,
    ROUND(
        100.0 * SUM(CASE WHEN is_anomaly = 1 THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS anomaly_pct
FROM ngx_prices
GROUP BY year
ORDER BY year;


-- ----------------------------------------------------------------------------
-- Q4: Rolling monthly volatility — which months were the most turbulent?
-- ----------------------------------------------------------------------------
SELECT
    strftime('%Y-%m', trade_date) AS year_month,
    ROUND(AVG(daily_return) * 100, 3) AS avg_daily_return_pct,
    COUNT(*) AS trading_days
FROM ngx_prices
GROUP BY year_month
ORDER BY year_month;
