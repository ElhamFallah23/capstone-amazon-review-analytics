# 04 — Analytics & Modeling Layer

## 1. Purpose

This document describes the transformation strategy, data modeling philosophy, orchestration logic, and analytics design of the platform.

The analytics layer converts processed lake data into business-ready datasets optimized for reporting and BI consumption.

---

## 2. Modeling Philosophy

The transformation layer follows a structured, layered approach using dbt.

The goals are:

- Clear separation of transformation responsibilities
- Explicit grain definition
- Testable models
- Maintainable business logic
- BI-ready output

The modeling architecture consists of:

- Staging Layer
- Mart Layer

---

## 3. Staging Layer (dbt)

Purpose:

- Source-aligned transformations
- Column standardization
- Type normalization
- Minimal business logic

Design Principles:

- One model per source entity
- Preserve source-level granularity
- Avoid aggregations in staging

This layer acts as the foundation for all downstream logic.

---

## 4. Mart Layer (dbt)

Purpose:

- Business-level transformations
- Aggregations
- KPI calculation
- BI optimization

Each mart model defines:

- Explicit grain
- Business meaning
- Aggregation level

Example design considerations:

- Review-level fact table
- Aggregated product-level metrics
- Time-based trend analysis

All business logic is centralized in mart models.

---

## 5. Grain Definition Strategy

Each mart model clearly defines its grain.

Examples:

- fct_reviews_granular → one row per review
- mart_product_kpi → one row per product per time period

Why Grain Definition Matters:

- Prevents accidental double counting
- Ensures consistent aggregations
- Enables predictable BI behavior
- Simplifies dashboard design

Grain clarity is critical in production analytics systems.

---

## 6. Data Quality & Testing

Data quality is enforced using dbt tests.

Implemented tests include:

- not_null
- unique
- relationships

Testing Strategy:

- Validate primary identifiers
- Ensure referential integrity
- Prevent duplicate records
- Catch schema mismatches early

This prevents silent analytical corruption.

---

## 7. Airflow Orchestration

Airflow is responsible for:

- Executing dbt transformations
- Managing execution schedule
- Handling retries

Current Design:

- DAG runs on defined schedule interval
- dbt tasks grouped logically

Future Evolution:

- Event-driven DAG trigger
- Dependency-based scheduling
- Integration with data freshness checks

Airflow provides visibility and execution control.

---

## 8. BI Layer (QuickSight)

QuickSight consumes mart-level datasets.

Design Principles:

- Dashboards built on aggregated mart tables
- Filters (e.g., Year filter)
- Top-N analysis
- KPI visualization

Benefits of Mart-Based BI:

- Improved performance
- Clear metric definitions
- Avoids heavy raw-layer queries

---

## 9. Separation of Responsibilities

The system clearly separates:

- Data ingestion (AWS)
- Data storage (S3)
- Data warehouse access (Snowflake external)
- Transformation logic (dbt)
- Orchestration (Airflow)
- Visualization (QuickSight)

This layered separation follows modern data platform architecture patterns.

---

## 10. Scalability & Evolution

The analytics layer is designed to evolve:

- Incremental dbt models can be added
- Additional marts can be introduced
- New KPIs can be layered without affecting ingestion
- Airflow DAGs can expand modularly

The design supports business growth.

---

## 11. Why This Analytics Layer Is Production-Oriented

- Clear grain definition
- Test-driven modeling
- Layered architecture
- Centralized business logic
- Orchestrated execution
- BI-optimized design

This reflects modern analytics engineering standards rather than ad-hoc SQL transformations.