# Docker Compose Monitoring Containers

## Overview
This document lists the containers configured in the Docker Compose setup for networking, focusing on the exposed ports for each service.

---

## 📦 Services in Docker Compose

| Container name   | Host port | Container port | Purpose                   |
|------------------|-----------|----------------|---------------------------|
| pihole           | 10000     | 443            | Web Console               |
| pihole           | 10001     | 80             | Web Console - deprecated  |
| unbound          | 10002     | 53             | DNS                       |
| wireguard        | 10003     | 51820          | Port forwarding           |
| wireguard        | 10004     | 51821          | Web Console               |
| NPM              | 10008     | 81             | Web Console               |
| NPM              | 80        | 80             |                           |
| NPM              | 443       | 443            |                           |
