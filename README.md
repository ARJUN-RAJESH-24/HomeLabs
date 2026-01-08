# HomeLabs

## Overview

This repository documents the design, setup, and operation of a **self-hosted home lab** built using refurbished consumer laptops.  
The goal of this project is to design an **offline-capable, secure, family-oriented backup and media server infrastructure** with remote access, redundancy, and power-aware operation.

This home lab is designed under **real-world constraints**:
- Limited hardware
- No always-on internet
- No cloud storage dependency
- Remote access from long distances
- Power and availability limitations

The project emphasizes **systems thinking, Linux administration, networking, storage, and reliability engineering**.

---

## Devices

### Client Machines

- **Acer Predator Helios Neo 16**  
  *Role:* Main client / daily driver  
  *Usage:* Development, administration, SSH access, monitoring

- **DELL Inspiron 5521**  
  *Role:* Secondary client  
  *Usage:* Auxiliary access, testing, fallback client

---

### Server Machines

- **Lenovo ThinkPad E530c** *(Primary Server)*  
  *Specifications:*
  - Intel i5 3rd Gen (M series)
  - 12 GB RAM
  - 128 GB SSD (OS)
  - 512 GB HDD (Data)
  - Ethernet (Wake-on-LAN supported)

  *Role:*
  - Primary home server
  - Family backup hub
  - Media server
  - Remote access gateway
  - On-demand availability using Wake-on-LAN

- **DELL Inspiron N4030** *(Secondary / Backup Server)*  
  *Specifications:*
  - 4 GB RAM
  - 160 GB HDD
  - Ethernet
  - Headless operation

  *Role:*
  - Backup mirror
  - Redundancy node
  - Utility and recovery server

---

## Operating System Strategy

- **Linux Mint (Ubuntu LTS base)** on the primary server
- Desktop Environment completely removed
- Headless, SSH-only operation
- Liquorix kernel used temporarily during testing
- Planned migration to generic LTS kernel for long-term stability

No graphical environment is used on server machines.

---

## Storage Architecture

### Primary Server (ThinkPad E530c)

- **SSD (128 GB)**  
  - Operating system only

- **HDD (512 GB)** mounted at:
```

/srv/data

```

Directory structure:
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

- **HDD (160 GB)** mounted at:
```

/srv/backup

```

- Used as an `rsync` mirror for redundancy

---

## Networking Design

### Local Network (No Internet)

- Wi-Fi router operates without ISP connectivity
- All devices connect to the same LAN
- Services available locally:
- File sharing (Samba)
- Media streaming (Jellyfin)
- Device-to-device transfers

Internet access is **not required** for core functionality.

---

### Remote Access (Internet Available)

- Secure remote access via **Tailscale**
- No port forwarding
- No public exposure
- Access from long distances (300–500 km)

---

## Power & Availability Strategy

- All servers operate on AC power (dead batteries)
- Servers are treated as appliances
- **Wake-on-LAN** enables on-demand availability
- No requirement for 24/7 uptime
- Manual power control accepted for secondary server

---

## Security Model

- SSH-based administration
- Firewall-enabled (UFW)
- No exposed public services
- VPN-style access using Tailscale
- Principle of least privilege applied

---

## 10-Day Execution Program

### Day 1 – Hardware Validation
- Verify thermals, RAM, storage
- Confirm Wake-on-LAN functionality
- BIOS configuration

### Day 2 – OS Hardening
- Remove desktop environment
- Disable sleep, lid actions
- Enable SSH-only access

### Day 3 – Storage Setup
- Partition and mount data disks
- Define directory structure
- Persistent mounts via `/etc/fstab`

### Day 4 – Network Baseline
- Local LAN testing
- Static IP planning
- SSH reliability checks

### Day 5 – Security Configuration
- Firewall rules
- SSH hardening
- User privilege review

### Day 6 – File Sharing
- Samba setup for family backups
- Permission and access control

### Day 7 – Media Server
- Jellyfin deployment
- CPU-only direct play configuration
- TV and device access testing

### Day 8 – Remote Access
- Tailscale deployment
- Secure remote login testing

### Day 9 – Backup & Redundancy
- rsync-based backup to secondary server
- Restore testing

### Day 10 – Documentation & Review
- Architecture review
- Failure scenario analysis
- Documentation and cleanup

---

## Domains & Skills Demonstrated

- Linux System Administration
- Networking (LAN, remote access, WoL)
- Storage & Backup Engineering
- Self-hosted Infrastructure
- Reliability under constraints
- Power-aware system design
- Home lab and on-prem architecture

---

## Project Philosophy

This project focuses on **engineering decisions under constraints**, not idealized cloud setups.  
It prioritizes **ownership, reliability, and understanding** over convenience.

---

## Status

- Architecture finalized
- Hardware prepared
- OS hardened
- Execution in progress

---

## Author

Self-built and maintained as a learning-focused systems project.
```

---

