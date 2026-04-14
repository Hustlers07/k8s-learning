# If you're running Kubernetes locally (minikube, Docker Desktop, etc.), you might not have a real external IP. In that case, use:

kubectl port-forward svc/nginx-service 8080:80

http://localhost:8080

    
# Get node ip
kubectl get nodes -o wide

eval $(minikube docker-env)



cat > /tmp/kubectl_port_forward.sh << 'EOF'
#!/bin/bash

# kubectl port-forwarding command to run in the background
# This forwards local port 8080 to pod port 8080 in the default namespace

# Example 1: Basic port-forwarding
kubectl port-forward pod/demo 8080:8080 &

# Alternative examples:

# Example 2: Port-forward to a service
# kubectl port-forward svc/demo 8080:8080 &

# Example 3: Port-forward with specific namespace
# kubectl port-forward -n my-namespace pod/demo 8080:8080 &

# Example 4: Port-forward with address binding
# kubectl port-forward --address 0.0.0.0 pod/demo 8080:8080 &

# To check the background job:
# jobs
# ps aux | grep "kubectl port-forward"

# To stop the port-forward:
# kill %1  (if it's job #1)
# or
# pkill -f "kubectl port-forward"

EOF
cat /tmp/kubectl_port_forward.sh