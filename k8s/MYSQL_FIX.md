# MySQL Setup Fix - Complete Guide

## Issue Summary
Your Spring Boot application was trying to connect with user `demo` but:
1. The MySQL `demo` user didn't exist
2. The `demo` database wasn't created
3. Access was denied for the user

## Solution Applied

### 1. Updated MySQL Deployment Configuration
Your `k8s-mysql-deployement.yml` now includes:

```yaml
env:
- name: MYSQL_ROOT_PASSWORD
  value: "root"
- name: MYSQL_DATABASE
  value: "demo"
- name: MYSQL_USER
  value: "demo"
- name: MYSQL_PASSWORD
  value: "demo"
```

This will automatically:
- Create the `demo` database
- Create the `demo` user with password `demo`
- Grant all privileges on `demo` database to `demo` user

### 2. Application Configuration
Your `application.yaml` is correctly configured:

```yaml
datasource:
  url: jdbc:mysql://localhost:3306/demo
  username: demo
  password: demo
```

## Steps to Fix Existing MySQL Container

### Option A: Delete and Recreate the Container (Recommended)

```bash
# Stop and remove the old MySQL container
docker stop mysql-demo
docker rm mysql-demo

# Start a new MySQL container with correct credentials
docker run -d \
  --name mysql-demo \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=demo \
  -e MYSQL_USER=demo \
  -e MYSQL_PASSWORD=demo \
  -p 3306:3306 \
  mysql:8.0

# Wait 10 seconds for MySQL to start
sleep 10

# Verify the connection
docker exec mysql-demo mysql -u demo -p demo -e "SELECT 1 as connected;"
```

### Option B: Manually Fix Existing Container

If you want to keep your existing container, connect to it and run:

```bash
# Connect to running container as root
docker exec -it mysql-demo mysql -u root -p root

# Then in MySQL shell, run these commands:
CREATE DATABASE IF NOT EXISTS demo;
CREATE USER IF NOT EXISTS 'demo'@'%' IDENTIFIED BY 'demo';
GRANT ALL PRIVILEGES ON demo.* TO 'demo'@'%';
FLUSH PRIVILEGES;
EXIT;
```

## Verification Commands

### 1. Test Connection from Host
```bash
# Connect as demo user
mysql -h localhost -u demo -p demo -D demo -e "SELECT 1 as test;"

# Should output:
# +-------+
# | test  |
# +-------+
# |     1 |
# +-------+
```

### 2. Test from Docker Container
```bash
docker exec mysql-demo mysql -u demo -p demo -D demo -e "SELECT 1 as test;"
```

### 3. Check User Permissions
```bash
docker exec mysql-demo mysql -u root -p root -e "SELECT user, host FROM mysql.user WHERE user='demo';"
```

### 4. Check Database
```bash
docker exec mysql-demo mysql -u root -p root -e "SHOW DATABASES;"
```

## For Kubernetes Deployment

### Apply the Updated Configuration
```bash
# Make sure old MySQL pod is deleted
kubectl delete deployment mysql

# Apply the updated deployment
kubectl apply -f k8s/k8s-mysql-deployement.yml

# Verify MySQL pod is running
kubectl get pods -l app=mysql

# Test connection to Kubernetes MySQL
kubectl exec -it <mysql-pod-name> -- mysql -u demo -p demo -D demo -e "SELECT 1;"
```

### Port Forward to Test Locally
```bash
# Forward Kubernetes MySQL to local port
kubectl port-forward svc/mysql-service 3306:3306 &

# Connect using the same credentials
mysql -h localhost -u demo -p demo -D demo -e "SELECT 1;"
```

## Credentials Summary

| Component | User | Password | Database | Host |
|-----------|------|----------|----------|------|
| MySQL Root | root | root | - | localhost:3306 |
| App User | demo | demo | demo | localhost:3306 |
| Kubernetes | demo | demo | demo | mysql-service:3306 |

## Expected Connection Flow

```
Spring Boot Application
    ↓
application.yaml (jdbc:mysql://localhost:3306/demo)
    ↓
MySQL JDBC Driver
    ↓
MySQL Server (port 3306)
    ↓
User: demo, Password: demo
    ↓
Database: demo
```

## Next Steps

1. **Stop old MySQL container** (if running):
   ```bash
   docker stop mysql-demo
   ```

2. **Create new MySQL container** with correct credentials:
   ```bash
   docker run -d \
     --name mysql-demo \
     -e MYSQL_ROOT_PASSWORD=root \
     -e MYSQL_DATABASE=demo \
     -e MYSQL_USER=demo \
     -e MYSQL_PASSWORD=demo \
     -p 3306:3306 \
     mysql:8.0
   ```

3. **Wait 10 seconds** for MySQL to initialize

4. **Run your Spring Boot application**:
   ```bash
   mvn spring-boot:run
   ```

Your application should now connect successfully to MySQL!

## Troubleshooting

### Still getting "Access denied"?
- Verify MySQL container is running: `docker ps | grep mysql`
- Check MySQL logs: `docker logs mysql-demo`
- Verify credentials: `docker exec mysql-demo mysql -u demo -p demo -e "SELECT 1;"`

### Connection refused?
- Verify port 3306 is open: `netstat -an | grep 3306`
- Check if MySQL is listening: `docker logs mysql-demo | tail -20`
- Wait longer - MySQL takes time to initialize on first start

### Database doesn't exist?
- List databases: `docker exec mysql-demo mysql -u root -p root -e "SHOW DATABASES;"`
- Create manually: `docker exec mysql-demo mysql -u root -p root -e "CREATE DATABASE demo;"`
