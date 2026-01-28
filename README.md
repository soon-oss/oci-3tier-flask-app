# OCI 3-Tier Cloud-Native Application ☁️

![CI Pipeline](https://github.com/soon-oss/oci-3tier-flask-app/actions/workflows/ci.yml/badge.svg)
![Oracle 23ai](https://img.shields.io/badge/Oracle-Database%2023ai-c74634?logo=oracle&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Multi--Stage-2496ed?logo=docker&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7b42bc?logo=terraform&logoColor=white)

> **🏆 Award Winner:** Rated Top 500 Learner (out of 1M+ participants) in the **Oracle Race to Certification 2025**.

## 📖 Project Overview
This repository demonstrates a **production-grade 3-tier web architecture** designed for the Oracle Cloud Infrastructure (OCI) ecosystem. 

Unlike standard tutorials, this project simulates a real-world enterprise environment locally using **Docker Compose** for orchestration and **Terraform** for network modeling. It implements strict **DevSecOps** principles, including automated CI/CD pipelines, secret management, and least-privilege container security.

### 🏗 Architecture
The application follows a strict separation of concerns (Public vs. Private Subnets) to mimic an OCI VCN design.

```mermaid
graph TD;
    User((Internet User)) -->|HTTPS/443| LB[Load Balancer / Gateway];
    
    subgraph "Public Subnet (DMZ)"
        LB -->|Traffic Route| Flask[Flask Application Container];
    end
    
    subgraph "Private Subnet (Secured)"
        Flask -->|Net Protocol / Port 1521| DB[(Oracle Database 23ai)];
    end

    style Flask fill:#2496ed,stroke:#fff,stroke-width:2px,color:#fff
    style DB fill:#c74634,stroke:#fff,stroke-width:2px,color:#fff

```

## 🚀 Key Features

* **☁️ Cloud-Native Simulation:** Uses **Terraform** (`main.tf`) to model OCI Virtual Cloud Networks (VCN), separating Public (App) and Private (DB) subnets.
* **🐳 Optimized Containers:** Implements **Multi-Stage Docker Builds** to reduce image size and remove build tools from production.
* **🛡️ Enterprise Security:** * **Non-Root User:** Containers run as `appuser`, not root.
* **Secret Management:** Credentials injected via Environment Variables (never hardcoded).
* **Oracle Thin Mode:** Uses `python-oracledb` for efficient, client-less connections.


* **🤖 Automated DevOps:** A **GitHub Actions** pipeline automatically lints code (`flake8`), builds Docker images, and scans for vulnerabilities (`Trivy`) on every push.

## 🛠 Tech Stack

| Component | Technology | Role |
| --- | --- | --- |
| **Frontend/API** | Python Flask | REST API & Web Server |
| **Database** | Oracle Database 23ai | Vector-Ready Relational DB |
| **Infrastructure** | Terraform | Infrastructure as Code (IaC) |
| **Orchestration** | Docker Compose | Local Microservices Management |
| **CI/CD** | GitHub Actions | Automated Testing & Security Scanning |

## ⚡ Quick Start

### Prerequisites

* Docker & Docker Compose installed.
* Git installed.

### 1. Clone the Repository

```bash
git clone [https://github.com/soon-oss/oci-3tier-flask-app.git](https://github.com/soon-oss/oci-3tier-flask-app.git)
cd oci-3tier-flask-app

```

### 2. Launch the Stack

This command spins up the Database and App. The App will automatically **wait** for the Database to be healthy before starting (using Healthchecks).

```bash
docker-compose up --build

```

### 3. Verify Deployment

* **Web App:** Visit `http://localhost:5000`
* **Health Check:** Visit `http://localhost:5000/health` (Returns JSON DB status)

## 👨‍💻 About the Author

**Certified OCI Architect & DevOps Professional**

Building bridges between On-Premise legacy and Cloud-Native futures.

* **Certifications:** OCI Architect Associate, OCI DevOps Professional, OCI Migrations Architect Professional.
* **Focus:** Kubernetes, Terraform, and Secure Cloud Architecture.
* **Contact:** [[LinkedIn](https://www.linkedin.com/in/desmond-soon-248889390/)]