# Docker Compose Monitoring Containers

## Overview
This document lists the base network containers configured in the Docker Compose setup, focusing on exposed ports.

---

## 📦 Services in Docker Compose

| Container name    | Host port | Container port | Purpose                  |
|-------------------|-----------|----------------|---------------------------|
| base-pihole       | 10000     | 443            | Web Console               |
| base-pihole       | 10001     | 80             | Web Console - deprecated  |
| base-unbound      | 10002     | 53             | DNS                       |
| base-wireguard    | 10003     | 51820          | Port forwarding           |
| base-wireguard    | 10004     | 51821          | Web Console               |
