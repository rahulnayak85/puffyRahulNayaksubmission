SELECT
  COUNT(*) AS rows,
  COUNT(DISTINCT session_id) AS distinct_sessions
FROM `analytics_intermediate.sessions`;
