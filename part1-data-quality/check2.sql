-- FAILURES: duplicated transaction_ids in purchase events
-- PURPOSE: to verify that each transaction is recorded only once in purchase events
-- PASS: No rows returned
-- SEVERITY: HIGH as duplicate purchases lead to over-counted orders and inflated revenue


SELECT
  JSON_VALUE(event_data, '$.transaction_id') AS transaction_id,
  COUNT(*) AS purchase_event_count,
  MIN(timestamp) AS first_seen_ts,
  MAX(timestamp) AS last_seen_ts
FROM `analytics_intermediate.all_events`
WHERE event_name = 'checkout_completed'
  AND JSON_VALUE(event_data, '$.transaction_id') IS NOT NULL
  AND JSON_VALUE(event_data, '$.transaction_id') != ''
GROUP BY 1
HAVING purchase_event_count > 1
ORDER BY purchase_event_count DESC, last_seen_ts DESC;
