## Sessionization

Sessions are defined per user (`client_id`) using a 30-minute inactivity timeout:

- Events are ordered by `timestamp` for each user.

- A new session starts when there is no previous event for that user, or when the time gap between consecutive events exceeds 30 minutes.

- All subsequent events within the inactivity window are assigned to the same session.

Each session is assigned a stable `session_id` derived from the user identifier and session sequence number, and session-level attributes (such as traffic source, device, and landing page) are taken from the first event in the session.


## Metrics and Attributes

### Session-level metrics

These summarise engagement and conversion behaviour within a visit:

- number of page views

- add-to-cart count

- checkout started count

- purchase flag (whether a purchase occurred in the session)

- session revenue (revenue attributed to purchases in the session)

These metrics allow analysis of engagement, funnel progression, and conversion rates by channel, device, and landing page.


## User+Session Attributes

### User attributes

- client\_id

- session\_id

- session start and end timestamps

- session date


### Marketing attributes

- traffic source, medium, and campaign (derived from UTM parameters on the first event of the session). There are other parameters here which can also be used (affid, sub1, sub2 etc)

- landing page


### Device attributes

- device type

- browser and operating system (if possible)


## Attribution-level metrics

To support first-click and last-click attribution:

- attributed source, medium, and campaign per order

- attributed revenue per order (100% of revenue assigned to one channel per model)

These outputs allow marketing to aggregate orders and revenue by channel under different attribution models.


## Architecture

To architect this solution, a number of transformation tables will be needed

- events\_validated → events\_clean

- events\_clean → sessionized\_events (assign session ids)

- sessionized\_events → sessions (aggregate)

- sessionized\_events → orders (dedupe + anchor purchase truth)

- orders + sessions → order\_touchpoints\_7d

- order\_touchpoints\_7d → attribution\_first\_click and attribution\_last\_click (first + last)

**events\_validated** - raw events in current format with rows that fail data validation removed

**events\_clean** - parse key JSON fields into columns (`transaction_id`, `revenue`)

**sessionized\_events** - assign a `session_id` to each event

**sessions** - 1 row per session

**orders** - 1 row per transaction

**order\_touchpoints\_7d** - capture all touchpoints within 7-day look back for orders

**attribution\_first\_click** and **attribution\_last\_click** - 1 row per order with assigned credit to a single channel per table


### Trade-Offs

**Sessionization**: Because sessions are inferred from event timestamps, long periods of passive engagement (e.g. a user spending a long time on a page without generating events) may be split into multiple sessions. This can be improved by emitting additional engagement signals (such as scroll or heartbeat events), which are not available in this dataset.

**Sessionization** is also dependent on client\_id being available which as seen in the dataset is not guaranteed.

**Architecture**:  the trade-off or assumption here is that orders need to be de-duped and this case I have made the decision to de-dupe them by retaining the one with the higher revenue. This approach assumes that the higher revenue values represent the final basket. 


## Validation

For validation, I propose 3 main checks

1. Reconciliation checks

2. Structural Checks

3. Spot-check test cases


### Reconciliation Checks

This will look to confirm that totals in transformed tables match the source files

- Orders table reconciles to purchases

- Session revenue reconciles to orders

- Attribution totals reconcile to orders


### Structural Checks

This will look to check that each transformed table has the right grain and keys

- Each transaction has one row in orders 

- Each session has one row in sessions

- Each sessionized event maps to a session\_id

- Each order has an attribution row


### Spot checks

- Human check on 3-5 different transaction\_ids and sessions to confirm attribution is working as expected


### Validation Results 

On checking the validation queries, it has been discovered that 

- 17,287 events do not have a client\_id. 

- This includes 77 orders. 

These entries are excluded from session-based analysis and attribution, as they cannot be reliably associated with a user journey. In a production system, this would typically be addressed by introducing an alternative stable user identifier (e.g. authenticated user ID or device-level ID). This is outside the scope of the provided dataset.
