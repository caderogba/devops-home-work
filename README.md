
# Health Check API

This project consists of a minimal Spring Boot REST API and an optimized Docker configuration. The application provides a simple health check endpoint and is designed with production-grade security and performance in mind.

## Project Structure
```
devops-take-home/
├── README.md           # Project documentation
├── docker/
│   └── Dockerfile      # Optimized multi-stage Dockerfile
├── src/                # Java source code
├── pom.xml             # Maven configuration
└── ... (terraform/workflows)
```

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

