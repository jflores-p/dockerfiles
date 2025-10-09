# Dockerized Monitoring and Networking Environment

Welcome to my first Docker-based project! This repository serves as an experiment and demonstration of various **monitoring** and **networking tools** using Docker and Docker Compose. The goal of this setup is to explore and test different tools for monitoring network traffic, managing services, and optimizing infrastructure, all within isolated Docker containers.

## 🚀 Project Overview

This project is designed to test and experiment with different **monitoring**, **networking**, and **miscellaneous** services running in Docker containers. As a first-time Docker user, I’m using this project as a learning opportunity to deploy, monitor, and manage various tools in isolated environments. This setup will help me improve my understanding of containerization and gain practical experience with Docker, while ensuring that the network, performance, and security of each service are handled effectively.

The key tools and services included in this project are:

- **Portainer**: A Docker management UI to monitor and control the Docker environment.
- **Grafana**: Used to visualize and analyze metrics from various containers.
- **Nginx Proxy Manager**: A simple UI for managing Nginx proxies and reverse proxies.
- **Pi-hole** and **Unbound**: A combined DNS solution for ad-blocking and DNS resolution.
- **WireGuard**: A VPN service for secure, encrypted connections.
- **Miscellaneous tools** like Snippets and Composerize for specific use cases.

## 🔧 Technologies Used

- **Docker** & **Docker Compose**: For creating isolated environments and managing multiple containers.
- **Grafana**: For visualizing monitoring data from the Docker containers.
- **Nginx**: A reverse proxy used for routing requests.
- **Pi-hole**: For ad-blocking and network-wide DNS services.
- **WireGuard**: For secure VPN tunneling.
- **Unbound**: For DNS resolution and caching.

# 📦 Port Assignments

---

## 🟣 Pihole + Unbound Stack

| Container name    | Host port | Container port | Purpose                   |
|-------------------|-----------|----------------|---------------------------|
| pihole            | 10000     | 443            | Web Console               |
| pihole            | 10001     | 80             | Web Console - deprecated  |
| unbound           | 10002     | 53             | DNS                       |
| wireguard         | 10003     | 51820          | Port forwarding           |
| wireguard         | 10004     | 51821          | Web Console               |

---

## 🟢 Monitoring Tools Stack

| Container name         | Host port | Container port | Purpose        |
|------------------------|-----------|----------------|----------------|
| portainer              | 10005     | 8000           |                |
| portainer              | 10006     | 9443           | Web Console    |
| grafana                | 10007     | 3000           | Web Console    |
| vnstat                 | 10014     | 10014          | Web Console    |
| cadvisor               | 8090      | 8090           |                |
| node-exporter          | 9100      | 9100           |                |
| prometheus             | 9090      | 9090           |                |
| homeassistant          | 8123      | 8123           |                |

---

## 🔵 Networking Tools Stack

| Container name   | Host port | Container port | Purpose        |
|------------------|-----------|----------------|----------------|
| NPM              | 10008     | 81             | Web Console    |
| NPM              | 80        | 80             |                |
| NPM              | 443       | 443            |                |
| my-speed	   | 10017     | 443            | Web Console    |

---

## 🟡 Miscellaneous Tools Stack

| Container name               | Host port | Container port | Purpose        |
|------------------------------|-----------|----------------|----------------|
| first-homepage               | 10011     | 80             |                |
| snippets                     | 10012     | 5000           | Web Console    |
| composerize                  | 10013     | 80             | Web Console    |
| paperless                    | 10015     | 8000           | Web Console    |
| homepage                     | 10016     | 3000           |                |

## 🛠️ How to Set Up

To get started with this Dockerized environment, follow these steps:

### 1. **Clone the Repository**

```bash
git clone https://github.com/your-username/monitoring-network-tools.git
cd monitoring-network-tools
```
## Adding k3s to the equation

### Raspberry Pi – Enabling cgroups for k3s

This document explains the initial configuration changes needed on a Raspberry Pi to run **k3s** properly.  

---

#### 1. `/boot/firmware/cmdline.txt`

Add the following parameters at the end of the single line:

	cgroup_memory=1 cgroup_enable=memory

**Reason**  
- Raspberry Pi OS does not enable memory cgroups by default.  
- Kubernetes (including **k3s**) requires memory cgroups to enforce pod resource limits and scheduling.  
- Without these parameters, k3s will not function correctly.  

---

#### 2. `/etc/docker/daemon.json`

Create or edit the file with:

```json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
```

**Reason**  
- Docker defaults to the cgroupfs driver.
- Modern Kubernetes distributions expect the systemd driver for consistent cgroup management.
- Aligning Docker with systemd avoids resource and stability issues when running Docker containers alongside k3s.
