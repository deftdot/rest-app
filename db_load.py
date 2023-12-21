import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('restaurants')

with open('restlist.json', 'r') as file:
    data = json.load(file)

for item in data:
    table.put_item(Item=item)
