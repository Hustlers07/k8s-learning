#!/bin/bash

# Switch Docker to use Minikube's environment
eval $(minikube docker-env)

# Run Maven clean install to build the JAR
echo "Running Maven clean install..."
mvn clean install -DskipTests

# Delete old Docker image if it exists
#echo "Deleting old Docker image spring-demo:latest (if present)..."
#docker rmi -f spring-demo:latest || true

# Build the Spring Boot Docker image without using cache
echo "Building new Docker image spring-demo:latest (no cache)..."
#docker build --no-cache -t spring-demo:latest .
docker build -t spring-demo:latest .

# Deleting existing deployment if it exists
echo "Deleting existing Kubernetes deployment (if it exists)..."
kubectl delete -f ./k8s/k8s-spring-deployment.yaml --ignore-not-found

# Apply the Kubernetes deployment
echo "Applying Kubernetes deployment..."
kubectl apply -f ./k8s/k8s-spring-deployment.yaml

echo "Done! Your Spring Boot app should now be deployed to Minikube."

# Checking pods
echo "Checking pods"
kubectl get pods

#kubectl exec -it spring-demo-654c766db8-hzd8f -- curl http://localhost:8080/demo/actuator/health