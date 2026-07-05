# Resilient Ping 🚀

A cloud-native Java and Spring Boot telemetry application designed to monitor network availability and track uptime metrics. This project serves as a showcase for end-to-end DevOps automation, modern container orchestration, infrastructure as code, and robust system observability.

## 🛠️ Tech Stack & Architecture

- **Backend App:** Java / Spring Boot (Micrometer for telemetry)
- **Containerization:** Docker (Multi-stage builds)
- **Orchestration:** Kubernetes (K8s)
- **Infrastructure as Code:** Terraform
- **Cloud Platform:** AWS (VPC, EC2, IAM)
- **CI/CD Pipeline:** GitHub Actions
- **Observability:** Prometheus & Grafana

## 🏗️ DevOps & Core Features

### 🐋 Containerization
- Optimized using **Docker multi-stage builds** to ensure the final production image contains only the compiled runtime artifact, minimizing attack surface and image size.
- Utilizes layered caching to accelerate build times.

### ☸️ Kubernetes Orchestration
- Managed via declarative Kubernetes manifests implementing self-healing **Deployments** to guarantee continuous high availability.
- Exposes workloads securely inside the cluster utilizing **Services** to act as permanent network switchboards routing traffic across dynamic Pod lifecycles.

### 🗺️ Infrastructure as Code (IaC)
- Fully provisioned using **Terraform** to prevent configuration drift. 
- Automatically deploys a secure, isolated network topology (VPC, private subnets, security groups) and relies on **AWS IAM Roles** to eliminate hardcoded credentials entirely.

### 🪵 Automated CI/CD
- Engineered a **GitHub Actions** pipeline triggered on every code push.
- Automatically provisions a temporary runner VM to compile, test, containerize, and package the application securely.

### 📊 End-to-End Observability
- Exposes system vitals and customized telemetry counters via a machine-readable `/metrics` endpoint.
- Uses **Prometheus** to pull/scrape data intervals dynamically, feeding a centralized **Grafana** dashboard to visualize real-time system success rates and monitor infrastructure health.

## 🚀 Getting Started

### Prerequisites
- Java 17+
- Docker & Kubernetes (Minikube / Docker Desktop)
- Terraform

### Local Development & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Andy916/resilient-ping.git
   cd resilient-ping
   ```
2. **Initialize Infrastructure (Terraform):**
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```
3. **Deploy to Kubernetes:**
   ```bash
   kubectl apply -f k8s/
   ```
4. **Verify Application Observability:**
   Access the raw metrics endpoint locally to verify telemetry tracking:
   ```bash
   curl http://localhost:8080/metrics
   ```
