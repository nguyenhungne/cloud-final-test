# Hướng dẫn tạo Custom Grafana Dashboard

## Mục tiêu
Tạo dashboard tùy chỉnh trong Grafana với 3 panels hiển thị CPU, Memory, và Network metrics từ Prometheus.

## Yêu cầu
- Grafana đang chạy tại: http://localhost:3000
- Prometheus đang chạy tại: http://localhost:9090
- Node Exporter đang thu thập metrics

## Bước 1: Đăng nhập vào Grafana

1. Mở trình duyệt và truy cập: **http://localhost:3000**
2. Đăng nhập với credentials mặc định:
   - Username: `admin`
   - Password: `admin`
3. Nếu được yêu cầu đổi mật khẩu, bạn có thể skip hoặc đặt mật khẩu mới

## Bước 2: Thêm Prometheus Datasource

1. Từ menu bên trái, click vào **⚙️ Configuration** (biểu tượng bánh răng)
2. Chọn **Data sources**
3. Click nút **Add data source**
4. Chọn **Prometheus** từ danh sách
5. Cấu hình datasource:
   - **Name**: `Prometheus`
   - **URL**: `http://monitoring-prometheus-server:9090`
   - Các tùy chọn khác để mặc định
6. Click **Save & test** ở cuối trang
7. Bạn sẽ thấy thông báo "Data source is working" màu xanh

## Bước 3: Tạo Dashboard mới

1. Từ menu bên trái, click vào **+** (Create)
2. Chọn **Dashboard**
3. Click **Add visualization**
4. Chọn datasource **Prometheus** vừa tạo

## Bước 4: Tạo Panel 1 - CPU Metrics

1. Trong panel editor:
   - **Title**: Đặt tên panel là `CPU Usage`
   - **Query**: Nhập query sau vào ô Metrics browser:
     ```promql
     rate(node_cpu_seconds_total{mode="idle"}[5m])
     ```
   - Hoặc sử dụng query tổng quát hơn:
     ```promql
     100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
     ```
2. Trong tab **Panel options** (bên phải):
   - **Title**: `CPU Usage`
   - **Description**: `CPU usage percentage from Node Exporter`
3. Click **Apply** ở góc trên bên phải để lưu panel

## Bước 5: Tạo Panel 2 - Memory Metrics

1. Click **Add** → **Visualization** để thêm panel mới
2. Chọn datasource **Prometheus**
3. Trong panel editor:
   - **Query**: Nhập query:
     ```promql
     node_memory_MemAvailable_bytes
     ```
   - Hoặc hiển thị theo GB:
     ```promql
     node_memory_MemAvailable_bytes / 1024 / 1024 / 1024
     ```
4. Trong tab **Panel options**:
   - **Title**: `Available Memory`
   - **Description**: `Available memory in bytes from Node Exporter`
5. Trong tab **Standard options**:
   - **Unit**: Chọn `bytes(IEC)` hoặc `gigabytes` nếu dùng query chia cho 1024^3
6. Click **Apply**

## Bước 6: Tạo Panel 3 - Network Metrics

1. Click **Add** → **Visualization** để thêm panel thứ 3
2. Chọn datasource **Prometheus**
3. Trong panel editor:
   - **Query**: Nhập query:
     ```promql
     rate(node_network_receive_bytes_total[5m])
     ```
   - Để hiển thị cả receive và transmit, thêm query thứ 2:
     ```promql
     rate(node_network_transmit_bytes_total[5m])
     ```
4. Trong tab **Panel options**:
   - **Title**: `Network Traffic`
   - **Description**: `Network receive bytes per second from Node Exporter`
5. Trong tab **Standard options**:
   - **Unit**: Chọn `bytes/sec(IEC)`
6. Click **Apply**

## Bước 7: Lưu Dashboard

1. Click vào biểu tượng **💾 Save dashboard** ở góc trên bên phải
2. Đặt tên dashboard: `MyMiniCloud System Monitoring`
3. Thêm description (optional): `Custom dashboard monitoring CPU, Memory, and Network metrics`
4. Click **Save**

## Bước 8: Verify Dashboard

Dashboard của bạn bây giờ sẽ có 3 panels:
- ✅ **CPU Usage**: Hiển thị mức sử dụng CPU
- ✅ **Available Memory**: Hiển thị bộ nhớ khả dụng
- ✅ **Network Traffic**: Hiển thị lưu lượng mạng

## Troubleshooting

### Không thấy dữ liệu trong panels?

1. Kiểm tra Prometheus đang scrape metrics:
   - Truy cập http://localhost:9090
   - Vào **Status** → **Targets**
   - Verify target `node` có status **UP**

2. Kiểm tra query trong Prometheus trước:
   - Vào http://localhost:9090
   - Thử chạy query `node_cpu_seconds_total` trong tab Graph
   - Nếu có dữ liệu ở đây nhưng không có trong Grafana, kiểm tra lại datasource URL

3. Kiểm tra time range:
   - Trong Grafana dashboard, đảm bảo time range ở góc trên bên phải được set là "Last 5 minutes" hoặc "Last 15 minutes"

### Datasource connection failed?

- Đảm bảo URL là `http://monitoring-prometheus-server:9090` (không phải localhost)
- Containers phải cùng network `cloud-net`
- Restart Grafana container nếu cần: `docker compose restart monitoring-grafana-dashboard-server`

## Queries Reference

Dưới đây là các queries được sử dụng theo yêu cầu:

1. **CPU**: `node_cpu_seconds_total` hoặc `rate(node_cpu_seconds_total{mode="idle"}[5m])`
2. **Memory**: `node_memory_MemAvailable_bytes`
3. **Network**: `node_network_receive_bytes_total` hoặc `rate(node_network_receive_bytes_total[5m])`

## Kết quả mong đợi

Sau khi hoàn thành, bạn sẽ có:
- ✅ Prometheus datasource được cấu hình trong Grafana
- ✅ Dashboard "MyMiniCloud System Monitoring" với 3 panels
- ✅ Panels hiển thị real-time metrics từ Node Exporter
- ✅ Đáp ứng Requirements 9.7

---

**Lưu ý**: Đây là manual UI task, không thể tự động hóa hoàn toàn. Hãy làm theo từng bước trong hướng dẫn này.
