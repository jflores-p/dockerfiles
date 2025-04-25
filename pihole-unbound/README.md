# Docker Compose Monitoring Containers

## Overview
This document lists the base network containers configured in the Docker Compose setup, focusing on exposed ports.

---

## 📦 Services in Docker Compose

| Service Name       | Ports Exposed            |
|--------------------|---------------------------|
| **pihole**         | 53 (TCP/UDP), 5051, 5052 |
| **unbound**        | 5053 (TCP/UDP)           |
| **wireguard**      | 5054 (UDP), 5055 (TCP)   |
