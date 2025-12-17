CREATE OR REPLACE TABLE `analytics_intermediate.sessions` AS
WITH base AS (
  SELECT * FROM `analytics_intermediate.sessionized_events`
),

session_attrs AS (
  SELECT
    session_id,
    ANY_VALUE(client_id) AS client_id,
    MIN(event_ts) AS session_start_ts,
    MAX(event_ts) AS session_end_ts,
    DATE(MIN(event_ts)) AS session_date,
    -- Session-level marketing dims: take first non-null values seen in the session
    ARRAY_AGG(utm_source IGNORE NULLS ORDER BY event_ts LIMIT 1)[OFFSET(0)] AS session_source,
    ARRAY_AGG(utm_medium IGNORE NULLS ORDER BY event_ts LIMIT 1)[OFFSET(0)] AS session_medium,
    ARRAY_AGG(utm_campaign IGNORE NULLS ORDER BY event_ts LIMIT 1)[OFFSET(0)] AS session_campaign,
    ARRAY_AGG(utm_content IGNORE NULLS ORDER BY event_ts LIMIT 1)[OFFSET(0)] AS session_content,
    ARRAY_AGG(utm_term IGNORE NULLS ORDER BY event_ts LIMIT 1)[OFFSET(0)] AS session_term,

    -- Optional: keep partner identifiers for deeper analysis if needed
    ARRAY_AGG(affiliate_id IGNORE NULLS ORDER BY event_ts LIMIT 1)[OFFSET(0)] AS affiliate_id,
    ARRAY_AGG(sub1 IGNORE NULLS ORDER BY event_ts LIMIT 1)[OFFSET(0)] AS sub1,
    ARRAY_AGG(sub2 IGNORE NULLS ORDER BY event_ts LIMIT 1)[OFFSET(0)] AS sub2,
    ARRAY_AGG(sub3 IGNORE NULLS ORDER BY event_ts LIMIT 1)[OFFSET(0)] AS sub3,
    ARRAY_AGG(sub4 IGNORE NULLS ORDER BY event_ts LIMIT 1)[OFFSET(0)] AS sub4,
  FROM base
  WHERE session_id IS NOT NULL AND session_id != ''
  GROUP BY session_id
),

session_event_metrics AS (
  SELECT
    session_id,
    COUNTIF(event_name = 'page_viewed') AS pageviews,
    COUNTIF(event_name = 'product_added_to_cart') AS atc_count,
    COUNTIF(event_name = 'checkout_started') AS checkout_started_count
  FROM base
  WHERE session_id IS NOT NULL AND session_id != ''
  GROUP BY session_id
),

session_order_metrics AS (
  SELECT
    purchase_session_id AS session_id,
    COUNT(*) AS purchase_count,
    SUM(revenue) AS session_revenue
  FROM `analytics_intermediate.orders`
  GROUP BY 1
)

SELECT
  a.*,
  e.pageviews,
  e.atc_count,
  e.checkout_started_count,
  COALESCE(o.purchase_count, 0) AS purchase_count,
  COALESCE(o.session_revenue, 0) AS session_revenue,
  (COALESCE(o.purchase_count, 0) > 0) AS has_purchase
FROM session_attrs a
LEFT JOIN session_event_metrics e USING (session_id)
LEFT JOIN session_order_metrics o USING (session_id);