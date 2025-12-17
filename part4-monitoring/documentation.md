## Production Monitoring Framework

- Pipeline Health and Freshness

  - Latest event in all\_events table should be within expected window

  - Latest purchase event in orders\_all should be within expected window

  - Row counts for latest date should be within tolerance over baseline

* Key Commercial Data Health Indicators

  - Transaction\_id should be unique

  - Revenue should be >0 for all transactions

- Key Commercial Metrics

  - Pageviews/Add to Carts/Checkouts initiated should be within tolerance from baseline

  - Revenue/Orders/AOV should be within tolerance from baseline

* Key Conversion Rates

  - Add to Cart %, Checkout initiated %, checkout completed %, overall funnel conversion % should be within tolerance from baseline

- Attribution Coverage

  - % orders with atleast 1 touchpoint in 7-day look back should be within tolerance from baseline

* Bot Pollution

  - % of traffic coming from bots should be within tolerance from baseline


## Production Monitoring Detection

- Pipeline Health and Freshness

  - Events freshness: max(event\_ts) in all\_events for run\_date, **alert** if lag seen for >4-6 hours past expected close of day

  - Orders freshness: max(purchase\_ts) in orders\_all for run\_date, **alert** if lag seen for >4-6 hours past expected close of day

  - Daily Volume: total event count for run\_date, **alert** if volume +-30% from 28 day median (back test on 1 year data to check how many days would alert)

* Key Commercial Data Health Indicators

  - transaction\_id unique in orders\_all, **alert** if any duplicates seen

  - revenue > 0 for all transactions, **alert** if any transactions with 0 revenue seen

- Key Commercial Metrics

  - Pageviews/Add to Carts/Checkouts: **alert** if +- 40% vs 28-day median, backtest for 1 year data

  - Revenue/Orders/AOV: **alert** if +-40% vs 28-day median, backtest for 1 year data

* Key Conversion Rates

  - Add to Cart %, Checkout initiated %, checkout completed %, overall funnel conversion %: **alert** if +-50% vs 28-day median, backtest for 1 year data

- Attribution Coverage

  - % orders with at least 1 touchpoint in 7-day look back should be within tolerance from baseline: **alert** if +-40% vs 28-day median, backtest for 1 year data

* Bot Pollution

  - % of traffic coming from bots should be within tolerance from baseline: : **alert** if +-50% vs 28-day median, backtest for 1 year data


## Putting Alerts into Production

The code files in the Github repository show how we would set up tables for daily metrics and alerts. The alerts table would then feed into the BI tool to display the metrics that have been tagged as being above threshold.
