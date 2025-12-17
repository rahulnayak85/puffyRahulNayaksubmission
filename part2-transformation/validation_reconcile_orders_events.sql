-- Orders revenue should equal deduped purchase revenue from events
WITH deduped_purchases AS (
  SELECT
    transaction_id,
    MAX(revenue) AS revenue
  FROM `analytics_intermediate.events_clean`
  WHERE event_name = 'checkout_completed'
    AND transaction_id IS NOT NULL AND transaction_id != ''
    AND revenue IS NOT NULL
  GROUP BY 1
)
SELECT
  (SELECT COUNT(*) FROM `analytics_intermediate.orders`) AS orders_table_orders,
  (SELECT SUM(revenue) FROM `analytics_intermediate.orders`) AS orders_table_revenue,
  (SELECT COUNT(*) FROM deduped_purchases) AS deduped_event_orders,
  (SELECT SUM(revenue) FROM deduped_purchases) AS deduped_event_revenue;
