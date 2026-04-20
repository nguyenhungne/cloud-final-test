# MyMiniCloud System

Hệ thống mô phỏng cloud platform cơ bản với 9 server containers chạy trên Docker.

## Kiến trúc hệ thống

MyMiniCloud bao gồm các thành phần sau:

1. **Web Frontend Server** (Nginx) - Phục vụ nội dung web tĩnh
2. **Application Backend Server** (Flask) - REST API backend
3. **Relational Database Server** (MariaDB) - Lưu trữ dữ liệu quan hệ
4. **Authentication Identity Server** (Keycloak) - Quản lý identity và OIDC
5. **Object Storage Server** (MinIO) - S3-compatible object storage
6. **Internal DNS Server** (Bind9) - Phân giải tên miền nội bộ
7. **Monitoring Prometheus Server** - Thu thập metrics
8. **Monitoring Grafana Dashboard Server** - Visualization dashboard
9. **API Gateway Proxy Server** (Nginx) - Reverse proxy và load balancer

## Yêu cầu hệ thống

- Docker Engine 20.10+
- Docker Compose 2.0+
- 4GB RAM tối thiểu
- 10GB dung lượng đĩa trống

## Cài đặt và chạy

### 1. Clone repository

```bash
git clone <repository-url>
cd hotenSVminicloud
```

### 2. Build custom images

```bash
docker compose build
```

### 3. Khởi động hệ thống

```bash
docker compose up -d
```

### 4. Kiểm tra trạng thái

```bash
docker compose ps
```

### 5. Dừng hệ thống

```bash
docker compose down
```

## Truy cập các services

Sau khi khởi động, các services có thể truy cập qua:

- **Web Frontend**: http://localhost:8080
- **Application API**: http://localhost:8085
- **Database**: localhost:3306 (user: root, password: root)
- **Keycloak**: http://localhost:8081 (admin/admin)
- **MinIO Console**: http://localhost:9001 (minioadmin/minioadmin)
- **MinIO API**: http://localhost:9000
- **DNS Server**: localhost:1053/udp
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)
- **API Gateway**: http://localhost

## Cấu trúc thư mục

```
hotenSVminicloud/
├── web-frontend-server/          # Nginx web server
├── application-backend-server/   # Flask API server
├── relational-database-server/   # MariaDB database
├── authentication-identity-server/  # Keycloak (image only)
├── object-storage-server/        # MinIO storage
├── internal-dns-server/          # Bind9 DNS
├── monitoring-prometheus-server/ # Prometheus monitoring
├── monitoring-grafana-dashboard-server/  # Grafana (image only)
├── monitoring-node-exporter-server/      # Node Exporter (image only)
├── api-gateway-proxy-server/     # Nginx reverse proxy
├── docker-compose.yml            # Orchestration file
└── README.md                     # This file
```

## Network

Tất cả containers kết nối qua Docker network `cloud-net` (bridge driver), cho phép giao tiếp nội bộ giữa các services.

## Troubleshooting

### Containers không khởi động

```bash
docker compose logs <service-name>
```

### Reset toàn bộ hệ thống

```bash
docker compose down -v
docker compose up -d
```

### Kiểm tra network connectivity

```bash
docker exec <container-name> ping <other-container-name>
```

## Deployment lên AWS EC2

Hệ thống có thể deploy lên AWS EC2 instance. Xem hướng dẫn chi tiết:

- **[Quick Start AWS](./QUICKSTART_AWS.md)** - Deploy trong 10 phút
- **[Deployment Guide](./DEPLOYMENT.md)** - Hướng dẫn chi tiết deployment và maintenance
- **[Security Groups](./AWS_SECURITY_GROUPS.md)** - Cấu hình AWS Security Groups
- **[Docker Installation Script](./install-docker.sh)** - Script tự động cài Docker

### Quick Deploy

```bash
# 1. Launch EC2 Ubuntu instance (t3.medium, 20GB)
# 2. Configure security group (ports: 22, 80, 3000, 8080, 8081, 9090)
# 3. SSH vào instance
ssh -i your-key.pem ubuntu@<EC2_PUBLIC_IP>

# 4. Install Docker
curl -fsSL https://raw.githubusercontent.com/yourusername/hotenSVminicloud/main/install-docker.sh | bash
newgrp docker

# 5. Clone và deploy
git clone <repo-url>
cd hotenSVminicloud
docker compose build
docker compose up -d
```

## License

Educational project for cloud computing course.
