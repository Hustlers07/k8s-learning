# MySQL Port 3307 Setup

## Start MySQL on Port 3307

```bash
# Stop existing MySQL container (if any)
docker stop mysql-demo
docker rm mysql-demo

# Start MySQL on port 3307
docker run -d \
  --name mysql-demo \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=demo \
  -e MYSQL_USER=demo \
  -e MYSQL_PASSWORD=demo \
  -p 3307:3306 \
  mysql:8.0

# Wait for MySQL to start
sleep 15

# Verify connection on port 3307
docker exec mysql-demo mysql -u demo -p demo -D demo -e "SELECT 1 as connected;"
```

## Connection Details for Port 3307

- **Host**: localhost
- **Port**: 3307
- **Database**: demo
- **Username**: demo
- **Password**: demo

## Test Connection

```bash
# From host machine
mysql -h localhost -P 3307 -u demo -p demo -D demo -e "SELECT 1;"
```

## JDBC Connection String
```
jdbc:mysql://localhost:3307/demo?allowPublicKeyRetrieval=true&useSSL=false&serverTimezone=UTC
```

## Your application.yaml is already configured correctly:
```yaml
datasource:
  url: jdbc:mysql://localhost:3307/demo
  username: demo
  password: demo
```

Just start the MySQL container with the command above, and your Spring Boot app should connect successfully!
