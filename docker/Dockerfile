# --- STAGE 1: Build (Optimization) ---
# This stage uses the full Maven image to compile your code
FROM maven:3.9.6-eclipse-temurin-17-alpine AS build
WORKDIR /app

# 1. Copy pom.xml and download dependencies (for better caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# 2. Copy your actual src directory structure
COPY src ./src

# 3. Build the JAR file
RUN mvn package -DskipTests

# --- STAGE 2: Runtime (Minimal Size & Security) ---
# This stage uses a tiny JRE image and only the final JAR
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Best Practice: Run as a non-root user
RUN addgroup -S spring && adduser -S spring -G spring
USER spring

# 4. Copy the JAR from the build stage 
# This handles whatever filename Maven generated automatically
COPY --from=build /app/target/*.jar app.jar

# Requirement: Port 8080
EXPOSE 8080

# Requirement: Health Check
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -q --spider http://localhost:8080/health || exit 1

ADD https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip /tmp/newrelic.zip
RUN unzip /tmp/newrelic.zip -d /opt && rm /tmp/newrelic.zip

ENTRYPOINT ["java", "-javaagent:/opt/newrelic/newrelic.jar", "-jar", "/app/app.jar"]
