# -------------------------
# Stage 1: Build the JAR
# -------------------------
FROM maven:3.9.11-amazoncorretto-11-debian AS builder

# Set working directory
WORKDIR /app

# Copy only necessary files first to leverage Docker cache
COPY pom.xml .
COPY src ./src

# Build the JAR
RUN mvn clean package -DskipTests

# -------------------------
# Stage 2: Final Spark Runtime
# -------------------------
FROM apache/spark:3.5.1

# Switch to root to copy files
USER root

# Create necessary directories
RUN mkdir -p /opt/spark/jars /opt/spark/work-dir

# Copy the JAR from the builder stage
COPY --from=builder /app/target/spark-hello-app-*.jar /opt/spark/jars/

# Set correct permissions for non-root user
RUN chown -R 185:185 /opt/spark && chmod -R 755 /opt/spark

# Drop to non-root user and set working directory
USER 185
WORKDIR /opt/spark/work-dir
