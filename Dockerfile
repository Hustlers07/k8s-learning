# Use a lightweight JDK base image
FROM eclipse-temurin:17

# Set working directory
WORKDIR /app

# Copy the jar file into the container
COPY target/demo-0.0.1-SNAPSHOT.jar app.jar

# Run the jar
ENTRYPOINT ["java","-jar","app.jar"]
