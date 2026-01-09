# HomeLabs

## Overview

This repository documents the design, setup, and operation of a **self-hosted home lab** built using refurbished consumer laptops.  
The objective is to design an **offline-capable, secure, family-oriented backup and media server infrastructure** with redundancy, remote access, and power-aware operation.

The project is built under **real-world constraints** such as limited hardware, intermittent internet access, and power availability, with a strong focus on **systems engineering and reliability** rather than idealized cloud-native setups.

---

## Goals

- Eliminate dependency on cloud storage services (e.g., Google Photos limits)
- Provide a **centralized family backup solution** for photos and files
- Enable **local media streaming** within the home network
- Allow **secure remote access** from long distances (300–500 km)
- Design a system that does **not require 24/7 uptime**
- Build redundancy using multiple low-cost machines
- Gain hands-on experience in Linux systems, networking, and storage
- Document the system as a reproducible, real-world project

---

## Devices

### Client Machines

- **Acer Predator Helios Neo 16**  
  *Role:* Main client / daily driver  
  *Usage:* Development, SSH administration, monitoring

- **DELL Inspiron 5521**  
  *Role:* Secondary client  
  *Usage:* Auxiliary access, fallback administration

---

### Server Machines

- **Lenovo ThinkPad E530c** *(Primary Server)*  
  **Specifications**
  - Intel i5 3rd Gen (M series)
  - 12 GB RAM
  - 128 GB SSD (OS)
  - 512 GB HDD (Data)
  - Ethernet with Wake-on-LAN support

  **Responsibilities**
  - Primary home server
  - Family backup hub
  - Media server
  - Secure remote access gateway
  - On-demand availability via Wake-on-LAN

- **DELL Inspiron N4030** *(Secondary / Backup Server)*  
  **Specifications**
  - 4 GB RAM
  - 160 GB HDD
  - Ethernet
  - Headless operation

  **Responsibilities**
  - Backup mirror
  - Redundancy and recovery node
  - Utility server

---

## Operating System Strategy

- Linux Mint (Ubuntu LTS base)
- Desktop Environment fully removed
- Headless, SSH-only operation
- Liquorix kernel used temporarily during testing
- Planned transition to generic LTS kernel for long-term stability

The choice prioritizes **stability, predictability, and low overhead** over performance tuning.

---

## Storage Architecture

### Primary Server (ThinkPad E530c)

- **128 GB SSD**  
  - Operating system only

- **512 GB HDD** mounted at:
```

/srv/data

```
```

/srv/data/
├── family/     # Family photo & file backups
├── media/      # Movies, shows, music
├── uploads/    # Remote uploads
├── jellyfin/   # Media server data
└── backups/    # Backup staging

```

---

### Secondary Server (N4030)

- **160 GB HDD** mounted at:
```

/srv/backup

```

- Used as an rsync-based mirror of critical data

---

## Networking Design

### Local Network (Offline Mode)

- Wi-Fi router functions without ISP connectivity
- Devices connect over LAN only
- Fully functional local services:
- File sharing (Samba)
- Media streaming (Jellyfin)
- Device-to-device file transfer

No internet access is required for core functionality.

---

### Remote Access (Online Mode)

- Secure access via **Tailscale**
- No port forwarding
- No public exposure
- NAT-agnostic connectivity

---

## Power & Availability Strategy

- Dead batteries accepted; systems operate on AC power
- Servers treated as fixed appliances
- Wake-on-LAN enables remote power-on
- No requirement for continuous uptime
- Manual power-on accepted for secondary server

---

## Issues Faced

### Hardware-Level Challenges
- Dead batteries across all legacy machines
- Broken display on secondary server
- Aging thermal paste causing thermal throttling
- Limited internal drive mounting options
- Absence of UPS or power conditioning hardware

### Software & System Challenges
- Converting a desktop-oriented OS into a server-grade environment
- Managing resource usage on older CPUs
- Kernel choice trade-offs (latency vs stability)
- Networking design without guaranteed internet
- Ensuring reliability without cloud services

---

## Constraints

- No dedicated server hardware
- Limited storage capacity
- Intermittent or absent internet connectivity
- No always-on power guarantee
- No enterprise networking equipment
- Physical distance between administrator and server

These constraints directly influenced architectural decisions.

---

## Skills Demonstrated

### Hardware Skills
- Laptop disassembly and reassembly
- RAM upgrades
- Thermal paste replacement
- Fault diagnosis and recovery

### Systems & Software Skills
- Linux system administration
- Headless server operation
- Service hardening and optimization
- Storage layout design
- Backup strategy implementation

### Networking & Infrastructure
- LAN-only service design
- Remote access using VPN-style tools
- Wake-on-LAN configuration
- Secure access without exposed ports

---

## Use Cases

- Family photo and file backups
- Local media streaming to TV and mobile devices
- Secure remote file uploads while away from home
- Learning and experimentation with system administration
- Backup and disaster recovery testing

---

## Real-World Relevance

This project mirrors challenges faced in:
- On-premise IT environments
- Edge computing setups
- Small office or home office (SOHO) infrastructure
- Environments with unreliable connectivity
- Cost-constrained infrastructure deployments

---

## Scalability & Future Additions

Planned or possible extensions:
- Migration to generic LTS kernel
- UPS integration for graceful shutdowns
- Automated snapshot-based backups
- Additional storage expansion
- Service isolation using containers
- Monitoring and alerting
- Access control per family member
- Integration with additional client devices

The architecture allows **incremental scaling without redesign**.

---

## 10-Day Execution Program

### Day 1 – Hardware Validation
### Day 2 – OS Hardening
### Day 3 – Storage Setup
### Day 4 – Networking Baseline
### Day 5 – Security Configuration
### Day 6 – File Sharing
### Day 7 – Media Server
### Day 8 – Remote Access
### Day 9 – Backup & Redundancy
### Day 10 – Documentation & Review

---

## Project Philosophy

This project prioritizes **understanding, ownership, and reliability** over convenience.  
All decisions are made with **real constraints**, not ideal assumptions.

---

## Status

Active development and refinement.

---

## Author
Arjun Rajesh
