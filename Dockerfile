FROM apache/spark:3.5.1

USER root

# Create necessary directories and copy JAR
RUN mkdir -p /opt/spark/jars /opt/spark/work-dir
COPY target/spark-hello-app-2.7.0.jar /opt/spark/jars/

# Fix permissions for non-root user
RUN chown -R 185:185 /opt/spark && chmod -R 755 /opt/spark

USER 185
WORKDIR /opt/spark/work-dir
