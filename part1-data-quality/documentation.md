The goal of this framework is to validate the integrity of raw event data at ingestion, before it is used in production analytics. The framework focuses on purchase events - to ensure that core metrics like revenue, orders and conversion rates are reliably obtained. 

The framework is designed to

- Identify specific data issues present in the data set provided for this assignment

- Detect similar event-tracking failures in the future


## What went wrong in the given data period

The current data set revealed data quality issues related to purchase events, which would then directly impact revenue dashboards

- Duplicate purchase events for the same order

  - `checkout_completed` was triggered more than once for the same `transaction_id. `A completed transaction should map to exactly one purchase event. Duplication indicates events misfiring - possibly due to retry logic or some other setup issues

- Conflicting revenue values for the same transaction

  - In multiple cases, the same `transaction_id` appeared with different revenue values across duplicated `checkout_completed` events. This indicates that the purchase event is being fired at different stages of the purchase (possibly before and after final basket calculation) and the true revenue to be attributed is therefore hard to discern.

## What we are checking for in the automated framework

This data quality framework validates raw purchase events before they are processed for production analytics. The 3 checks are

### 1. Required fields present

Every purchase event must include:

- A non-empty `transaction_id`

- A positive revenue value

### 2. Transaction ID uniqueness

Each `transaction_id` must appear only once in the purchase event stream

### 3. Consistent Order Value

All purchase events associated with the same `transaction_id` must report exactly the same revenue value. If this check fails, check 2 will almost always fail but having this check will enable in finding out the kind of failure we are dealing with
