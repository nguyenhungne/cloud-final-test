# Monitoring Grafana Dashboard Server

## 🚀 Bắt đầu nhanh

**Task 17.1 đã sẵn sàng!** Hệ thống đã được verify và hoạt động tốt.

### Bước tiếp theo của bạn:

1. **Đọc tổng quan**: Mở `TASK_17.1_SUMMARY.md` để hiểu những gì đã chuẩn bị
2. **Làm theo hướng dẫn**: Mở `DASHBOARD_SETUP_GUIDE.md` và làm theo từng bước
3. **Hoặc import nhanh**: Sử dụng `dashboard-template.json` để import dashboard

### Verify hệ thống (Optional)

Chạy script verification:
```powershell
.\verify-metrics.ps1
```

---

## Tổng quan

Thư mục này chứa tài liệu và template cho việc cấu hình Grafana dashboard trong hệ thống MyMiniCloud.

## 📁 Files trong thư mục

### Tài liệu chính
- **TASK_17.1_SUMMARY.md**: ⭐ **BẮT ĐẦU TỪ ĐÂY** - Tổng quan task và những gì cần làm
- **DASHBOARD_SETUP_GUIDE.md**: Hướng dẫn chi tiết từng bước để tạo custom dashboard
- **QUICK_REFERENCE.md**: Tham chiếu nhanh với checklist và queries

### Files hỗ trợ
- **dashboard-template.json**: Template JSON có thể import vào Grafana (optional)
- **verify-metrics.ps1**: Script PowerShell để verify hệ thống
- **README.md**: File này

## Task 17.1: Tạo Custom Dashboard

### Mục tiêu
Tạo dashboard trong Grafana với 3 panels hiển thị:
1. CPU metrics (node_cpu_seconds_total)
2. Memory metrics (node_memory_MemAvailable_bytes)
3. Network metrics (node_network_receive_bytes_total)

### Yêu cầu
- Requirements: 9.7
- Grafana đang chạy tại http://localhost:3000
- Prometheus datasource cần được cấu hình

### Cách thực hiện

#### Phương án 1: Làm theo hướng dẫn (Recommended)
Đọc file **DASHBOARD_SETUP_GUIDE.md** và làm theo từng bước.

#### Phương án 2: Import template (Nhanh hơn)
1. Thêm Prometheus datasource trước (xem DASHBOARD_SETUP_GUIDE.md bước 2)
2. Import file **dashboard-template.json** vào Grafana

### Verify hệ thống

Trước khi bắt đầu, kiểm tra các services đang chạy:

```bash
# Kiểm tra containers
docker compose ps

# Kiểm tra Grafana
curl http://localhost:3000

# Kiểm tra Prometheus
curl http://localhost:9090

# Kiểm tra Node Exporter metrics
curl http://localhost:9100/metrics
```

### Prometheus Targets Status

Prometheus đang scrape metrics từ:
- ✅ **node**: monitoring-node-exporter-server:9100 (UP)
- ⚠️ **web**: web-frontend-server:80 (không có /metrics endpoint - bình thường)

### Troubleshooting

#### Grafana không truy cập được
```bash
docker compose logs monitoring-grafana-dashboard-server
docker compose restart monitoring-grafana-dashboard-server
```

#### Prometheus không có dữ liệu
```bash
# Kiểm tra Prometheus targets
curl http://localhost:9090/api/v1/targets

# Restart Prometheus
docker compose restart monitoring-prometheus-server
```

#### Node Exporter không hoạt động
```bash
# Kiểm tra Node Exporter
curl http://localhost:9100/metrics

# Restart Node Exporter
docker compose restart monitoring-node-exporter-server
```

## Kết quả mong đợi

Sau khi hoàn thành task 17.1:
- ✅ Prometheus datasource được thêm vào Grafana
- ✅ Dashboard "MyMiniCloud System Monitoring" được tạo
- ✅ 3 panels hiển thị CPU, Memory, Network metrics
- ✅ Metrics được cập nhật real-time từ Node Exporter
- ✅ Requirements 9.7 được đáp ứng

## Lưu ý quan trọng

⚠️ **Đây là manual UI task** - Không thể tự động hóa hoàn toàn vì cần tương tác với Grafana UI.

Người dùng cần:
1. Mở trình duyệt
2. Đăng nhập Grafana
3. Cấu hình datasource
4. Tạo dashboard và panels thủ công

Hoặc sử dụng dashboard template để import nhanh hơn.

## Tài liệu tham khảo

- [Grafana Documentation](https://grafana.com/docs/)
- [Prometheus Query Language](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Node Exporter Metrics](https://github.com/prometheus/node_exporter)
