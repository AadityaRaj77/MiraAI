from flask import Flask, request, jsonify
from mira_sdk import MiraClient

app = Flask(_name_)

@app.route('/', methods=['GET'])
def home():
    return '<h1>The server is running</h1>'

@app.route('/data', methods=['POST'])
def get_data():
    try:
        user_data = request.get_json()
        username = user_data.get('username', 'Unknown')
        age = user_data.get('age', '')
        gender = user_data.get('gender', '')
        weight = user_data.get('weight', '')
        occupation = user_data.get('occupation', '')
        hobbies = user_data.get('hobbies', '')
        health_info = user_data.get('healthInfo', '')
        time = user_data.get('time', '')

        client = MiraClient(config={"API_KEY": "sb-c447ebecb85b978c1a38c4e871cf76d7"})

        input_data = {
            "username": username,
            "age": age,
            "gender": gender,
            "weight": weight,
            "job": occupation,
            "hobbies": hobbies,
            "health": health_info,
            "time": time,
        }

        version = "1.0.0"
        flow_name = f"@sigmarule/lifestyle1/{version}"

        result = client.flow.execute(flow_name, input_data)

        data = [
            {'title': 'Activity to do', 'description': result['result']},
        ]
        return jsonify(data), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if _name_ == '_main_':
    app.run(debug=True)
