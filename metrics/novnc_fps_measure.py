from flask import Flask, request
import json

app = Flask(__name__)

@app.route('/fps', methods=['POST'])
def save_fps():
    data = request.get_json()

    if 'fps' not in data:
        return {"error": "No fps value provided"}, 400

    if 'source' not in data:
        return {"error": "No source provided"}, 400

    with open('fps_data.txt', 'a') as f:
        f.write(json.dumps(data) + '\n')

    return {"message": "FPS data saved successfully"}, 200

if __name__ == '__main__':
    app.run(debug=True, port=5001)