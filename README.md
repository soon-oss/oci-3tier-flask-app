# OCI 3-Tier Flask App (Portfolio Project)

A containerised 3-tier web application built with Flask, Oracle XE Database, and Docker Compose.  
This project simulates a typical cloud-native architecture that could be deployed on Oracle Cloud Infrastructure (OCI) or any modern cloud platform.

---

## 🏗 Architecture
![Architecture Diagram](architecture.png)


---

## ⚙️ Tech Stack
- Python 3.10  
- Flask (REST API)  
- Oracle XE 21c Database (Dockerized)  
- Docker / Docker Compose  

---

## How to run

1. Clone the repository:

   ```bash
   git clone https://github.com/soon-oss/oci-3tier-flask-app.git
   cd oci-3tier-flask-app
   ```

3. Build and start the containers:

   ```bash
   docker compose up --build -d
   docker exec -it oracle-db bash -c "createAppUser APPUSER AppPass123"
   docker compose restart flask-app
   ```

4. Access the Flask app:
   
- API base: http://localhost:5000
- Health check: http://localhost:5000/health
- Users endpoint: http://localhost:5000/users

---

## Features

- /health → verifies the app is running
- /users → fetches dummy users from the Oracle DB

---

## Next Steps

- Deploy this app to Oracle Cloud (when tenancy is active)
- Add JWT authentication for users
- Add a frontend UI with Bootstrap or React
- Automate with CI/CD pipeline

---

👤 Author
Created by soon-oss
