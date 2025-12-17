CREATE OR REPLACE VIEW `analytics_intermediate.sessionized_events` AS
WITH ordered AS (
  SELECT
    *,
    LAG(event_ts) OVER (PARTITION BY client_id ORDER BY event_ts) AS prev_event_ts
  FROM `analytics_intermediate.events_clean`
),
flagged AS (
  SELECT
    *,
    CASE
      WHEN prev_event_ts IS NULL THEN 1
      WHEN TIMESTAMP_DIFF(event_ts, prev_event_ts, MINUTE) > 30 THEN 1
      ELSE 0
    END AS is_new_session
  FROM ordered
),
numbered AS (
  SELECT
    *,
    SUM(is_new_session) OVER (PARTITION BY client_id ORDER BY event_ts) AS session_number
  FROM flagged
)
SELECT
  *,
  CONCAT(client_id, '-', CAST(session_number AS STRING)) AS session_id
FROM numbered;
