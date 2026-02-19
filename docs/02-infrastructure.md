# 02 — Infrastructure & CI/CD Design
## 1. Purpose

This document describes the infrastructure architecture, Terraform module strategy, remote state management, and CI/CD deployment model of the platform.

All infrastructure is provisioned using Terraform and deployed securely through GitHub Actions using OIDC authentication.

The system follows Infrastructure-as-Code and least-privilege security principles.

---

## 2. Infrastructure Architecture Overview

The infrastructure layer provisions:

- AWS S3 buckets (raw & processed)
- EventBridge rules
- Step Functions state machine
- Glue jobs
- IAM roles & policies
- Snowflake objects (database, schema, stage, external table)
- GitHub OIDC role
- Terraform remote backend (S3 + DynamoDB)

The design is modular and environment-aware.

---

## 3. Terraform Architecture

### 3.1 Backend Configuration

Remote state is configured using:

- S3 bucket for state storage
- DynamoDB table for state locking

Benefits:

- Prevents concurrent Terraform runs
- Enables team collaboration
- Ensures consistent state management

This follows Terraform production best practices.

---

### 3.2 Modular Design Strategy

Infrastructure is organized into reusable modules:

- s3
- iam
- glue
- lambda
- stepfunctions
- snowflake
- github-oidc

Each module:

- Has clear input variables
- Exposes explicit outputs
- Follows single-responsibility principle

Benefits:

- Reusability
- Clear separation of concerns
- Easier testing and debugging
- Scalable architecture evolution

---

### 3.3 Environment Isolation

The project is structured to support environment isolation:

- dev environment defined under `infra/environments/dev`
- Naming conventions include environment suffix
- Resources are logically separated

This design enables future expansion to staging or production.

---

## 4. Secure CI/CD Architecture

### 4.1 GitHub Actions Workflows

Three workflows manage infrastructure lifecycle:

- terraform-validate-fmt.yaml
- terraform-pr-plan.yaml
- terraform-post-merge-apply.yaml

Workflow Strategy:

1. Validate formatting and syntax
2. Run plan on pull request
3. Apply changes after merge

This ensures controlled infrastructure changes.

---

### 4.2 OIDC Authentication (No Static Credentials)

Instead of long-lived AWS access keys:

- GitHub Actions uses OpenID Connect (OIDC)
- AWS IAM role trusts GitHub as identity provider
- Short-lived tokens are issued dynamically

Benefits:

- No hard-coded credentials
- Improved security posture
- Least-privilege access control
- Enterprise-grade CI/CD pattern

---

## 5. IAM & Security Model

Security is based on least-privilege principles:

- Separate IAM roles for Glue, Step Functions, and CI/CD
- Explicit trust relationships
- Scoped permissions per service
- No wildcard administrative roles

Snowflake integration uses:

- IAM-based storage integration
- Restricted bucket access policy

All credentials are managed via IAM roles.

---

## 6. Event-Driven Infrastructure

The ingestion pipeline is fully event-driven:

- S3 emits object creation events
- EventBridge captures the event
- Step Functions state machine is triggered
- Glue jobs execute sequentially

Infrastructure components are decoupled and reactive.

---

## 7. Observability & Logging

- Glue logs stored in CloudWatch
- Step Functions execution history provides visibility
- GitHub Actions logs infrastructure changes
- Terraform plan artifacts stored during PR validation

This ensures traceability and operational visibility.

---

## 8. Failure & Recovery Strategy

- Step Functions supports retries and failure states
- Terraform state locking prevents corruption
- GitHub PR plan step prevents unsafe changes
- Modular design enables isolated debugging

The system is designed for safe iteration and controlled failure handling.

---

## 9. Why This Infrastructure Design Is Production-Ready

- Fully Infrastructure-as-Code
- Secure CI/CD with OIDC
- Remote state locking
- Modular Terraform architecture
- Environment-aware naming
- Event-driven orchestration
- Least-privilege IAM model

This reflects real-world cloud infrastructure patterns used in modern data platforms.