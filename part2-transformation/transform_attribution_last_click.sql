CREATE OR REPLACE VIEW `analytics_intermediate.attribution_last_click` AS
SELECT
  transaction_id,
  client_id,
  purchase_ts,
  revenue,
  touch_source AS attributed_source,
  touch_medium AS attributed_medium,
  touch_campaign AS attributed_campaign,
  touch_affiliate_id AS attributed_affiliate_id,
  touch_session_id AS attributed_session_id
FROM `analytics_intermediate.order_touchpoints_7d`
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY transaction_id
  ORDER BY touch_session_start_ts DESC
) = 1;
