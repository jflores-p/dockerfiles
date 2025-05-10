# Docker Compose Monitoring Containers

## Overview
This document lists the containers configured in the Docker Compose setup for monitoring and management, focusing on the exposed ports for each service.

---

## 📦 Services in Docker Compose

| Container name         | Host port | Container port | Purpose        |
|------------------------|-----------|----------------|----------------|
| monitoring-portainer   | 10005     | 8000           |                |
| monitoring-portainer   | 10006     | 9443           | Web Console    |
| monitoring-grafana     | 10007     | 3000           | Web Console    |
| monitoring-vnstat      | 10014     |                | Web Console    |
