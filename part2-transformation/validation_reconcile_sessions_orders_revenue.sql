SELECT
  (SELECT SUM(revenue) FROM `analytics_intermediate.orders`) AS orders_revenue,
  (SELECT SUM(session_revenue) FROM `analytics_intermediate.sessions`) AS sessions_revenue;
