# OCI 3-tier Flask App (local)

This project simulates a 3-tier cloud app locally:
- Flask app (web)
- Oracle XE (DB) container
- Docker Compose orchestration

## How to run

\`\`\`bash
docker compose up --build -d
docker exec -it oracle-db bash -c "createAppUser APPUSER AppPass123"
docker compose restart app
\`\`\`

Visit [http://localhost:5000](http://localhost:5000).
# oci-3tier-flask-app
