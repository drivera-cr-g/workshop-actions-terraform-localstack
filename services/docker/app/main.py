import json
from fastapi import FastAPI, HTTPException
from os import environ
import localstack_client.session as boto3
from botocore.exceptions import ClientError, EndpointConnectionError
from botocore.config import Config
from app.models import Item

app = FastAPI()

environ["AWS_ENDPOINT_URL"] = "http://localstack:4566/"
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
sample_table = dynamodb.Table('SampleTable')


@app.post("/items/")
async def create_item(item: Item):
    try:
        response = sample_table.put_item(Item=item.model_dump())
        return {"message": "Item created successfully", "item": item}
    except ClientError as e:
        raise HTTPException(
            status_code=400, detail=e.response['Error']['Message'])
    except EndpointConnectionError as e:
        raise HTTPException(
            status_code=503, detail=e.response['Error']['Message']
        )


@app.get("/items/{main_index_key}")
async def read_item(main_index_key: str):
    try:
        response = sample_table.get_item(Key={"MainIndexKey": main_index_key})
        if 'Item' in response:
            return response['Item']
        else:
            raise HTTPException(status_code=404, detail="Item not found")
    except ClientError as e:
        raise HTTPException(
            status_code=400, detail=e.response['Error']['Message'])
    except EndpointConnectionError as e:
        raise HTTPException(
            status_code=503, detail=str(e)
        )


@app.get("/tables")
async def get_tables():
    try:
        client = boto3.Session().client('dynamodb', config=Config(region_name='us-east-1'))
        response = client.list_tables()
        if response:
            return {"Tables": response['TableNames']}
        else:
            raise HTTPException(status_code=404, detail="Tables not found")
    except ClientError as e:
        raise HTTPException(
            status_code=400, detail=e.response['Error']['Message'])
    except EndpointConnectionError as e:
        raise HTTPException(
            status_code=503, detail=str(e)
        )


@app.get("/buckets")
async def get_buckets():
    try:
        client = boto3.Session().client('s3', config=Config(region_name='us-east-1'))
        response = client.list_buckets()
        if response:
            return {"Buckets": [bucket['Name'] for bucket in response['Buckets']]}
        else:
            raise HTTPException(status_code=404, detail="Buckets not found")
    except ClientError as e:
        raise HTTPException(
            status_code=400, detail=e.response['Error']['Message'])
    except EndpointConnectionError as e:
        raise HTTPException(
            status_code=503, detail=str(e)
        )


@app.get("/logs")
async def get_logs():
    client = boto3.Session().client('s3', config=Config(region_name='us-east-1'))
    bucket_name = 'terraform-output-s3-bucket'
    object_key = 'terraform-output.json'
    response = client.get_object(Bucket=bucket_name, Key=object_key)
    content = response['Body'].read().decode('utf-8')
    return json.loads(content)
