
# 📦 Amazon Product Review Analytics (Capstone Project)

---

## 🧠 Project Description

This project is designed as a capstone data engineering challenge to build an end-to-end data pipeline for collecting, processing, transforming, and analyzing Amazon product review data using AWS-native services and modern tools such as Terraform, Snowflake, DBT, and Airflow.

---

## 🏗 Architecture Overview

A modular, cloud-native data pipeline based on:

- Terraform + GitHub Actions for Infrastructure as Code and CI/CD
- AWS S3 for data ingestion
- AWS Glue & Step Functions for orchestration
- Snowflake for warehousing
- DBT for transformation
- Airflow for scheduling
- QuickSight for visualization

➡️ Full diagram and explanation: [`docs/00-project-overview.md`](./docs/00-project-overview.md)

---

## 🚀 Getting Started

```bash
# Clone the repository
git clone https://github.com/your-username/amazon-review-capstone.git
cd amazon-review-capstone

# Configure AWS CLI
aws configure

# Initialize Terraform
cd infra
terraform init
terraform workspace new dev
terraform apply -var="environment=dev"
```

---

## 🛠 Technologies Used

| Area              | Tools & Services                           |
|-------------------|---------------------------------------------|
| Infra as Code     | Terraform                                   |
| Cloud Provider    | AWS (S3, Glue, Step Functions, IAM, etc.)  |
| Data Warehouse    | Snowflake                                   |
| Data Modeling     | DBT                                          |
| Orchestration     | Apache Airflow, AWS Step Functions          |
| Visualization     | Amazon QuickSight                           |
| Automation        | GitHub Actions                              |
| Language          | Python                                       |

---

## 📂 Project Structure

```
.
├── infra/                   # Terraform modules and root config
├── docs/                    # Phase-by-phase documentation
├── dags/                    # Airflow DAGs (planned)
├── dbt/                     # DBT models (planned)
├── .github/workflows/       # GitHub Actions for CI/CD
├── screenshots/             # Screenshots used in documentation
└── README.md
```

---

## ✅ Project Progress

- [x] Phase 01 - Bootstrap (S3 + DynamoDB for state & locking)
- [ ] Phase 02 - Infra setup modules
- [ ] Phase 03 - GitHub Actions automation
- [ ] Phase 04+ - Data flow, modeling, transformation & reporting

---

## 📸 Key Screenshots

> Coming soon as each phase progresses...

---

## 📄 Documentation

- [00 - Project Overview](./docs/00-project-overview.md)
- [01 - Bootstrap Setup](./docs/01-bootstrap.md)
- [02 - Infra Modules](./docs/02-terraform-infra.md)
- (more docs in `/docs/` folder)

---

## 📬 About the Author

This project is built as part of a Data Engineering capstone bootcamp project using real-world best practices and cloud-native design.  
Stay tuned for updates and full deployment!