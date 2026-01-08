# Java Spring Boot REST API on AWS ECS Fargate

## Overview
This project demonstrates a **production-ready Java Spring Boot REST API** deployed on **AWS ECS Fargate**, fronted by an **Application Load Balancer (ALB)**, built and deployed using **Terraform** and **GitHub Actions**.

The solution is **multi-environment (dev/prod)**, follows **least-privilege security principles**, and includes **observability via CloudWatch and New Relic**.

---

## Infrastructure Overview

The infrastructure is fully defined using Terraform modules and includes:

- **VPC** with public and private subnets across 2 Availability Zones
- **Internet Gateway** for public internet access
- **Application Load Balancer (ALB)** in public subnets
- **ECS Fargate** cluster and service in private subnets
- **ECR** for container image storage
- **IAM Roles** with least privilege (task execution + task role)
- **Security Groups** enforcing ALB → ECS only access
- **CloudWatch Log Groups** for application logs
- **New Relic** for APM, infrastructure metrics, logs, and alerts

---

## Architecture Diagram

```
                Internet
                    |
                    v
        +------------------------+
        | Application Load       |
        | Balancer (Public)      |
        +-----------+------------+
                    |
                    v
        +------------------------+
        | ECS Fargate Service    |
        | (Private Subnets)      |
        |  - Spring Boot App     |
        |  - New Relic Agent     |
        +-----------+------------+
                    |
      +-------------+-------------+
      |                           |
      v                           v
 CloudWatch Logs            New Relic
 (Logs & Metrics)     (APM, Infra, Alerts)
```

---

## Prerequisites

### Required Tools

- AWS CLI (v2)
- Terraform >= 1.4
- Docker
- Java 17+
- Maven
- GitHub account

---

## AWS Credentials & Permissions

### Required AWS Permissions

Your AWS user/role must be able to manage:

- VPC, Subnets, Internet Gateway
- ECS, ECR, ALB
- IAM roles and policies
- CloudWatch Logs
- Secrets Manager

Recommended policies:

- `AdministratorAccess` (for learning/demo)
- OR scoped IAM permissions for production

### Local AWS Authentication

```bash
aws configure
```

or via environment variables:

```bash
export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=xxx
export AWS_DEFAULT_REGION=us-east-1
```

---

## Required GitHub Secrets

Configure the following **repository secrets**:

| Secret Name | Description |
|------------|-------------|
| AWS_ACCESS_KEY_ID | AWS access key |
| AWS_SECRET_ACCESS_KEY | AWS secret key |
| AWS_REGION | AWS region (e.g. us-east-1) |
| ECR_REPOSITORY | ECR repository name |
| NEW_RELIC_LICENSE_KEY | New Relic license key |


## Terraform Usage

### Environment Structure

```text
terraform/
  envs/
    dev/
    prod/
  modules/
    vpc/
    alb/
    ecs/
    iam/
    ecr/
    logs/
```

### Initialize Terraform

```bash
terraform init
```

### Plan Changes

```bash
terraform plan -var-file=dev.tfvars
```

### Apply Infrastructure

```bash
terraform apply -var-file=dev.tfvars
```

---

## CI/CD Pipeline (GitHub Actions)

### Triggers

- **Pull Request** → build & test only
- **Push to main** → build, push to ECR, deploy to ECS

### Pipeline Stages

1. Build Java application
2. Run unit tests
3. Build Docker image
4. Push image to ECR
5. Update ECS task definition
6. Deploy and verify service

---

## Observability & Monitoring

### CloudWatch

- Application logs
- ECS task logs

### New Relic

- Java APM metrics
- ECS/Fargate infrastructure metrics
- Log aggregation
- Alerts for performance & availability

---

## Troubleshooting Guide

### ❌ Terraform Errors

- Ensure all module variables are declared
- Verify correct IAM permissions
- Run `terraform validate`

### ❌ ECS Tasks Not Starting

- Check CloudWatch logs
- Verify IAM task execution role
- Confirm ECR image exists

### ❌ ALB Health Check Failing

- Ensure `/health` endpoint is reachable
- Confirm security group allows ALB → ECS

### ❌ New Relic Data Missing

- Verify license key secret access
- Confirm New Relic sidecar is running
- Check ECS task environment variables

---

## Security Best Practices

- Private subnets for ECS tasks
- ALB is the only internet-facing component
- Secrets stored in AWS Secrets Manager
- Least-privilege IAM roles
- TLS recommended for production

---

## Environments

| Environment | Purpose |
|------------|--------|
| dev | Development & testing |
| prod | Production workload |
---

## Summary

✔ Fully automated infrastructure
✔ Secure, scalable architecture
✔ Multi-environment support
✔ CI/CD with GitHub Actions
✔ Full observability with New Relic


# Application Build & Run

This project consists of a minimal Spring Boot REST API and an optimized Docker configuration. The application provides a simple health check endpoint and is designed with production-grade security and performance in mind.

## Prerequisites 
- Docker
- Java 17 (if running locally without docker)
- Maven 3.9+ (if running locally without docker)

## Run Locally (without Docker)
```bash
mvn spring-boot:run
```
## Run tests
```bash
mvn test
```

## Building and Deployment
1. Build the Docker Image

Run the build from the project root and point to the file explicitly:
```bash
docker build -t health-api:v1 -f docker/Dockerfile .
```

2. Run the Application

```bash
docker run -d \
  --name health-app \
  -p 8080:8080 \
  health-api:v1
```

3. Verify the Deployment

- Access the API: `curl http://localhost:8080/health`

Expected response:
```json
{"status":"ok"}
```

- Check Container Health: `docker ps` (Look for the (healthy) status)

- Verify Security: `docker exec health-app whoami`

Expected response:
```
spring
```

## Dockerfile Choices

- Multi-Stage Build: Separation of concerns. Stage 1 (Build) uses a full Maven/JDK image to compile code, while Stage 2 (Runtime) uses a minimal JRE. This keeps the production image small (~160MB).

- Base Image: Uses eclipse-temurin:17-jre-alpine. This is a trusted, official OpenJDK distribution. The alpine variant is chosen to minimize the attack surface and image size.

- Context management: `-f docker/Dockerfile` keeps Dockerfile in `docker/` while building from project root.

- Layer Caching: We COPY pom.xml and run dependency:go-offline before copying the source code. This ensures that Docker caches dependencies, making subsequent builds much faster.

- Note on Testing: > The Dockerfile uses -DskipTests to optimize build speed and ensure the packaging process is decoupled from the test suite execution. Tests should ideally be executed in the CI pipeline (GitHub Actions) prior to the image build stage.

- Security (Non-Root User): The container runs under a custom spring user. Following the Principle of Least Privilege, this prevents potential exploits from gaining root access to the container or host.

- Native Health Check: Implements a HEALTHCHECK instruction using wget. This allows orchestrators (like AWS ECS or Kubernetes) to monitor the application's actual readiness, not just the process status.

## Troubleshooting
| Issue | Cause | Solution |
| --- | --- | --- |
| dockerfile: no such file | Running build in wrong directory | Ensure you are in the root devops-take-home folder and use the -f flag. |
| Port 8080 already in use | Local service conflict | Check: `lsof -i :8080` or  run on another port: `docker run -d --name health-app -p 8081:8080 health-api:v1` |
| Conflict. The container names `health-app` is already in use | Container with the same name exists from a previous run. | `docker rm -f health-app` then rerun. |


- View container logs:
  - `docker logs --tail=100 -f health-app`
- Rebuild after dependency changes:
  - `docker build --no-cache -t health-api:v1 -f docker/Dockerfile .`

