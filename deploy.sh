#!/bin/bash

# Switch Docker to use Minikube's environment
eval $(minikube docker-env)

# Build the Spring Boot Docker image
echo "Building Docker image spring-demo:latest..."
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

#kubectl exec -it spring-demo-6665c8749d-4t96r -- curl http://localhost:8082/demo/actuator/health