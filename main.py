from flask import Flask, request, jsonify
import boto3
import uuid
from flask_httpauth import HTTPBasicAuth
import os
from boto3.dynamodb.conditions import Key, Attr
from datetime import datetime
import pytz


app = Flask(__name__)
auth = HTTPBasicAuth()

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

def get_audit_password():
    session = boto3.Session()
    ssm = session.client('ssm')
    try:
        response = ssm.get_parameter(
            Name='audit_secret',
            WithDecryption=True
        )
        return response['Parameter']['Value']
    except Exception as e:
        print(f"Error fetching parameter: {e}")
        return None

AUDIT_PASSWORD = get_audit_password()

@app.route('/search', methods=['GET'])
def search():
    tz = pytz.timezone('Israel')
    current_time = datetime.now(tz)  # Current time in Israeli time zone
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

    if not filtered_restaurants:
        next_openings = []
        for restaurant in complete_results:
            if not is_open(restaurant, current_time):
                next_openings.append(f"{restaurant['name']} will open at {restaurant['openHour']}")
        
        message = "Sorry, there are no open restaurants currently for your search."
        if next_openings:
            message += " But the following restaurants will open at: " + ", ".join(next_openings)
        return message, 200

    audit_data = {
        'ActionID': str(uuid.uuid4()),
        'ReqParams': str(request.args),
        'Response': [restaurant['name'] for restaurant in filtered_restaurants],
        'Time': datetime.now(tz).isoformat()
    }
    audit_table = dynamodb.Table('audit')
    audit_table.put_item(Item=audit_data)

    return jsonify(filtered_restaurants)

@app.route('/health')
def health_check():
    return "OK", 200


@app.route('/audit', methods=['GET'])
@auth.login_required
def get_audit_logs():
    max_last_records = int(request.args.get('maxLastRecords', '5'))  # Default to 5 if not specified
    audit_table = dynamodb.Table('audit')
    response = audit_table.scan(
        Limit=max_last_records
    )
    return jsonify(response['Items'])

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=80)

