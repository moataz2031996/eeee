from flask import Flask, request, jsonify
from flask_cors import CORS
import json, os

app = Flask(__name__)
CORS(app)

USERS_FILE = "users.json"
lessons = {
    "HS101": {"video": "https://www.youtube.com/embed/dQw4w9WgXcQ", "teacher": "أ. محمد مصطفى"},
    "HS102": {"video": "https://www.youtube.com/embed/tgbNymZ7vqY", "teacher": "أ. فاطمة علي"},
    "MATH201": {"video": "https://www.youtube.com/embed/eVTXPUF4Oz4", "teacher": "أ. أحمد سالم"}
}

def load_users():
    if not os.path.exists(USERS_FILE):
        return {}
    with open(USERS_FILE, "r", encoding="utf-8") as f:
        return json.load(f)

def save_users(users):
    with open(USERS_FILE, "w", encoding="utf-8") as f:
        json.dump(users, f, ensure_ascii=False, indent=2)

@app.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    name = data.get("name"); password = data.get("password")
    if not name or not password:
        return jsonify({"success": False, "message": "يرجى إدخال الاسم وكلمة السر"}), 400
    users = load_users()
    if name in users:
        return jsonify({"success": False, "message": "هذا الاسم مستخدم بالفعل"}), 409
    users[name] = {"password": password}
    save_users(users)
    return jsonify({"success": True, "message": "تم التسجيل بنجاح"})

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    users = load_users()
    user = users.get(data.get("name"))
    if user and user["password"] == data.get("password"):
        return jsonify({"success": True, "student": data.get("name")})
    return jsonify({"success": False, "message": "البيانات غير صحيحة"}), 401

@app.route("/lesson/<code>")
def get_lesson(code):
    lesson = lessons.get(code)
    if not lesson:
        return jsonify({"success": False, "message": "كود غير صحيح"}), 404
    return jsonify({"success": True, "lesson": lesson})

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    app.run(host="0.0.0.0", port=port)
