CREATE OR REPLACE TABLE `analytics_intermediate.orders` AS
SELECT
  transaction_id,
  client_id,
  event_ts AS purchase_ts,
  DATE(event_ts) AS purchase_date,
  revenue,
  session_id AS purchase_session_id
FROM `analytics_intermediate.sessionized_events`
WHERE event_name = 'checkout_completed'
  AND transaction_id IS NOT NULL
  AND transaction_id != ''
  AND revenue IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY transaction_id
  ORDER BY revenue DESC, event_ts DESC
) = 1;
