SELECT COUNT(*) AS unattributed_orders
FROM `analytics_intermediate.orders` o
LEFT JOIN `analytics_intermediate.attribution_last_click` a
  USING (transaction_id)
WHERE a.transaction_id IS NULL;
