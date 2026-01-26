Conversation opened. 1 read message.

Skip to content
Using Gmail with screen readers
Storage update
Get 100 GB for €1.99
Storage is shared across Gmail, Drive & Photos
13.27 GB of 15 GB used
Conversations
88% of 15 GB used
Cancel subscription
Terms · Privacy · Program Policies
Last account activity: 0 minutes ago
Open in 1 other location · Details
# Phase 02: Terraform Infrastructure Modules

🎯 **Goal of This Phase**  
To build the foundational data infrastructure using modularized and production-grade Terraform code, allowing scalable and secure ingestion and crawling of raw data.

---

## 🧱 Modules Implemented So Far

### 1️⃣ S3 Ingestion Bucket

- **Purpose**: Stores raw review data from Amazon in a secure and partitionable structure.
- **Module**: `modules/s3_ingestion`
- **Key Features**:
  - Bucket name derived from workspace environment (e.g., `amazon-ingestion-dev`)
  - Public access blocked completely
  - Optional versioning enabled
  - AES-256 SSE encryption enabled

**Resources Created**:
| Resource Type | Description |
|---------------|-------------|
| `aws_s3_bucket` | Raw data ingestion bucket |
| `aws_s3_bucket_public_access_block` | Blocks public access to the bucket |
| `aws_s3_bucket_versioning` | Enables version control of raw data |
| `aws_s3_bucket_server_side_encryption_configuration` | Enables AES256 encryption |

---

### 2️⃣ Glue Crawler + Database

- **Purpose**: Automatically crawls the raw data in S3 and creates a structured schema in the Glue Data Catalog.
- **Module**: `modules/glue`
- **Key Features**:
  - Glue catalog database created dynamically based on workspace (e.g., `amazon_reviews_db_dev`)
  - Crawler targets `s3://amazon-ingestion-dev/reviews/`
  - IAM role created and attached with necessary policies
  - Schema change policies defined: update in-place, delete to log

**Resources Created**:
| Resource Type | Description |
|---------------|-------------|
| `aws_glue_catalog_database` | Glue database to store crawled metadata |
| `aws_glue_crawler` | Crawler that scans raw data and updates the Glue table |
| `aws_iam_role` | Role that allows the crawler to assume permissions |
| `aws_iam_role_policy_attachment` | Policies for S3 and Glue access |

---

## ⚠️ Common Issues & Fixes

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `Duplicate backend block` | Multiple `backend.tf` files active | Rename or remove extra backend files |
| `S3 bucket not found during init` | Bucket not created yet | Disable backend temporarily during `init` |
| `Missing variable environment` | Not passed to module | Add `environment = "dev"` to `main.tf` |
| `Unable to validate S3 target` | Crawler points to non-existing folder | Upload a placeholder file to `reviews/` |
| `Access Denied` when creating crawler | IAM role missing policy | Attach `AmazonS3ReadOnlyAccess` and `AWSGlueServiceRole` |

---

## 📌 Key Learnings

- Always separate **bootstrap phase** from main infrastructure
- Remote backend must only be activated **after** S3/DynamoDB creation
- Use **workspaces + variables** to isolate `dev/prod` environments
- Glue crawler **needs a real or placeholder file** in S3 before it can start

---

## 🛠️ Tools Used

- **Terraform**
- **AWS S3**
- **AWS Glue**
- **AWS IAM**
- **Terraform CLI Workspaces**

---

▶️ **Next Phase**: [Step Functions Orchestration →](06-stepfunction.md)
02-terraform-infra.md
Displaying 02-terraform-infra.md. 