-- FAILURES: same transaction_id has multiple revenue values across purchase events
SELECT
  JSON_VALUE(event_data, '$.transaction_id') AS transaction_id,
  COUNT(*) AS purchase_event_count,
  COUNT(DISTINCT SAFE_CAST(JSON_VALUE(event_data, '$.revenue') AS FLOAT64)) AS distinct_revenue_values,
  ARRAY_AGG(
    SAFE_CAST(JSON_VALUE(event_data, '$.revenue') AS FLOAT64)
    ORDER BY timestamp
  ) AS revenue_sequence,
  MIN(timestamp) AS first_seen_ts,
  MAX(timestamp) AS last_seen_ts
FROM `analytics_intermediate.all_events`
WHERE event_name = 'checkout_completed'
  AND JSON_VALUE(event_data, '$.transaction_id') IS NOT NULL
  AND JSON_VALUE(event_data, '$.transaction_id') != ''
  AND SAFE_CAST(JSON_VALUE(event_data, '$.revenue') AS FLOAT64) IS NOT NULL
GROUP BY 1
HAVING distinct_revenue_values > 1
ORDER BY distinct_revenue_values DESC, purchase_event_count DESC;
