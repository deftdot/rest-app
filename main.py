from flask import Flask, request, jsonify
import boto3
import uuid
from flask_httpauth import HTTPBasicAuth
import os
from boto3.dynamodb.conditions import Key, Attr
from datetime import datetime

app = Flask(__name__)
auth = HTTPBasicAuth()
AUDIT_PASSWORD = os.environ.get('AUDIT_PASSWORD', 'defaultpassword')

@auth.verify_password
def verify_password(username, password):
    if not (username and password):
        return False
    return password == AUDIT_PASSWORD
    
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('restaurants')

def is_open(restaurant, current_time):
    open_time = datetime.strptime(restaurant["openHour"], "%H:%M").time()
    close_time = datetime.strptime(restaurant["closeHour"], "%H:%M").time()
    current_time = current_time.time()

    if close_time < open_time:
        if current_time >= open_time or current_time <= close_time:
            return True
    else:
        if open_time <= current_time <= close_time:
            return True
    return False


@app.route('/search', methods=['GET'])
def search():
    current_time = datetime.now()
    style = request.args.get('style')
    is_vegetarian = request.args.get('isVegetarian')

    filter_expression = None

    if style:
        filter_expression = Key('style').eq(style)
    if is_vegetarian is not None:
        vegetarian_bool = is_vegetarian.lower() == 'true'
        if filter_expression:
            filter_expression = filter_expression & Attr('vegetarian').eq(vegetarian_bool)
        else:
            filter_expression = Attr('vegetarian').eq(vegetarian_bool)

    scan_kwargs = {'FilterExpression': filter_expression} if filter_expression else {}
    complete_results = []

    while True:
        response = table.scan(**scan_kwargs)
        complete_results.extend(response.get('Items', []))

        if 'LastEvaluatedKey' not in response:
            break
        scan_kwargs['ExclusiveStartKey'] = response['LastEvaluatedKey']

    filtered_restaurants = [restaurant for restaurant in complete_results if is_open(restaurant, current_time)]

    audit_data = {
    'ActionID': str(uuid.uuid4()),
    'ReqParams': str(request.args),
    'Response': [restaurant['name'] for restaurant in filtered_restaurants],
    'Time': datetime.now().isoformat()
    }
    audit_table = dynamodb.Table('audit')
    audit_table.put_item(Item=audit_data)

    return jsonify(filtered_restaurants)

@app.route('/health')
def health_check():
    return "OK, v1.18", 200


@app.route('/audit', methods=['GET'])
@auth.login_required
def get_audit_logs():
    max_last_records = int(request.args.get('maxLastRecords', '5'))  # Default to 10 if not specified
    audit_table = dynamodb.Table('audit')
    response = audit_table.scan(
        Limit=max_last_records
    )
    return jsonify(response['Items'])

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=80)
