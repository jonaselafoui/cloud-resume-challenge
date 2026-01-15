import os
import json
import boto3
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])

def _json_default(o):
    if isinstance(o, Decimal):
        return int(o)
    raise TypeError

def lambda_handler(event, context):
    counter_id = os.environ.get("COUNTER_ID", "website")

    resp = table.update_item(
        Key={"visitorcounter_id": counter_id},
        UpdateExpression="SET number_of_visitors = if_not_exists(number_of_visitors, :zero) + :inc",
        ExpressionAttributeValues={":inc": 1, ":zero": 0},
        ReturnValues="UPDATED_NEW",
    )

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET,OPTIONS",
        },
        "body": json.dumps({"count": resp["Attributes"]["number_of_visitors"]}, default=_json_default),
    }
