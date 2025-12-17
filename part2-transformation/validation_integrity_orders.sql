SELECT
  COUNT(*) AS rows,
  COUNT(DISTINCT transaction_id) AS distinct_transactions
FROM `analytics_intermediate.orders`;
