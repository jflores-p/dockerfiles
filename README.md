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

| Container name    | Host port | Container port | Purpose                  |
|-------------------|-----------|----------------|---------------------------|
| base-pihole       | 10000     | 443            | Web Console               |
| base-pihole       | 10001     | 80             | Web Console - deprecated  |
| base-unbound      | 10002     | 53             | DNS                       |
| base-wireguard    | 10003     | 51820          | Port forwarding           |
| base-wireguard    | 10004     | 51821          | Web Console               |

---

## 🟢 Monitoring Tools Stack

| Container name         | Host port | Container port | Purpose        |
|------------------------|-----------|----------------|----------------|
| monitoring-portainer   | 10005     | 8000           |                |
| monitoring-portainer   | 10006     | 9443           | Web Console    |
| monitoring-grafana     | 10007     | 3000           | Web Console    |
| monitoring-vnstat      | 10014     |                | Web Console    |

---

## 🔵 Networking Tools Stack

| Container name   | Host port | Container port | Purpose        |
|------------------|-----------|----------------|----------------|
| networking-NPM   | 10008     | 81             | Web Console    |
| networking-NPM   | 10009     | 80             |                |
| networking-NPM   | 10010     | 443            |                |

---

## 🟡 Miscellaneous Tools Stack

| Container name               | Host port | Container port | Purpose        |
|------------------------------|-----------|----------------|----------------|
| miscellaneous-homepage       | 10011     | 80             |                |
| miscellaneous-snippets       | 10012     | 5000           | Web Console    |
| miscellaneous-composerize    | 10013     | 80             | Web Console    |
| miscellaneous-paperless      | 10014     | 8000           | Web Console    |

## 🛠️ How to Set Up

To get started with this Dockerized environment, follow these steps:

### 1. **Clone the Repository**

```bash
git clone https://github.com/your-username/monitoring-network-tools.git
cd monitoring-network-tools

