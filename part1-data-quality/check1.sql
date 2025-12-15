-- FAILURES: purchase events missing transaction_id or revenue <= 0 / non-numeric
SELECT
  DATE(timestamp) AS event_date,
  COUNT(*) AS failing_events,
  ARRAY_AGG(
    STRUCT(
      JSON_VALUE(event_data, '$.transaction_id') AS transaction_id,
      SAFE_CAST(JSON_VALUE(event_data, '$.revenue') AS FLOAT64) AS revenue,
      timestamp AS event_ts
    )
    ORDER BY timestamp
    LIMIT 20
  ) AS sample_rows
FROM `analytics_intermediate.all_events`
WHERE event_name = 'checkout_completed'
  AND (
    JSON_VALUE(event_data, '$.transaction_id') IS NULL
    OR JSON_VALUE(event_data, '$.transaction_id') = ''
    OR SAFE_CAST(JSON_VALUE(event_data, '$.revenue') AS FLOAT64) IS NULL
    OR SAFE_CAST(JSON_VALUE(event_data, '$.revenue') AS FLOAT64) <= 0
  )
GROUP BY 1
ORDER BY event_date;
