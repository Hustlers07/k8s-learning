#!/bin/bash

# Switch Docker to use Minikube's environment
eval $(minikube docker-env)

# # Deleting existing deployment if it exists
# echo "Deleting existing Kubernetes deployment (if it exists)..."
# kubectl delete -f ./k8s/k8s-spring-deployment.yaml --ignore-not-found

# Apply the Kubernetes deployment
echo "Applying Kubernetes deployment..."
kubectl apply -f ./k8s/k8s-spring-deployment.yaml

echo "Done! Your Spring Boot app should now be deployed to Minikube."

# Checking pods
echo "Checking pods"
kubectl get pods

#kubectl exec -it spring-demo-654c766db8-hzd8f -- curl http://localhost:8080/demo/actuator/health