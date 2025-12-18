
---

## Prerequisites

### Required
- A Google Cloud project with **BigQuery enabled**
- Permission to create:
  - Datasets
  - Views
  - Tables (or at minimum: tables in a personal dataset)
- The raw event exports loaded into BigQuery as **daily tables**:
  - `puffyproject.event_data.events_YYYYMMDD`  
  - Date range: `20250223` → `20250308`

## Setup (run once)

### 1) Create datasets

Run the following in BigQuery (or create these datasets via the UI), ensuring **location = `europe-west2`**:

```sql
CREATE SCHEMA IF NOT EXISTS `puffyproject.analytics_intermediate`
OPTIONS (location = "europe-west2", description = "Intermediate tables/views");

CREATE SCHEMA IF NOT EXISTS `puffyproject.analytics_marts`
OPTIONS (location = "europe-west2", description = "Analytics-ready marts");

CREATE SCHEMA IF NOT EXISTS `puffyproject.quality_checks`
OPTIONS (location = "europe-west2", description = "Data quality outputs");

CREATE SCHEMA IF NOT EXISTS `puffyproject.monitoring`
OPTIONS (location = "europe-west2", description = "Monitoring outputs");


All datasets created by this project **must be created in the same location**.

---

## Setup (run once)

### 1) Create required datasets

Run the following in BigQuery (or via the UI), ensuring the location is **`europe-west2`**:

```sql
CREATE OR REPLACE VIEW `puffyproject.analytics_intermediate.all_events` AS
SELECT
  PARSE_DATE('%Y%m%d', _TABLE_SUFFIX) AS event_date,
  _TABLE_SUFFIX AS source_table,
  *
FROM `puffyproject.event_data.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20250223' AND '20250308';

CREATE SCHEMA IF NOT EXISTS `puffyproject.monitoring`
OPTIONS (
  location = "europe-west2",
  description = "Daily monitoring and anomaly detection outputs"
);
```
### 1) Validate the View
```sql
SELECT
  event_date,
  COUNT(*) AS events
FROM `puffyproject.analytics_intermediate.all_events`
GROUP BY 1
ORDER BY 1;
```