from flask import Flask, jsonify, request
from sqlalchemy import create_engine, text
import os

app = Flask(__name__)

# --- Database Configuration ---
# FIX: Removed the hardcoded default passwords.
# Now, the app reads strictly from the Environment Variables injected by Docker.
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_SERVICE = os.getenv("DB_SERVICE")

# Check if credentials are present (Fail Fast pattern)
if not all([DB_USER, DB_PASSWORD, DB_HOST, DB_SERVICE]):
    raise ValueError("Missing required database environment variables. Check your .env file.")

DATABASE_URL = f"oracle+oracledb://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/?service_name={DB_SERVICE}"
engine = create_engine(DATABASE_URL)


# --- Routes ---
@app.route("/health")
def health():
    """Health check for app + DB connection"""
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1 FROM dual"))
        return jsonify({"status": "ok", "database": "connected"})
    except Exception as e:
        return jsonify({"status": "error", "details": str(e)}), 500


@app.route("/users", methods=["POST"])
def add_user():
    """Add a new user"""
    data = request.get_json()
    username = data.get("username")
    if not username:
        return jsonify({"error": "username is required"}), 400

    with engine.begin() as conn:
        conn.execute(text("INSERT INTO users (username) VALUES (:username)"), {"username": username})

    return jsonify({"message": f"User '{username}' added!"})


@app.route("/users", methods=["GET"])
def get_users():
    """Fetch all users"""
    with engine.connect() as conn:
        result = conn.execute(text("SELECT id, username FROM users")).fetchall()

    users = [{"id": row[0], "username": row[1]} for row in result]
    return jsonify(users)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)