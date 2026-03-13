import boto3
import os

ecs = boto3.client("ecs")

def lambda_handler(event, context):

    ecs.run_task(
        cluster=os.environ["CLUSTER"],
        taskDefinition=os.environ["TASK"],
        launchType="FARGATE",

        networkConfiguration={
            "awsvpcConfiguration": {
                "subnets": [os.environ["SUBNET"]],
                "securityGroups": [os.environ["SECURITY_GROUP"]],
                "assignPublicIp": "ENABLED"
            }
        }
    )

    return {"statusCode":200}