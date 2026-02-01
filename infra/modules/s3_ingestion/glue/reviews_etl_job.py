import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import col

# -------------------------------------------------------------------
# Resolve job arguments passed from Glue Job configuration (Terraform)
# -------------------------------------------------------------------
# These arguments are defined in Terraform under default_arguments
args = getResolvedOptions(
    sys.argv,
    [
        "JOB_NAME",
        "glue_datbase_name",
        "glue_table_name"
        "processed_output_path",
        "environment"
    ]
)

# -------------------------------------------------------------------
# Initialize Spark and Glue contexts
# -------------------------------------------------------------------
sc = SparkContext()
glue_context = GlueContext(sc)
spark = glue_context.spark_session

# Initialize Glue Job lifecycle
job = Job(glue_context)
job.init(args["JOB_NAME"], args)

# -------------------------------------------------------------------
# Read raw Amazon review data from S3
# Spark automatically handles compressed JSON (.json.gz)
# -------------------------------------------------------------------
#raw_df = spark.read.json(args["raw_input_path"])
raw_dyf = glue_context.create_dynamic_frame.from_catalog(
    database=args["glue_database_name"],
    table_name=args["glue_table_name"]
)
# Convert DynamicFrame to Spark DataFrame for transformations
raw_df = raw_dyf.toDF()

# -------------------------------------------------------------------
# Flatten and normalize the raw JSON structure
# This prepares the data for analytics and downstream systems
# -------------------------------------------------------------------
flattened_df = raw_df.select(
    col("reviewerID").alias("reviewer_id"),
    col("asin").alias("product_id"),
    col("reviewText").alias("review_text"),
    col("overall").alias("rating"),
    col("unixReviewTime").alias("review_timestamp"),
    col("verified").alias("is_verified"),
    col("reviewerName").alias("reviewer_name")
)

# -------------------------------------------------------------------
# Write the processed data to S3 in Parquet format
# Parquet is optimized for analytical workloads and Snowflake
# -------------------------------------------------------------------
(
    flattened_df
        .write
        .mode("overwrite")
        .parquet(args["processed_output_path"])
)

# -------------------------------------------------------------------
# Commit the Glue Job
# This marks the job as SUCCESS in AWS Glue
# -------------------------------------------------------------------
job.commit()
