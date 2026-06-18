# --- Stage 1: The Build Environment ---
FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder
WORKDIR /build

# Copy only the dependency file first to leverage Docker's caching layer
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the actual source code and build the application packaging
COPY src ./src
RUN mvn package -DskipTests

# --- Stage 2: The Production Runtime ---
FROM eclipse-temurin:17-jre-alpine AS runner
WORKDIR /app

# Create a non-root system user for security enforcement
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy the compiled JAR from the builder stage
COPY --from=builder /build/target/*.jar app.jar

# Switch to the non-root user so the container doesn't run as root in the cloud
USER appuser

# Expose the internal container port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]