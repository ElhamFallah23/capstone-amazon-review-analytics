# 03 — Data Pipeline Design

## 1. Purpose

This document describes the end-to-end data pipeline architecture, processing strategy, storage design, and integration with Snowflake.

The pipeline is designed to be:

- Event-driven
- Scalable
- Decoupled
- Analytics-ready
- Fully automated

---

## 2. Data Flow Overview

### Pipeline Sequence

1. Raw review files are uploaded to S3 (raw layer).
2. S3 emits an object creation event.
3. EventBridge captures the event.
4. Step Functions state machine is triggered.
5. Glue Job 1 performs data cleaning.
6. Glue Job 2 performs data flattening.
7. Cleaned Parquet files are written to S3 (processed layer).
8. Snowflake external table metadata refresh is triggered.
9. dbt transforms data into staging and mart layers.
10. Airflow orchestrates analytics execution.

The pipeline requires no manual intervention.

---

## 3. Raw Layer (S3)

Purpose:
- Immutable landing zone for source JSON files.

Design Principles:

- Raw data remains unchanged.
- Files are versionable.
- Acts as trigger point for event-driven execution.

This aligns with data lake best practices.

---

## 4. Processing Layer (Glue Jobs)

Two separate Glue jobs are implemented.

### 4.1 Glue Job 1 — Cleaning

Responsibilities:

- Data validation
- Type casting
- Handling nulls and malformed records
- Standardization of key fields

Reasoning:

Separating cleaning ensures raw-to-standardized transformation is isolated and traceable.

---

### 4.2 Glue Job 2 — Flattening

Responsibilities:

- Flatten nested JSON structures
- Normalize schema
- Convert data to Parquet format

Reasoning for Separation:

- Clear separation of concerns
- Easier debugging
- Independent scaling
- Improved observability
- Production-style modular ETL

This avoids monolithic ETL design.

---

## 5. Processed Layer (S3 – Parquet)

Why Parquet?

- Columnar storage format
- Reduced storage footprint
- Faster analytical queries
- Optimized for Snowflake external querying

The processed layer serves as the curated data lake zone.

---

## 6. Snowflake Integration

### 6.1 External Table Architecture

The system uses:

- Storage Integration (IAM-based access)
- External Stage
- External Table
- Auto-refresh enabled via S3 events

Important Design Decision:

Data is NOT copied into Snowflake using `COPY INTO`.

Instead:

- Data remains in S3.
- Snowflake maintains metadata only.
- Queries are executed directly against Parquet files in S3.

---

### 6.2 Metadata Refresh vs Data Load

External Table Behavior:

- When new Parquet files arrive in S3,
- S3 event triggers Snowflake metadata refresh,
- The external table updates automatically.

This is metadata synchronization, not physical ingestion.

Benefits:

- No data duplication
- Reduced storage cost
- Clear separation of storage and compute
- Near real-time availability

---

## 7. Event-Driven Orchestration

The pipeline is reactive rather than schedule-based.

Advantages over cron-based systems:

- Processing starts immediately after file arrival.
- No wasted compute cycles.
- Improved scalability.
- Better operational efficiency.

Event Flow:

S3 → EventBridge → Step Functions → Glue Jobs

This ensures decoupled and automated execution.

---

## 8. Analytics Transformation Layer (dbt)

Two modeling layers are implemented:

### Staging Layer

- Source-aligned transformations
- Column renaming
- Type normalization

### Mart Layer

- Aggregated business logic
- Clearly defined grain
- Optimized for BI queries

Data quality is enforced using dbt tests:

- not_null
- unique
- relationships

---

## 9. Airflow Orchestration

Current State:

- Airflow DAG runs on schedule interval.

Responsibilities:

- Executes dbt models
- Controls downstream analytics flow

Future Enhancement:

- Event-driven DAG triggering via EventBridge.

This allows gradual evolution toward full event-driven orchestration.

---

## 10. Scalability Considerations

- S3 scales automatically.
- Glue supports configurable worker scaling.
- Step Functions manages concurrent workflows.
- Snowflake separates compute and storage.
- dbt models are incremental-ready.

The architecture supports growth in data volume and processing complexity.

---

## 11. Failure Handling Strategy

- Step Functions manages retries and failure states.
- Glue logs are available in CloudWatch.
- Airflow includes retry mechanisms.
- Modular jobs prevent cascading failures.

The pipeline is resilient and observable.

---

## 12. Why This Pipeline Is Production-Oriented

- Event-driven execution
- Modular ETL design
- Parquet-based data lake layer
- External table integration
- Automated metadata refresh
- Clear modeling separation
- Observability and failure control

This design reflects modern cloud-native data engineering practices.