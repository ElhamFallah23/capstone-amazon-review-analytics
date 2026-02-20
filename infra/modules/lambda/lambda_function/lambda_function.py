import json
import os
import boto3

# Create AWS service clients
glue_client = boto3.client("glue")
sns_client = boto3.client("sns")

# Read environment variables passed from Terraform
GLUE_JOB_NAME = os.environ["GLUE_JOB_NAME"]     # ?????
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]


def lambda_handler(event, context):
    ###
    # This Lambda function is invoked by AWS Step Functions.
    # It checks the status of a Glue job run and sends a notification via SNS if the job succeeded or failed.
    ###

    # Step Function passes JobRunId in the input event
    job_run_id = event.get("JobRunId")

    if not job_run_id:
        raise ValueError("JobRunId is required in the event input")

    # Get Glue job run status
    response = glue_client.get_job_run(
        JobName=GLUE_JOB_NAME,
        RunId=job_run_id
    )

    job_status = response["JobRun"]["JobRunState"]

    # Prepare base message
    message = {
        "job_name": GLUE_JOB_NAME,
        "job_run_id": job_run_id,
        "status": job_status
    }

    # If job succeeded, notify success
    if job_status == "SUCCEEDED":
        sns_client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject="Glue Job Succeeded",
            Message=json.dumps(message)
    )

    # If job failed or stopped, notify failure
    elif job_status in ["FAILED", "STOPPED", "TIMEOUT"]:
        sns_client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject="Glue Job Failed",
            Message=json.dumps(message)
    )

    # Return status back to Step Function
    return message