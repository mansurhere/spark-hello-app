# -------------------------
# Stage 1: Build the JAR
# -------------------------
FROM amazoncorretto:17-alpine3.22-jdk AS builder

RUN apk add --no-cache maven

# Set working directory for Maven
WORKDIR /app

# Copy only necessary files first to leverage Docker cache
COPY pom.xml .
#Copy source code
COPY src ./src

# Optional: Fix for Maven wrapper if used
RUN mkdir -p .mvn && chmod -R 777 .mvn

# Build the JAR (skipping tests to speed up build)
RUN mvn clean package -DskipTests

# -------------------------------
# Stage 2: Spark Runtime (Apache)
# -------------------------------
FROM apache/spark:3.5.1
#FROM apache/spark:3.5.3-java17
# Switch to root to copy files
USER root

# Create necessary directories
RUN mkdir -p /opt/spark/jars /opt/spark/work-dir

# Copy the JAR from the builder stage
COPY --from=builder /app/target/spark-hello-job-1.0.jar /opt/spark/jars/

# Create non-root user
RUN useradd -u 1000 -m -d /home/sparkuser -s /bin/bash sparkuser && \
    mkdir -p /tmp/spark-events /home/sparkuser/.ivy2 && \
    chown -R sparkuser:sparkuser /home/sparkuser /tmp/spark-events && \
    chmod -R 755 /tmp/spark-events /home/sparkuser

# Copy the built JAR into Spark's jars folder
COPY --from=builder --chown=sparkuser:sparkuser /app/target/spark-hello-job-1.0.jar /opt/spark/jars/

USER sparkuser

WORKDIR /home/sparkuser

ENV HOME=/home/sparkuser \
    HADOOP_USER_NAME=sparkuser \
    SPARK_HOME=/opt/spark

