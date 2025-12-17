declare run_date date default date_sub(current_date(), interval 1 day);

with today as (
  select metric_name, metric_value
  from `puffyproject.monitoring.daily_metrics`
  where run_date = run_date
),
baseline as (
  select
    metric_name,
    approx_quantiles(metric_value, 100)[offset(50)] as median_28d
  from `puffyproject.monitoring.daily_metrics`
  where run_date between date_sub(run_date, interval 29 day) and date_sub(run_date, interval 1 day)
  group by 1
),
joined as (
  select
    t.metric_name,
    t.metric_value,
    b.median_28d,
    safe_divide(t.metric_value - b.median_28d, nullif(b.median_28d, 0)) as pct_diff
  from today t
  join baseline b using (metric_name)
)
insert into `puffyproject.monitoring.alerts`
select
  run_date,
  case
    when abs(pct_diff) >= 0.60 then 'CRITICAL'
    when abs(pct_diff) >= 0.40 then 'WARN'
    else null
  end as severity,
  metric_name,
  metric_value,
  median_28d as baseline_value,
  'deviation_vs_28d_median' as rule,
  concat('pct_diff=', cast(round(pct_diff*100, 1) as string), '%') as details
from joined
where metric_name in (
  'orders','revenue','aov',
  'page_views','add_to_cart','checkout_started','checkout_completed_events',
  'add_to_cart_rate','checkout_start_rate','checkout_completion_rate','full_funnel_rate',
  'events_missing_client_id_rate','bot_event_share'
)
and abs(pct_diff) >= 0.40;
