# Kubernetes Ingress Configuration Guide

## Overview
This guide covers setting up Ingress for MySQL, phpMyAdmin, and Spring Boot applications in Kubernetes.

## Files Created

### 1. `k8s-ingress.yaml` - Production Ingress
For cloud environments (AWS, GCP, Azure, etc.)

### 2. `k8s-ingress-minikube.yaml` - Development/Minikube Ingress
For local development with Minikube

## File Structure

```
k8s/
├── k8s-mysql-deployement.yml      # MySQL + phpMyAdmin deployments
├── k8s-spring-deployment.yaml      # Spring Boot deployment
├── k8s-ingress.yaml                # Production ingress
├── k8s-ingress-minikube.yaml       # Development ingress
└── README.md                        # Setup guide
```

## Deployment Instructions

### Prerequisites
```bash
# Verify kubectl is configured
kubectl cluster-info

# Check if NGINX Ingress Controller is installed
kubectl get pods -n ingress-nginx

# If not installed, install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# For Minikube, enable ingress addon
minikube addons enable ingress
```

## Setup Steps

### Step 1: Deploy MySQL and phpMyAdmin
```bash
kubectl apply -f k8s/k8s-mysql-deployement.yml
kubectl get pods -w  # Wait for MySQL pod to be ready
```

### Step 2: Deploy Spring Boot Application
```bash
kubectl apply -f k8s/k8s-spring-deployment.yaml
kubectl get pods -w  # Wait for Spring pods to be ready
```

### Step 3: Deploy Ingress

**For Minikube/Local Development:**
```bash
kubectl apply -f k8s/k8s-ingress-minikube.yaml
```

**For Cloud Environments (Production):**
```bash
kubectl apply -f k8s/k8s-ingress.yaml
```

### Step 4: Verify Ingress
```bash
kubectl get ingress
kubectl describe ingress phpmyadmin-ingress
```

## Access Your Applications

### Option A: Minikube with Ingress

1. **Get Minikube IP:**
   ```bash
   MINIKUBE_IP=$(minikube ip)
   echo $MINIKUBE_IP
   ```

2. **Add to /etc/hosts:**
   ```bash
   echo "$MINIKUBE_IP phpmyadmin.local spring-demo.local" | sudo tee -a /etc/hosts
   ```

3. **Access Applications:**
   - phpMyAdmin: `http://phpmyadmin.local`
   - Spring Boot: `http://spring-demo.local`
   - MySQL: `telnet localhost 30306`

### Option B: Port Forwarding (Alternative)

```bash
# Access phpMyAdmin
kubectl port-forward svc/phpmyadmin-service 8080:80 &

# Access Spring Boot
kubectl port-forward svc/spring-demo-service 8081:8081 &

# Access MySQL
kubectl port-forward svc/mysql-service 3306:3306 &
```

Then:
- phpMyAdmin: `http://localhost:8080`
- Spring Boot: `http://localhost:8081`
- MySQL: `mysql -h localhost -u demo -p demo -D demo`

### Option C: Cloud Load Balancer (Production)

```bash
# Get external IP
kubectl get svc phpmyadmin-service
kubectl get svc spring-demo-service

# Access via Load Balancer IP
# http://<EXTERNAL-IP>:80
# http://<EXTERNAL-IP>:8081
```

## Network Policies

The ingress configurations include NetworkPolicy to ensure:
- ✅ phpMyAdmin can access MySQL
- ✅ Spring Boot can access MySQL
- ✅ Other pods cannot access MySQL directly

Verify network policy:
```bash
kubectl get networkpolicy
kubectl describe networkpolicy mysql-network-policy
```

## Ingress Rules Summary

### Production Ingress (k8s-ingress.yaml)

| Hostname | Service | Port | Type |
|----------|---------|------|------|
| phpmyadmin.example.com | phpmyadmin-service | 80 | HTTP |
| mysql.example.com | mysql-service | 3306 | TCP (via LoadBalancer) |

### Development Ingress (k8s-ingress-minikube.yaml)

| Hostname | Service | Port | Type |
|----------|---------|------|------|
| phpmyadmin.local | phpmyadmin-service | 80 | HTTP |
| spring-demo.local | spring-demo-service | 8081 | HTTP |
| localhost:30306 | mysql-nodeport-service | 3306 | TCP (via NodePort) |

## MySQL Connectivity Options

### 1. Within Kubernetes (Pod-to-Pod)
```bash
# From any pod
mysql -h mysql-service -u demo -p demo -D demo
```

### 2. From External Machine (Minikube)
```bash
mysql -h <MINIKUBE_IP> -P 30306 -u demo -p demo -D demo
```

### 3. From External Machine (Cloud)
```bash
# Get LoadBalancer External IP first
kubectl get svc mysql-external-service
mysql -h <EXTERNAL-IP> -P 3306 -u demo -p demo -D demo
```

## DNS Resolution

### Minikube Setup
```bash
# Add to /etc/hosts
<MINIKUBE_IP> phpmyadmin.local
<MINIKUBE_IP> spring-demo.local
```

### Cloud Setup
```bash
# Configure DNS records
phpmyadmin.example.com  -> Load Balancer IP
spring-demo.example.com -> Load Balancer IP
mysql.example.com       -> LoadBalancer IP
```

## Troubleshooting

### Ingress not working
```bash
# Check ingress status
kubectl get ingress
kubectl describe ingress phpmyadmin-ingress

# Check ingress controller logs
kubectl logs -n ingress-nginx deployment/nginx-ingress-controller
```

### Cannot connect to MySQL
```bash
# Check MySQL service
kubectl get svc mysql-service
kubectl get svc mysql-nodeport-service

# Test MySQL pod
kubectl exec -it <mysql-pod> -- mysql -u demo -p demo -D demo
```

### phpMyAdmin connection refused
```bash
# Check phpMyAdmin pod
kubectl logs <phpmyadmin-pod>

# Verify network policy allows connection
kubectl get networkpolicy mysql-network-policy
```

### DNS resolution issues
```bash
# Test DNS from pod
kubectl exec -it <pod> -- nslookup mysql-service
kubectl exec -it <pod> -- nslookup phpmyadmin-service

# For Minikube, verify /etc/hosts
cat /etc/hosts | grep local
```

## Cleanup

To remove all ingress configurations:
```bash
kubectl delete -f k8s/k8s-ingress.yaml
# OR
kubectl delete -f k8s/k8s-ingress-minikube.yaml
```

## Security Considerations

1. **HTTPS/TLS**: Production setup includes cert-manager for automatic SSL certificates
2. **Network Policies**: MySQL access is restricted to authorized pods only
3. **NodePort Range**: Minikube uses NodePort 30306 (outside normal port range)
4. **Load Balancer**: Cloud environments use secure LoadBalancer services

## Best Practices

✅ **Do:**
- Use Ingress for HTTP/HTTPS traffic (port 80, 443)
- Use NodePort/LoadBalancer for TCP traffic (MySQL)
- Implement Network Policies for security
- Use SSL/TLS certificates in production
- Set resource limits on pods

❌ **Don't:**
- Expose MySQL on Ingress (it's for HTTP/HTTPS only)
- Use NodePort in production (use cloud Load Balancer)
- Disable Network Policies in production
- Store passwords in plain text

## Next Steps

1. Update domain names in production ingress
2. Configure SSL/TLS certificates
3. Set up CI/CD pipeline for deployments
4. Configure monitoring and logging
5. Implement backup strategy for MySQL
