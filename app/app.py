from flask import Flask, jsonify, request
from sqlalchemy import create_engine, text
import os

app = Flask(__name__)

# Read DB connection info from environment variables
DB_USER = os.getenv("DB_USER", "system")
DB_PASSWORD = os.getenv("DB_PASSWORD", "MyStrongPass123")
DB_HOST = os.getenv("DB_HOST", "oracle-db")
DB_PORT = os.getenv("DB_PORT", "1521")
DB_SERVICE = os.getenv("DB_SERVICE", "XE")

# Build Oracle connection string for SQLAlchemy
DATABASE_URL = f"oracle+oracledb://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/?service_name={DB_SERVICE}"
engine = create_engine(DATABASE_URL)

@app.route("/health")
def health():
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1 FROM dual"))
        return jsonify({"status": "ok", "database": "connected"})
    except Exception as e:
        return jsonify({"status": "error", "details": str(e)}), 500

@app.route("/users", methods=["POST"])
def add_user():
    data = request.get_json()
    username = data.get("username")
    with engine.begin() as conn:
        conn.execute(text("INSERT INTO users (username) VALUES (:username)"), {"username": username})
    return jsonify({"message": f"User {username} added!"})

@app.route("/users", methods=["GET"])
def get_users():
    with engine.connect() as conn:
        result = conn.execute(text("SELECT id, username FROM users")).fetchall()
    users = [{"id": row[0], "username": row[1]} for row in result]
    return jsonify(users)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
