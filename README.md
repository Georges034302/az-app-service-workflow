# 🐍 Employee API (Containerized Python App on Azure App Service)

This project provides a minimal FastAPI-based backend API to simulate an employee directory. The API is packaged into a Docker container, pushed to Azure Container Registry (ACR), and deployed to Azure App Service for Linux using **GitHub Actions**.

---

## 📌 Features

- ✅ Python + FastAPI-based backend API
- 📦 Dockerized and deployed to **Azure App Service**
- 🔁 CI/CD pipeline with **GitHub Actions**
- 🔐 Secure credentials via **GitHub Secrets**
- 🧪 Mock data served from a local JSON file

---

## 🧪 API Endpoints

| Method | Endpoint         | Description                 |
|--------|------------------|-----------------------------|
| GET    | `/users`         | List all employees          |
| GET    | `/users/{id}`    | Get a single employee by ID |

Sample response from `/users`:
```json
[
  {"id": 1, "name": "Alice", "role": "Manager", "department": "HR", "city": "Sydney"},
  {"id": 2, "name": "Bob", "role": "Developer", "department": "IT", "city": "Melbourne"},
  {"id": 3, "name": "Eve", "role": "Analyst", "department": "Finance", "city": "Brisbane"}
]
```

---

## ⚙️ Setup Instructions

### 1. 🔐 GitHub Secrets Required

| Secret Name             | Description                                      |
|-------------------------|--------------------------------------------------|
| `AZURE_CREDENTIALS`     | Output of `az ad sp create-for-rbac` (JSON)     |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID                           |
| `RESOURCE_GROUP`        | Azure resource group name                       |
| `ACR_NAME`              | Azure Container Registry name (e.g., myregistry)|
| `APP_NAME`              | Azure App Service name                          |

---

### 2. 📁 Project Structure

```
employee-api/
├── app/
│   ├── __init__.py
│   ├── main.py
│   └── data.json
├── azure/
│   ├── deploy.sh
│   ├── login.sh
│   └── configure-container.sh
├── .github/
│   └── workflows/
│       └── deploy.yml
├── Dockerfile
├── requirements.txt
└── README.md
```

---

### 3. ☁️ Azure CLI Deployment

```bash
cd azure
bash deploy.sh
```

This script provisions the Azure infrastructure stack and prepares the app for deployment.

---

### 4. 🚀 CI/CD with GitHub Actions

Triggered on push to `main` branch. Uses GitHub secrets and scripts to:

- Log in to Azure
- Build and push Docker image to ACR
- Configure App Service to use image

---

### 5. 🐳 Local Docker Run (for testing)

```bash
docker build -t employee-api .
docker run -d -p 80:80 employee-api
```

Access API at: [http://localhost](http://localhost)

---

## 🛡️ License

MIT License
