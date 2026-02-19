

## 1. Problem Statement

Modern data platforms must handle scalable ingestion, automated processing, secure deployment, and analytics-ready transformation while minimizing manual intervention.

The challenge is to design a cloud-native data pipeline that is:

- Secure
- Event-driven
- Fully automated
- Infrastructure-as-Code managed
- Analytics-ready

This project addresses that challenge by building a production-style, end-to-end data platform for Amazon product review analytics.

---

## 2. Solution Overview

The platform ingests Amazon review data into AWS S3, automatically processes and transforms it using event-driven orchestration, and exposes analytics-ready datasets in Snowflake for downstream reporting.

The entire infrastructure is provisioned using Terraform and deployed via GitHub Actions using OIDC authentication — without hard-coded credentials.

The solution demonstrates:

- Event-driven architecture
- Modular Infrastructure as Code
- Secure CI/CD
- Data lake design principles
- Layered transformation modeling (raw → stage → mart)

---

## Tech Stack & Tools

| Layer | Tools & Services Used |
|----------------------|----------------------|
| Infrastructure | Terraform |
| CI/CD | GitHub Actions (OIDC-based) |
| Data Ingestion | AWS S3, EventBridge |
| Processing | AWS Glue (Cleaning & Flattening) |
| Orchestration (Ingest) | AWS Step Functions |
| Orchestration (Analytics) | Apache Airflow |
| Data Warehouse | Snowflake (External Stage & Table) |
| Transformation | dbt (Data Build Tool) |
| Visualization | Amazon QuickSight |
| Programming Language | Python |

---
## 3. High-Level Architecture Summary

The system is designed as a secure, event-driven, cloud-native data platform following Infrastructure as Code (IaC) and production-grade design principles.

End-to-end flow:

- S3 (raw data landing zone)
- EventBridge-triggered Step Functions
- Two-stage Glue processing (cleaning & flattening)
- S3 processed layer (Parquet format)
- Snowflake External Table with auto-refresh
- dbt transformations (staging & mart)
- Airflow orchestration
- QuickSight dashboards

The pipeline is fully automated from ingestion to analytics.

![architecture-diagram](../screenshots/final-architecture-diagram.png)
---

## 4. Key Design Decisions

### Event-Driven Processing

S3 events trigger EventBridge, which starts Step Functions.
This eliminates manual execution and enables reactive processing.

### Separation of Concerns

Two Glue jobs are used:
- Cleaning
- Flattening

This improves maintainability and observability.

### External Table over Data Copy

Snowflake uses External Tables instead of `COPY INTO`.

- Data remains in S3
- Snowflake maintains metadata only
- Auto-refresh keeps tables updated
- Reduced storage duplication

### Secure CI/CD with OIDC

GitHub Actions deploy infrastructure using OIDC-based authentication.

- No static AWS credentials
- Short-lived tokens
- Least-privilege IAM roles

---

## 5. What Makes This Production-Ready

- Fully automated infrastructure provisioning
- Event-driven orchestration
- Modular Terraform architecture
- Secure credential management
- Data lake–style separation of storage and compute
- Clear modeling layers in dbt
- Observability through Step Functions & Airflow

This project reflects real-world cloud data engineering design patterns rather than a simple academic pipeline.


## 🔁 Project Phases Overview

| Phase | Description |
|-------|-------------|
| 01 | Terraform Backend Bootstrap (S3 state + DynamoDB lock) |
| 02 | Core Infrastructure Provisioning (Modular Terraform) |
| 03 | Secure CI/CD Integration with GitHub OIDC |
| 04 | S3 Raw Data Ingestion Setup |
| 05 | Glue Crawler & Schema Registration |
| 06 | Event-Driven Step Functions Orchestration |
| 07 | Snowflake Environment Setup (DB, Schema, Stage, External Table) |
| 08 | Snowflake Storage Integration with S3 |
| 09 | dbt Modeling (Staging & Mart Layers) |
| 10 | Airflow DAG Orchestration |
| 11 | BI Layer – QuickSight Dashboard |
| 12 | System Validation, Testing & Documentation |
| 13 | Final Architecture Review & Lessons Learned |
---

