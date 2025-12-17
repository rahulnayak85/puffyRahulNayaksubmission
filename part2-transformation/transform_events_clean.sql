CREATE OR REPLACE VIEW `analytics_intermediate.events_clean` AS
WITH base AS (
  SELECT
    timestamp AS event_ts,
    DATE(timestamp) AS event_date,
    client_id,
    event_name,
    event_data,
    page_url,
    user_agent,
    device_type,
    browser,
    os,

    -- Normalize common HTML-escaped ampersands (seen in your example)
    REPLACE(page_url, '&amp;', '&') AS page_url_norm
  FROM `analytics_intermediate.events_validated`
)

SELECT
  event_ts,
  event_date,
  client_id,
  event_name,
  event_data,
  page_url,

  user_agent,
  device_type,
  browser,
  os,

  -- Extract UTM params from URL query string
  NULLIF(REGEXP_EXTRACT(page_url_norm, r'(?i)[?&]utm_source=([^&#]+)'), '') AS utm_source,
  NULLIF(REGEXP_EXTRACT(page_url_norm, r'(?i)[?&]utm_medium=([^&#]+)'), '') AS utm_medium,
  NULLIF(REGEXP_EXTRACT(page_url_norm, r'(?i)[?&]utm_campaign=([^&#]+)'), '') AS utm_campaign,
  NULLIF(REGEXP_EXTRACT(page_url_norm, r'(?i)[?&]utm_content=([^&#]+)'), '') AS utm_content,
  NULLIF(REGEXP_EXTRACT(page_url_norm, r'(?i)[?&]utm_term=([^&#]+)'), '') AS utm_term,

  -- (Optional) grab other common marketing params you might want later
  NULLIF(REGEXP_EXTRACT(page_url_norm, r'(?i)[?&]msclkid=([^&#]+)'), '') AS msclkid,
  NULLIF(REGEXP_EXTRACT(page_url_norm, r'(?i)[?&]gclid=([^&#]+)'), '') AS gclid,
  NULLIF(REGEXP_EXTRACT(page_url_norm, r'(?i)[?&]fbclid=([^&#]+)'), '') AS fbclid,

  NULLIF(REGEXP_EXTRACT(page_url_norm, r'(?i)[?&]set_view=([^&#]+)'), '') AS set_view,
  NULLIF(REGEXP_EXTRACT(page_url_norm, r'(?i)[?&]oid=([^&#]+)'), '') AS order_id_param,
  NULLIF(REGEXP_EXTRACT(page_url_norm, r'(?i)[?&]affid=([^&#]+)'), '') AS affiliate_id,

-- Generic sub parameters (often reused by affiliates)
  NULLIF(REGEXP_EXTRACT(page_url_norm, r'(?i)[?&]sub1=([^&#]+)'), '') AS sub1,
  NULLIF(REGEXP_EXTRACT(page_url_norm, r'(?i)[?&]sub2=([^&#]+)'), '') AS sub2,
  NULLIF(REGEXP_EXTRACT(page_url_norm, r'(?i)[?&]sub3=([^&#]+)'), '') AS sub3,
  NULLIF(REGEXP_EXTRACT(page_url_norm, r'(?i)[?&]sub4=([^&#]+)'), '') AS sub4

  -- Purchase fields (only populated on checkout_completed)
  JSON_VALUE(event_data, '$.transaction_id') AS transaction_id,
  SAFE_CAST(JSON_VALUE(event_data, '$.revenue') AS FLOAT64) AS revenue
FROM base;
