SELECT
  (SELECT SUM(revenue) FROM `analytics_intermediate.orders`) AS orders_revenue,
  (SELECT SUM(revenue) FROM `analytics_intermediate.attribution_first_click`) AS first_click_revenue,
  (SELECT SUM(revenue) FROM `analytics_intermediate.attribution_last_click`) AS last_click_revenue;
