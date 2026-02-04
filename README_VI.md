# MATSim Distributed Runner

[🇺🇸 English](./README.md)

Repository này chứa các cấu hình runner cho môi trường mô phỏng phân tán MATSim (MATSim Distributed). Nó đóng vai trò như một trung tâm triển khai, tự động quản lý cấu hình các worker trên nhiều cấu hình phần cứng khác nhau.

## 🚀 Chiến lược Tự động hóa & Phân nhánh

Repository này sử dụng mô hình phân nhánh độc đáo dựa trên tự động hóa. **Không chỉnh sửa thủ công các branch runner.**

*   **`main`**: Nguồn dữ liệu chính (source of truth). Chứa `config.yaml`, `Dockerfile` gốc, và mẫu `docker-compose.yaml`.
*   **Các Branch Runner** (ví dụ: `i7`, `i7-high`, `i5`): Các branch được tạo tự động tương ứng với từng cấu hình phần cứng/worker cụ thể.

### Cách thức hoạt động
1.  **Cấu hình**: Định nghĩa giới hạn phần cứng và số lượng worker trong file `config.yaml`.
2.  **Đồng bộ**: Khi branch `main` được cập nhật, một GitHub Action (`sync-config.yml`) sẽ tự động:
    *   Tạo/Cập nhật các branch cho từng cấu hình đã định nghĩa.
    *   Điền các giới hạn CPU/Memory và số lượng worker cụ thể vào `docker-compose.yaml`.
    *   Đồng bộ `Dockerfile` mới nhất từ `main` sang các branch.

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

Các bản cập nhật được kích hoạt tự động từ repository [`MATSim_Custom`](https://github.com/ITS-Simulation/MATSim_Custom):
1.  Release mới trong `MATSim_Custom` → Push `Dockerfile` mới vào branch `main`.
2.  Quy trình `sync-config` kích hoạt → Cập nhật tất cả các branch runner.
3.  Các runner chỉ cần pull về và khởi động lại.
