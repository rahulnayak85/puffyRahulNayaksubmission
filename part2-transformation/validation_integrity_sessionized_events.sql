SELECT COUNT(*) AS events_missing_session_id
FROM `analytics_intermediate.sessionized_events`
WHERE session_id IS NULL OR session_id = '';
