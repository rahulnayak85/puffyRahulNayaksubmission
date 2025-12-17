CREATE OR REPLACE VIEW `analytics_intermediate.order_touchpoints_7d` AS
SELECT
  o.transaction_id,
  o.client_id,
  o.purchase_ts,
  o.revenue,

  s.session_id AS touch_session_id,
  s.session_start_ts AS touch_session_start_ts,

  s.session_source AS touch_source,
  s.session_medium AS touch_medium,
  s.session_campaign AS touch_campaign,
  s.affiliate_id AS touch_affiliate_id
FROM `analytics_intermediate.orders` o
JOIN `analytics_intermediate.sessions` s
  ON s.client_id = o.client_id
 AND s.session_start_ts BETWEEN TIMESTAMP_SUB(o.purchase_ts, INTERVAL 7 DAY) AND o.purchase_ts;
