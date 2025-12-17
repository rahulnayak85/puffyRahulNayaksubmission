declare v_run_date date default date_sub(current_date(), interval 1 day);

-- Idempotency: clear metrics for that run date
delete from `puffyproject.monitoring.daily_metrics`
where run_date = v_run_date;

-- Insert metrics (WITH must be inside the INSERT statement)
insert into `puffyproject.monitoring.daily_metrics` (run_date, metric_name, metric_value, notes)
with ev as (
  select
    event_date,
    event_name,
    clientId,
    timestamp as event_ts,
    user_agent
  from `puffyproject.analytics_intermediate.all_events`
  where event_date = v_run_date
),
ev_counts as (
  select
    count(*) as total_events,
    countif(event_name = 'page_viewed') as page_views,
    countif(event_name = 'product_added_to_cart') as add_to_cart,
    countif(event_name = 'checkout_started') as checkout_started,
    countif(event_name = 'checkout_completed') as checkout_completed_events,
    countif(clientId is null) as events_missing_client_id,
    countif(regexp_contains(lower(user_agent),
      r'adsbot-google|googlebot|bingbot|duckduckbot|slurp|semrushbot|ahrefsbot'
    )) as bot_events,
    max(event_ts) as max_event_ts
  from ev
),
orders_counts as (
  select
    count(*) as orders,
    sum(revenue) as revenue,
    safe_divide(sum(revenue), count(*)) as aov,
    max(purchase_ts) as max_purchase_ts
  from `puffyproject.analytics_intermediate.orders_all`
  where purchase_date = v_run_date
)
select v_run_date, metric_name, metric_value, notes
from (
  -- Freshness (store as unix seconds for easy comparisons later)
  select 'max_event_ts_unix' as metric_name,
         cast(unix_seconds(max_event_ts) as float64) as metric_value,
         'freshness' as notes
  from ev_counts

  union all
  select 'max_purchase_ts_unix',
         cast(unix_seconds(max_purchase_ts) as float64),
         'freshness'
  from orders_counts

  -- Volumes
  union all select 'total_events', cast(total_events as float64), 'all_events' from ev_counts
  union all select 'page_views', cast(page_views as float64), 'all_events' from ev_counts
  union all select 'add_to_cart', cast(add_to_cart as float64), 'all_events' from ev_counts
  union all select 'checkout_started', cast(checkout_started as float64), 'all_events' from ev_counts
  union all select 'checkout_completed_events', cast(checkout_completed_events as float64), 'all_events' from ev_counts

  union all select 'orders', cast(orders as float64), 'orders_all' from orders_counts
  union all select 'revenue', cast(revenue as float64), 'orders_all' from orders_counts
  union all select 'aov', cast(aov as float64), 'orders_all' from orders_counts

  -- Rates
  union all select 'add_to_cart_rate',
    safe_divide(cast(add_to_cart as float64), cast(page_views as float64)),
    'add_to_cart/page_views'
  from ev_counts

  union all select 'checkout_start_rate',
    safe_divide(cast(checkout_started as float64), cast(add_to_cart as float64)),
    'checkout_started/add_to_cart'
  from ev_counts

  union all select 'checkout_completion_rate',
    safe_divide(cast(checkout_completed_events as float64), cast(checkout_started as float64)),
    'checkout_completed/checkout_started'
  from ev_counts

  union all select 'full_funnel_rate',
    safe_divide(cast(checkout_completed_events as float64), cast(page_views as float64)),
    'checkout_completed/page_views'
  from ev_counts

  union all select 'events_missing_client_id_rate',
    safe_divide(cast(events_missing_client_id as float64), cast(total_events as float64)),
    'missing clientId / all events'
  from ev_counts

  union all select 'bot_event_share',
    safe_divide(cast(bot_events as float64), cast(total_events as float64)),
    'bot_events / all events'
  from ev_counts

  -- Reconciliation (orders vs checkout_completed event count)
  union all
  select 'orders_to_checkout_completed_ratio',
    safe_divide(cast(orders as float64), cast(checkout_completed_events as float64)),
    'orders_all / checkout_completed_events'
  from ev_counts, orders_counts
);
