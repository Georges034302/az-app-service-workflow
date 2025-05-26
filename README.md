## 🐍 Employee API (Containerized Python App on Azure App Service)

This project provides a minimal FastAPI-based backend API to simulate an employee directory. The API is packaged into a Docker container, pushed to Azure Container Registry (ACR), and deployed to Azure App Service for Linux using **GitHub Actions**.

---

### 📌 Features

- ✅ Python + FastAPI-based backend API
- 📦 Dockerized and deployed to **Azure App Service**
- 🔁 CI/CD pipeline with **GitHub Actions**
- 🔐 Secure credentials via **GitHub Secrets**
- 🧪 Mock data served from a local JSON file

---

### 🧪 API Endpoints

| Method | Endpoint                   | Description                        |
|--------|----------------------------|------------------------------------|
| GET    | `/users`                   | List all employees                 |
| GET    | `/users/{id}`              | Get a single employee by ID        |

**Full API URLs after deployment:**

- **Get all users:**  
  ```
  https://<APP_NAME>.azurewebsites.net/users
  ```

- **Get user by ID (example for user 2):**  
  ```
  https://<APP_NAME>.azurewebsites.net/users/2
  ```

Replace `<APP_NAME>` with your actual Azure App Service name.

Sample response from `/users`:
```json
[
  {"id": 1, "name": "Alice", "role": "Manager", "department": "HR", "city": "Sydney"},
  {"id": 2, "name": "Bob", "role": "Developer", "department": "IT", "city": "Melbourne"},
  {"id": 3, "name": "Eve", "role": "Analyst", "department": "Finance", "city": "Brisbane"}
]
```

---

### ⚙️ Setup Instructions

#### 1. 🔁 GitHub Actions Workflows

**How these are used in the workflow:**

- **setup-iac.yml**:  
  *Run once to provision Azure resources and set up infrastructure-as-code (IAC) using the above secrets.*

- **deploy.yml**:  
  *Used for configuring and deploying the App Service container. This workflow expects all secrets to be present and resources to already exist (created by `setup-iac.yml`).*

---

#### 2. 📁 Project Structure

```
az-app-service-workflow/
├── .github/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py
│   │   └── data.json
│   ├── scripts/
│   │   ├── acr_setup.sh
│   │   ├── az_login.sh
│   │   ├── az_setup.sh
│   │   ├── configure_app_service.sh
│   │   ├── deploy_app_service_container.sh
│   │   ├── gh_setup.sh
│   │   ├── output.sh
│   │   ├── setup.sh
│   │   └── tools_config.sh
│   └── workflows/
│       ├── deploy.yml
│       └── setup-iac.yml
├── Dockerfile
├── requirements.txt
└── README.md
```

---

#### 3. ⚙️ Local Setup & Deployment

I. **Authenticate and configure environment: (Run-Once)**  
   ```bash
   cd .github/scripts
   bash setup.sh
   ```

II. **Deploy to Azure (manual run):**  
   ```bash
   cd .github/scripts
   bash deploy.sh
   ```

---

#### 4. 🚀 CI/CD with GitHub Actions

- Triggered on push to `main` branch.
- setup.yaml is manual run-once configuration workflow
- deploy.yaml workflow runs on push
- Uses GitHub secrets and scripts to:
  - Log in to Azure
  - Build and push Docker image to ACR
  - Configure App Service to use image
  - Deploy container-app to App Service

---

#### 5. 🐳 Local Docker Run (for testing)

```bash
docker build -t employee-api .
docker run -d -p 80:80 employee-api
```

Access API at: [http://localhost](http://localhost)

---

#### 👨‍💻 Author: Georges Bou Ghantous
*This repository demonstrates automated deployment of a Python FastAPI app to Azure App Service and Azure Container Registry (ACR) using GitHub Actions. 💙*
