[![Generate Workers](https://github.com/ITS-Simulation/MATSim_Distributed_Runner/actions/workflows/sync-config.yml/badge.svg)](https://github.com/ITS-Simulation/MATSim_Distributed_Runner/actions/workflows/sync-config.yml)

# MATSim Distributed Runner

[🇬🇧 English](./README.md)

Repo này đóng vai trò trung tâm điều phối cho hệ thống mô phỏng MATSim phân tán. Nó tự động hóa việc quản lý và phân phối cấu hình cho các máy trạm (worker) trên nhiều nền tảng phần cứng khác nhau.

## 🚀 Cơ Chế Tự Động Hóa Branch

Dự án áp dụng mô hình quản lý branch tự động (Automated Branching Model). 
**Lưu ý quan trọng: Tuyệt đối KHÔNG chỉnh sửa thủ công các branch runner.**

*   **`main`**: "Nguồn gốc" - Chứa `config.yaml`, `Dockerfile` gốc, và template `docker-compose.yaml`.
*   **Branch Runner** (ví dụ: `i7`, `i7-high`, `i5`): Các branch con được sinh tự động, tương ứng với từng profile phần cứng đã định nghĩa.

### Quy Trình Hoạt Động
1.  **Tạo cấu hình gốc**: Khai báo tài nguyên phần cứng (CPU/RAM) và số lượng worker trong `config.yaml`.
2.  **Đồng bộ cấu hình**: Mỗi khi branch `main` có thay đổi, GitHub Action (`sync-config.yml`) sẽ kích hoạt:
    *   Khởi tạo hoặc cập nhật các branch con theo cấu hình.
    *   Inject (tiêm) giới hạn tài nguyên và số lượng replica vào file `docker-compose.yaml` của từng branch.
    *   Đồng bộ `Dockerfile` mới nhất từ `main`.

## ⚙️ Cấu hình (`config.yaml`)

Cấu hình các profile runner trong file `config.yaml` trên branch `main`:

```yaml
ip: "192.168.1.1"  # IP của máy chủ trung tâm

runner:
  i7:              # Tên Profile Core
    hw:
      cpu: 26.0    # Giới hạn CPU Docker
      memory: "10G" # Giới hạn RAM Docker
    workers:
      high: 10     # Tạo branch 'i7-high' với 10 worker
      normal: 8    # Tạo branch 'i7' với 8 worker
```

## 🛠️ Triển khai

Để triển khai một cấu hình runner cụ thể, chỉ cần pull branch tương ứng:

```bash
# Triển khai cấu hình i7 hiệu năng cao (high-performance)
git clone https://github.com/ITS-Simulation/MATSim_Distributed_Runner.git
git checkout i7-high
docker compose up -d --build
```

## 📦 Quy trình Cập nhật

Các bản cập nhật được kích hoạt tự động từ repository [`MATSim-Bus-Optimizer`](https://github.com/ITS-Simulation/MATSim-Bus-Optimizer):
1.  Release mới trong `MATSim-Bus-Optimizer` → Cập nhật `Dockerfile` trên branch `main` (phiên bản, checksum).
2.  Quy trình `sync-config` kích hoạt → Cập nhật tất cả các branch runner.
3.  Các runner chỉ cần pull về và khởi động lại.
