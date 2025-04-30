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

## TODO

Organize the ports with a scheme similar to this:

| Container Name               | Host IP     | Host Port (Network-specific) | Container Port(s)               | Network         |
|------------------------------|-------------|------------------------------|---------------------------------|-----------------|
| **monitoring-portainer**      | `10.8.1.7`  | `10000:9443`                  | `9443`                          | Monitoring      |
| **monitoring-grafana**        | `10.8.1.10` | `10010:3000`                  | `3000`                          | Monitoring      |
| **networking-NPM**            | `10.8.1.11` | `11000:443, 11001:8090`       | `443`, `8090`                   | Networking      |
| **base-wireguard**            | `10.8.1.4`  | `20000:51820, 20001:51821`    | `51820`, `51821`                | Pi-hole + Unbound |
| **base-unbound**              | `10.8.1.3`  | `21000:53`                    | `53`                            | Pi-hole + Unbound |
| **base-pihole**               | `10.8.1.2`  | `22000:80, 22001:443, 22002:53` | `80`, `443`, `53`               | Pi-hole + Unbound |
| **miscellaneous-snippets**    | `10.8.1.13` | `30000:5000`                  | `5000`                          | Miscellaneous   |
| **miscellaneous-composerize** | `10.8.1.14` | `31000:80`                    | `80`                            | Miscellaneous   |
| **miscellaneous-homepage**    | `10.8.1.12` | `32000:80`                    | `80`                            | Miscellaneous   |
| **testing01_nginx-default**   | `10.8.2.2`  | `40000:80`                    | `80`                            | Testing         |

## 🛠️ How to Set Up

To get started with this Dockerized environment, follow these steps:

### 1. **Clone the Repository**

```bash
git clone https://github.com/your-username/monitoring-network-tools.git
cd monitoring-network-tools

