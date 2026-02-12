import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import col

# Resolve arguments from Terraform
args = getResolvedOptions(
    sys.argv,
    [
        "JOB_NAME",
        "glue_database_name",
        "glue_table_name",
        "processed_output_path",
        "environment",
    ]
)

# Initialize Spark & Glue
sc = SparkContext()
glue_context = GlueContext(sc)
spark = glue_context.spark_session

# Initialize Job
job = Job(glue_context)
job.init(args["JOB_NAME"], args)

# Read meta data from Glue Catalog
meta_dyf = glue_context.create_dynamic_frame.from_catalog(
    database=args["glue_database_name"],
    table_name=args["glue_table_name"]
)

meta_df = meta_dyf.toDF()

# Flatten & select important columns
flattened_meta_df = meta_df.select(
    col("asin").alias("product_id"),
    col("title"),
    col("brand"),
    col("price"),
    col("description"),
    col("category")
)

# Write to S3 (processed/meta/)
(
    flattened_meta_df
    .write
    .mode("overwrite")
    .parquet(args["processed_output_path"])
)

job.commit()




