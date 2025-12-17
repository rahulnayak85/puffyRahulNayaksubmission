create schema if not exists `puffyproject.monitoring`;

create table if not exists `puffyproject.monitoring.daily_metrics` (
  run_date date,
  metric_name string,
  metric_value float64,
  notes string,
  created_at timestamp default current_timestamp()
);

create table if not exists `puffyproject.monitoring.alerts` (
  run_date date,
  severity string,         -- 'WARN' | 'CRITICAL'
  metric_name string,
  metric_value float64,
  baseline_value float64,
  rule string,
  details string,
  created_at timestamp default current_timestamp()
);
