# MATSim Distributed Runner

[🇻🇳 Tiếng Việt](./README_VI.md)

This repository hosts the runner configurations for the MATSim Distributed simulation environment. It acts as a deployment hub that automatically manages multiple worker configurations across different hardware profiles.

## 🚀 Automation & Branching Strategy

This repository uses a unique branching model driven by automation. **Do not manually edit runner branches.**

*   **`main`**: The source of truth. Contains the `config.yaml`, base `Dockerfile`, and `docker-compose.yaml` template.
*   **Runner Branches** (e.g., `i7`, `i7-high`, `i5`): Automatically generated branches representing specific hardware/worker configurations.

### How it works
1.  **Configuration**: Define hardware limits and worker counts in `config.yaml`.
2.  **Sync**: When `main` is updated, a GitHub Action (`sync-config.yml`) automatically:
    *   Creates/Updates branches for each defined configuration.
    *   Injects specific CPU/Memory limits and worker counts into `docker-compose.yaml`.
    *   Propagates the latest `Dockerfile` from `main`.

## ⚙️ Configuration (`config.yaml`)

Configure your runner profiles in `config.yaml` on the `main` branch:

```yaml
ip: "192.168.1.1"  # IP of the central server

runner:
  i7:              # Core Profile Name
    hw:
      cpu: 26.0    # Docker CPU limit
      memory: "10G" # Docker RAM limit
    workers:
      high: 10     # Creates branch 'i7-high' with 10 workers
      normal: 8    # Creates branch 'i7' with 8 workers
```

## 🛠️ Deployment

To deploy a specific runner configuration, simply pull the corresponding branch:

```bash
# Deploy the i7 high-performance configuration
git clone https://github.com/ITS-Simulation/MATSim_Distributed_Runner.git
git checkout i7-high
docker compose up -d --build
```

## 📦 Update Process

Updates are triggered automatically from the [`MATSim-Bus-Optimizer`](https://github.com/ITS-Simulation/MATSim-Bus-Optimizer) repository:
1.  New release in `MATSim-Bus-Optimizer` → Updates `Dockerfile` on `main` (version, checksum).
2.  `sync-config` workflow triggers → Updates all runner branches.
3.  Runners simply need to pull and restart.
