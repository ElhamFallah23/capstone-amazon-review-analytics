# 05 — Operational Runbook

## 1. Purpose

This runbook describes operational procedures, failure scenarios, monitoring points, and recovery strategies for the Amazon Review Analytics platform.

The goal is to ensure:

- Observability
- Controlled failure handling
- Fast issue resolution
- Safe infrastructure changes

---

## 2. System Monitoring Overview

Primary monitoring sources:

- AWS CloudWatch (Glue logs)
- Step Functions Execution History
- GitHub Actions logs
- Airflow UI & task logs
- Snowflake query history

Each layer provides visibility into its execution state.

---

## 3. Common Failure Scenarios & Resolution Steps

---

### 3.1 Glue Job Failure

Symptoms:

- Step Functions execution fails
- Glue job marked as FAILED
- CloudWatch logs show errors

Actions:

1. Open Glue Job in AWS Console
2. Review CloudWatch logs
3. Check input data format
4. Validate schema assumptions
5. Re-run Step Functions execution after fix

Common Causes:

- Schema mismatch
- Corrupt JSON
- Memory configuration too low

---

### 3.2 Step Functions Failure

Symptoms:

- Execution marked as FAILED
- Workflow stops between Glue jobs

Actions:

1. Open Step Functions console
2. Inspect failed state
3. Review input/output payload
4. Check IAM role permissions
5. Verify Glue job configuration

Step Functions retry policies should be reviewed if failures are transient.

---

### 3.3 Snowflake External Table Not Updating

Symptoms:

- New files in S3 (processed)
- External table does not reflect new data

Actions:

1. Verify S3 event notifications are enabled
2. Confirm Snowflake storage integration is active
3. Check external table auto-refresh configuration
4. Run manual metadata refresh (if required for debugging)

Important:

This architecture uses metadata refresh, not data load.
If metadata is not updated, queries will not see new files.

---

### 3.4 dbt Test Failure

Symptoms:

- dbt test fails (not_null / unique / relationships)

Actions:

1. Run `dbt test` locally
2. Identify failing model
3. Check upstream staging model
4. Validate grain assumptions
5. Fix transformation logic

Never ignore failing tests — they indicate potential analytical corruption.

---

### 3.5 Airflow DAG Failure

Symptoms:

- DAG run marked as failed
- dbt task fails

Actions:

1. Open Airflow UI
2. Inspect task logs
3. Identify failing task
4. Re-run task after fix

Check:

- Snowflake connectivity
- dbt environment configuration
- Data freshness

---

### 3.6 Terraform Apply Failure

Symptoms:

- GitHub Actions apply step fails
- Plan shows unexpected changes

Actions:

1. Review GitHub Actions logs
2. Inspect Terraform plan output
3. Confirm no state drift
4. Validate IAM permissions
5. Re-run after fix

Never apply manually outside CI/CD to prevent state inconsistency.

---

## 4. Incident Severity Guidelines

Severity Levels:

- Low: Visualization or minor transformation issue
- Medium: dbt model failure affecting reporting
- High: Glue or Step Functions failure blocking ingestion
- Critical: Terraform state corruption or security misconfiguration

High and Critical incidents require immediate attention.

---

## 5. Recovery Strategy

- Step Functions supports controlled retries
- Glue jobs can be re-executed safely
- External tables require metadata sync only
- dbt models are deterministic and re-runnable
- Terraform state protected via DynamoDB locking

The system is designed for safe reprocessing.

---

## 6. Operational Best Practices

- Never bypass CI/CD for infrastructure changes
- Always review Terraform plan before apply
- Monitor Step Functions execution metrics
- Validate dbt tests before publishing dashboards
- Maintain least-privilege IAM policies

---

## 7. Future Monitoring Enhancements

- Automated SNS alerts for Glue failure
- Data freshness checks in dbt
- Cost monitoring dashboards
- Centralized logging aggregation
- SLA tracking for ingestion latency

---

## 8. Operational Maturity

The platform includes:

- Automated infrastructure provisioning
- Event-driven execution
- Observability at each layer
- Clear failure handling strategy
- Deterministic reprocessing capability

This reflects production-grade operational awareness.