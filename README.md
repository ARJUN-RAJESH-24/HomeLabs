# HomeLabs

**A constraint-driven, offline-capable home server infrastructure built from refurbished consumer laptops**

---

## Overview

This repository documents the complete design, implementation, and operation of a self-hosted home laboratory built using repurposed consumer hardware. The project demonstrates practical systems engineering in resource-constrained environments, focusing on reliability, security, and offline capability over performance optimization.

**Core Philosophy:** Build reliable infrastructure using what you have, not what you wish you had.

---

## Project Objectives

### Primary Goals
- **Eliminate cloud dependency** - Break free from Google Photos limits and subscription-based storage services
- **Centralized family backup** - Single source of truth for photos, documents, and personal data
- **Local media streaming** - Jellyfin-based media server for home entertainment
- **Secure remote access** - Connect from 300-500 km away without exposing services publicly
- **Intermittent operation** - Design for on-demand usage, not 24/7 uptime
- **Redundancy on a budget** - Multi-node architecture using low-cost hardware
- **Hands-on learning** - Practical experience in Linux administration, networking, and storage design

### Real-World Relevance

This project mirrors challenges found in:
- On-premise IT infrastructure
- Edge computing deployments
- Small office/home office (SOHO) environments
- Connectivity-challenged locations
- Cost-constrained enterprise scenarios
- Disaster recovery planning

---

## Hardware Inventory

### Client Machines

#### Acer Predator Helios Neo 16
**Role:** Primary workstation and administrative interface

**Usage:**
- Daily development work
- SSH-based server administration
- System monitoring and maintenance
- Remote backup management

#### DELL Inspiron 5521
**Role:** Secondary client and fallback access point

**Usage:**
- Auxiliary administrative access
- Testing and validation
- Backup administration terminal

---

### Server Infrastructure

#### Primary Server: Lenovo ThinkPad E530c

**Hardware Specifications:**
- **CPU:** Intel Core i5 (3rd Gen, M-series)
- **RAM:** 12 GB DDR3
- **Storage:** 
  - 128 GB SSD (System)
  - 512 GB HDD (Data)
- **Network:** Gigabit Ethernet with Wake-on-LAN
- **Condition:** Dead battery, AC-only operation

**Service Responsibilities:**
- Primary file server and backup hub
- Jellyfin media server
- Samba file sharing
- Remote access gateway (Tailscale)
- Wake-on-LAN target for on-demand availability

**Why This Machine:**
The E530c offers the best balance of processing power, RAM capacity, and storage options. The 12 GB RAM allows comfortable operation of multiple services, while dual storage enables clean OS/data separation. Enterprise-grade network hardware ensures reliable Wake-on-LAN functionality.

---

#### Secondary Server: DELL Inspiron N4030

**Hardware Specifications:**
- **CPU:** Intel processor (details TBD)
- **RAM:** 4 GB DDR3
- **Storage:** 160 GB HDD
- **Network:** Ethernet
- **Condition:** Broken display, dead battery, headless operation only

**Service Responsibilities:**
- Rsync-based backup mirror
- Disaster recovery node
- Redundancy target
- Utility and testing server

**Why This Machine:**
Despite limited resources, the N4030 provides crucial redundancy. The 160 GB storage is sufficient for mirroring critical data subsets. Operating headless reduces resource overhead, making 4 GB RAM adequate for backup services.

---

## Operating System Strategy

### Distribution Choice: Linux Mint (Ubuntu LTS Base)

**Rationale:**
- Stability-first approach using proven Ubuntu LTS foundation
- Broad hardware compatibility for aging laptops
- Extensive documentation and community support
- Familiar package ecosystem

**Configuration Approach:**
- Desktop environment fully removed post-installation
- Headless SSH-only operation
- Minimal service footprint
- System resources dedicated to server workloads

### Kernel Strategy

**Current State:** Liquorix kernel (testing phase)
- Low-latency optimizations evaluated
- Performance characteristics documented
- Thermal behavior observed under load

**Planned Migration:** Generic Ubuntu LTS kernel
- Long-term stability over performance tuning
- Predictable security update cadence
- Reduced maintenance complexity
- Better alignment with conservative server philosophy

**Decision Criteria:** Stability, security patch availability, and thermal characteristics take precedence over benchmark performance.

---

## Storage Architecture

### Primary Server Storage Layout

```
/dev/sda (128 GB SSD)
├── / (root filesystem)
├── /boot
└── /swap

/dev/sdb (512 GB HDD) → mounted at /srv/data
```

### Data Organization

```
/srv/data/
├── family/              # Family photos, documents, and archives
│   ├── photos/
│   ├── documents/
│   └── archives/
├── media/               # Entertainment library
│   ├── movies/
│   ├── shows/
│   └── music/
├── uploads/             # Remote upload staging area
├── jellyfin/            # Media server metadata and configuration
│   ├── config/
│   ├── cache/
│   └── metadata/
└── backups/             # Backup staging and logs
    ├── current/
    ├── snapshots/
    └── logs/
```

**Design Principles:**
- **OS/Data Separation:** SSD failure doesn't risk data; HDD failure doesn't break the system
- **Clear Boundaries:** Each top-level directory has a single, well-defined purpose
- **Backup-Friendly:** Structure optimized for rsync and incremental backup tools
- **Access Control:** Directory hierarchy maps to permission boundaries

---

### Secondary Server Storage Layout

```
/dev/sda (160 GB HDD)
├── / (root filesystem, minimal size)
└── /srv/backup (majority of space)
```

### Backup Mirror Organization

```
/srv/backup/
├── family-mirror/       # Critical family data replication
├── snapshots/           # Point-in-time recovery points
├── sync-logs/           # Rsync operation logs
└── verification/        # Backup integrity checksums
```

**Replication Strategy:**
- Daily rsync from primary server
- Checksum-based integrity verification
- Retention policy: 7 daily, 4 weekly snapshots
- Manual verification of critical data monthly

---

## Networking Design

### Architecture Overview

The network is designed for **dual-mode operation**: functioning fully offline for local services while enabling secure remote access when internet connectivity is available.

---

### Local Network (Offline Mode)

**Topology:**
```
[Wi-Fi Router] (no ISP connection)
      │
      ├── [Primary Server] (Ethernet)
      ├── [Secondary Server] (Ethernet)
      ├── [Client Laptop] (Wi-Fi)
      └── [Family Devices] (Wi-Fi)
```

**Available Services (No Internet Required):**
- Samba file sharing (SMB/CIFS)
- Jellyfin media streaming
- Local DNS resolution
- Device-to-device file transfer
- Network backup operations

**Key Feature:** Router operates in access point mode, creating a local network without requiring ISP connectivity. All core family services remain functional during internet outages.

---

### Remote Access (Online Mode)

**Technology:** Tailscale VPN mesh network

**Why Tailscale:**
- No port forwarding required
- No public service exposure
- Works behind CGNAT and restrictive ISPs
- Automatic NAT traversal
- Zero-trust architecture
- Peer-to-peer when possible, relay when necessary

**Access Topology:**
```
[Remote Client] ←→ [Tailscale Network] ←→ [Primary Server]
                                              ↓
                                        [Local Services]
```

**Security Measures:**
- SSH key-only authentication (password auth disabled)
- Fail2ban monitoring Tailscale-facing SSH
- Service binding to Tailscale interface only
- Firewall rules restricting external access
- Regular audit of connected devices

**Use Cases:**
- Remote file uploads while traveling
- Emergency access to family documents
- Server maintenance from remote locations
- Backup monitoring and management

---

### Wake-on-LAN Configuration

**Purpose:** Enable on-demand server availability without 24/7 operation

**Implementation:**
```bash
# On client machine:
wakeonlan <server-mac-address>

# Wait for boot (approx. 60-90 seconds)
ssh user@server.local
```

**Requirements Met:**
- BIOS WoL setting enabled
- Ethernet connection maintained
- Magic packet transmission from LAN device
- Router maintains ARP cache or uses static DHCP

**Operational Pattern:**
1. Client device sends WoL packet
2. Server powers on and boots
3. Network services become available
4. Client connects via SSH or Tailscale
5. After use, server can be shut down to conserve power

---

## Power & Availability Strategy

### Design Constraints

**Hardware Reality:**
- All legacy machines have dead batteries
- Operate exclusively on AC power
- Vulnerable to power interruptions
- No UPS (uninterruptible power supply) currently deployed

**Operational Model:**
- Servers are **on-demand appliances**, not always-on infrastructure
- Wake-on-LAN enables remote power-on
- Manual power-on accepted for secondary server (physical access required)
- Graceful shutdowns prioritized to protect data integrity

---

### Uptime Philosophy

**Not a Data Center:** This infrastructure is designed for **intermittent availability**, reflecting real-world home usage patterns.

**Acceptable Scenarios:**
- Servers powered down when not needed
- Multi-day offline periods during travel
- Scheduled maintenance windows
- Power cycling for updates

**Unacceptable Risks:**
- Ungraceful shutdowns during write operations
- Power loss during rsync replication
- Filesystem corruption from hard power-offs

---

### Future Improvements

**Planned Addition:** UPS integration
- Graceful shutdown automation on power loss
- Protection during brief outages
- Safe completion of in-flight backup operations
- Battery capacity: 15-30 minutes runtime (sufficient for shutdown)

---

## Backup Strategy

### Multi-Tier Approach

**Tier 1: Local Snapshots (Primary Server)**
- Automated daily backups using rsync
- 7-day retention of incremental snapshots
- Source: `/srv/data/`
- Destination: `/srv/data/backups/snapshots/`

**Tier 2: Secondary Server Replication**
- Daily mirror to DELL N4030
- Full filesystem replication via rsync
- Independent storage medium (disaster recovery)
- Manual verification checksum validation

**Tier 3: Cold Storage (Planned)**
- Monthly archival to external USB drives
- Off-site storage of critical family data
- Long-term retention (years)

---

### Backup Script Implementation

The project includes a production-ready backup script with the following features:

```bash
#!/usr/bin/env bash
set -euo pipefail

SRC="/srv/data/"
DEST="/srv/data/backups/current"
LOG="/srv/data/backups/logs/backup-$(date +%F).log"

EXCLUDES=(
    --exclude="/backups/"
    --exclude="timeshift/"
    --exclude="*/cache/*"
    --exclude="*/tmp/*"
    --exclude="lost+found"
    --exclude="jellyfin/cache/"
    --exclude="*.log"
)

echo "===== BACKUP START $(date) =====" | tee -a "$LOG"

mkdir -p "$DEST"
mkdir -p "$(dirname "$LOG")"

rsync -aAXH \
    --numeric-ids \
    --one-file-system \
    --delete \
    --info=progress2 \
    "${EXCLUDES[@]}" \
    "$SRC" "$DEST" | tee -a "$LOG"

echo "===== BACKUP END $(date) =====" | tee -a "$LOG"
```

**Script Features:**
- **Error Handling:** `set -euo pipefail` ensures failure detection
- **Archive Mode:** Preserves permissions, timestamps, symlinks
- **ACL Preservation:** `-A` flag maintains access control lists
- **Extended Attributes:** `-X` flag preserves filesystem metadata
- **Hard Link Handling:** `-H` preserves hard links
- **Progress Reporting:** Real-time transfer statistics
- **Exclusion Patterns:** Skips cache, temporary files, and logs
- **Atomic Operations:** `--delete` ensures mirror accuracy
- **Filesystem Boundaries:** `--one-file-system` prevents crossing mount points
- **Audit Trail:** Comprehensive logging with timestamps

**Automation:**
```bash
# Cron schedule (daily at 2:00 AM)
0 2 * * * /usr/local/bin/backup-data.sh
```

---

### Recovery Testing

**Validation Protocol:**
1. Random file restoration test (monthly)
2. Full disaster recovery drill (quarterly)
3. Secondary server boot verification (monthly)
4. Checksum validation of critical directories (weekly)

**Documented Recovery Time Objectives (RTO):**
- Individual file recovery: < 5 minutes
- Critical folder restoration: < 30 minutes
- Full system rebuild: < 4 hours (with current backups)

---

## Security Configuration

### SSH Hardening

```bash
# /etc/ssh/sshd_config (key settings)
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AllowUsers arjun
Port 22
```

**Rationale:**
- Key-only authentication eliminates brute-force password attacks
- Non-root login enforces sudo audit trail
- User whitelist prevents unauthorized account access

---

### Firewall Configuration

**Tool:** UFW (Uncomplicated Firewall)

```bash
# Default policies
ufw default deny incoming
ufw default allow outgoing

# Local network access
ufw allow from 192.168.1.0/24 to any port 22
ufw allow from 192.168.1.0/24 to any port 139,445  # Samba
ufw allow from 192.168.1.0/24 to any port 8096     # Jellyfin

# Tailscale interface (for remote access)
ufw allow in on tailscale0
```

**Security Model:**
- Deny all unsolicited incoming connections
- Whitelist local network services
- Trust Tailscale interface for remote access
- No public internet exposure

---

### Fail2ban Integration

**Purpose:** Automated intrusion prevention

**Configuration:**
```ini
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
```

**Behavior:** After 3 failed SSH attempts, source IP is banned for 1 hour.

---

## Service Configuration

### Samba File Sharing

**Purpose:** Cross-platform file access for Windows, macOS, Linux, and mobile clients

**Configuration Highlights:**
```ini
[family]
path = /srv/data/family
valid users = @family
read only = no
create mask = 0664
directory mask = 0775

[media]
path = /srv/data/media
valid users = @family
read only = yes
```

**Access Control:**
- Separate shares for family data (read-write) and media (read-only)
- Group-based permissions using Linux groups
- Proper umask ensures consistent file permissions

---

### Jellyfin Media Server

**Purpose:** Self-hosted Netflix alternative for local media

**Installation Method:** Official APT repository (not Docker)
- Direct hardware access for transcoding
- Lower resource overhead on older hardware
- Simpler troubleshooting

**Library Structure:**
```
/srv/data/media/
├── movies/
├── shows/
└── music/
```

**Configuration Location:** `/srv/data/jellyfin/config/`

**Performance Tuning:**
- Hardware acceleration disabled (older CPU lacks support)
- Pre-transcoded media preferred
- Direct play prioritized to reduce server load

**Access Methods:**
- Local network: `http://server.local:8096`
- Remote (via Tailscale): `http://100.x.x.x:8096`

---

## Challenges & Solutions

### Hardware Challenges

| Challenge | Impact | Solution |
|-----------|--------|----------|
| Dead batteries across all machines | AC-only operation, vulnerability to power loss | Accept constraint; plan UPS deployment; use Wake-on-LAN |
| Broken display on N4030 | No local diagnostics | Headless operation via SSH; network-based recovery |
| Aging thermal paste | Thermal throttling under load | Thermal paste replacement; conservative workload tuning |
| Limited drive bays | Storage expansion constraints | USB 3.0 external drives; network-attached storage planning |
| No UPS | Data corruption risk | Journaling filesystems; regular backups; graceful shutdown procedures |

---

### Software & System Challenges

| Challenge | Impact | Solution |
|-----------|--------|----------|
| Desktop OS → Server conversion | Unnecessary services consuming resources | Manual service audit; removal of desktop environment; minimal install |
| Resource usage on old CPUs | Service responsiveness | Single-purpose service design; avoid Docker overhead |
| Kernel choice (latency vs stability) | System reliability vs performance | Testing phase with Liquorix; planned migration to LTS kernel |
| Offline-capable design | Limited troubleshooting resources | Comprehensive local documentation; offline package caching |
| No cloud services | Dependency on local infrastructure | Redundancy through secondary server; regular backup testing |

---

### Networking Challenges

| Challenge | Impact | Solution |
|-----------|--------|----------|
| Intermittent internet | Remote access unavailable | Design for local-first operation; Tailscale for when online |
| CGNAT / restrictive ISP | Cannot use port forwarding | Tailscale mesh VPN; no public exposure required |
| Wake-on-LAN reliability | Server availability | Static DHCP; Ethernet-only server connections |
| No managed switches | Limited VLAN options | Firewall-based segmentation; service binding to specific interfaces |

---

## Skills Demonstrated

### Hardware & Electronics
- Laptop disassembly and component access
- RAM module installation and upgrade procedures
- Thermal paste application and thermal management
- BIOS configuration for server operation (WoL, boot order, power settings)
- Diagnostic troubleshooting of failing components

### Linux System Administration
- Headless server deployment and management
- SSH-based remote administration
- Service management with systemd
- Package management and repository configuration
- Filesystem management and partitioning
- User and permission management
- System monitoring and log analysis

### Networking
- LAN design and implementation
- VPN mesh networking (Tailscale)
- Firewall configuration (UFW)
- Wake-on-LAN setup and troubleshooting
- Network service binding and access control
- DNS and DHCP concepts

### Storage & Backup
- Filesystem selection and configuration (ext4)
- Storage layout design and mount points
- Rsync-based backup strategies
- Snapshot and retention policies
- Disaster recovery planning and testing

### Security
- SSH hardening and key-based authentication
- Firewall rule design
- Intrusion prevention (Fail2ban)
- Service isolation and least-privilege principles
- Zero-trust remote access architecture

### Documentation & Project Management
- Technical documentation writing
- System architecture diagramming
- Constraint-driven design
- Phased implementation planning
- Knowledge transfer and reproducibility

---

## Use Cases

### Family Backup Hub
**Scenario:** Parents' smartphones approaching storage limits

**Solution:** Automated photo/video sync to `/srv/data/family/photos/` via Samba, accessible from any device on the local network.

---

### Local Media Streaming
**Scenario:** Children want to watch family movie collection on TV

**Solution:** Jellyfin server streams from `/srv/data/media/` to smart TV or Chromecast, no internet required.

---

### Remote File Upload
**Scenario:** Administrator traveling 500 km away, needs to save important document

**Solution:** Connect via Tailscale, upload via SFTP or Samba to `/srv/data/uploads/`, accessible from home upon return.

---

### Disaster Recovery
**Scenario:** Primary server HDD fails catastrophically

**Solution:** Boot secondary server, restore data from `/srv/backup/family-mirror/`, restore service within hours instead of days.

---

### Learning Laboratory
**Scenario:** Administrator wants to experiment with new services without risking production data

**Solution:** Secondary server used as testing environment, allowing safe experimentation with Docker, alternative filesystems, or new backup tools.

---

## 10-Day Implementation Schedule

### Day 1: Hardware Validation & Preparation
- **Objectives:** Verify all hardware functionality, identify issues
- **Tasks:**
  - Test RAM on all machines (memtest86+)
  - Verify hard drives (SMART diagnostics)
  - Check Ethernet ports and cables
  - Test Wake-on-LAN from BIOS
  - Document MAC addresses
  - Clean physical components, apply thermal paste
- **Deliverables:** Hardware inventory spreadsheet, documented issues

---

### Day 2: OS Installation & Hardening
- **Objectives:** Install and configure base operating system
- **Tasks:**
  - Install Linux Mint on both servers
  - Remove desktop environment
  - Configure SSH server
  - Set up sudo privileges
  - Apply system updates
  - Configure UFW firewall basics
- **Deliverables:** Headless, SSH-accessible servers

---

### Day 3: Storage Setup & Partitioning
- **Objectives:** Configure storage layout
- **Tasks:**
  - Partition and format data drives
  - Create `/srv/data` and `/srv/backup` mount points
  - Add entries to `/etc/fstab`
  - Set up directory structure
  - Configure permissions and ownership
  - Test mount persistence across reboots
- **Deliverables:** Functional storage hierarchy

---

### Day 4: Networking Baseline
- **Objectives:** Establish local network services
- **Tasks:**
  - Configure static IP or DHCP reservation
  - Set up hostname resolution
  - Test local network connectivity
  - Configure Wake-on-LAN from client
  - Verify firewall rules for local network
- **Deliverables:** Reliable local network access

---

### Day 5: Security Configuration
- **Objectives:** Harden server security
- **Tasks:**
  - Generate and deploy SSH keys
  - Disable password authentication
  - Configure Fail2ban
  - Implement UFW rules
  - Set up automatic security updates
  - Create non-root user accounts
- **Deliverables:** Hardened, audit-ready servers

---

### Day 6: File Sharing (Samba)
- **Objectives:** Deploy family file sharing
- **Tasks:**
  - Install and configure Samba
  - Create shares for family and media
  - Set up user authentication
  - Test access from Windows, macOS, Linux clients
  - Configure mobile device access
- **Deliverables:** Functional cross-platform file sharing

---

### Day 7: Media Server (Jellyfin)
- **Objectives:** Deploy media streaming service
- **Tasks:**
  - Install Jellyfin from official repository
  - Configure media libraries
  - Set up user accounts
  - Test streaming to various devices
  - Optimize performance settings
- **Deliverables:** Working media server

---

### Day 8: Remote Access (Tailscale)
- **Objectives:** Enable secure remote connectivity
- **Tasks:**
  - Install Tailscale on servers and clients
  - Configure Tailscale network
  - Test remote SSH access
  - Verify remote file access
  - Document connection procedures
- **Deliverables:** Secure remote access capability

---

### Day 9: Backup & Redundancy
- **Objectives:** Implement backup strategy
- **Tasks:**
  - Deploy backup script on primary server
  - Configure cron job for automation
  - Set up rsync replication to secondary server
  - Test backup restoration
  - Document recovery procedures
- **Deliverables:** Automated backup system

---

### Day 10: Documentation & Testing
- **Objectives:** Finalize and validate complete system
- **Tasks:**
  - Complete system documentation
  - Perform end-to-end testing of all services
  - Conduct disaster recovery drill
  - Create operational runbook
  - Train family members on basic usage
  - Identify future improvements
- **Deliverables:** Production-ready system with comprehensive documentation

---

## Future Roadmap

### Short-Term (1-3 Months)
- [ ] Migrate to generic Ubuntu LTS kernel
- [ ] Implement UPS with automated shutdown scripts
- [ ] Deploy monitoring (Prometheus + Grafana or simpler alternatives)
- [ ] Add external USB storage for cold backups
- [ ] Create recovery boot media

### Medium-Term (3-6 Months)
- [ ] Evaluate ZFS or Btrfs for snapshot-based backups
- [ ] Implement Docker for service isolation
- [ ] Add second NIC for network segregation
- [ ] Deploy Pi-hole for network-wide ad blocking
- [ ] Automated offsite backup rotation

### Long-Term (6-12 Months)
- [ ] Acquire dedicated NAS hardware (if budget allows)
- [ ] Implement RAID for storage redundancy
- [ ] Add 10GbE networking for faster local transfers
- [ ] Deploy Kubernetes for learning purposes
- [ ] Create public-facing portfolio site (separate from home infrastructure)

---

## Lessons Learned

### What Worked Well
- **Constraint-driven design:** Limited resources forced thoughtful architectural decisions
- **Offline-first approach:** System remains useful regardless of internet availability
- **Dual-server redundancy:** Inexpensive backup server proved invaluable during testing
- **Tailscale:** Eliminated complexity of port forwarding and dynamic DNS
- **Documentation-first:** Writing this document clarified design decisions

### What Could Be Improved
- **Earlier thermal management:** Should have replaced thermal paste before initial deployment
- **UPS from day one:** Several close calls with power interruptions
- **More conservative kernel choice:** Liquorix testing caused unnecessary troubleshooting
- **Standardized backup testing:** Should have established testing schedule earlier

### Unexpected Challenges
- **Wake-on-LAN flakiness:** Required BIOS tweaking and static DHCP to stabilize
- **Samba performance on old hardware:** Needed tuning beyond default configuration
- **Jellyfin transcoding limitations:** Older CPU cannot handle real-time transcoding

---

## Technical Specifications Summary

### Primary Server (Lenovo ThinkPad E530c)
```
CPU:         Intel Core i5-3210M (2.5 GHz, 2 cores / 4 threads)
RAM:         12 GB DDR3
Storage:     128 GB SSD (OS) + 512 GB HDD (Data)
Network:     Gigabit Ethernet, Wi-Fi (unused)
OS:          Linux Mint 21.x (Ubuntu 22.04 base)
Services:    Samba, Jellyfin, Tailscale, SSH, rsync
Uptime:      On-demand (Wake-on-LAN)
```

### Secondary Server (DELL Inspiron N4030)
```
CPU:         Intel processor (details TBD)
RAM:         4 GB DDR3
Storage:     160 GB HDD
Network:     Ethernet
OS:          Linux Mint 21.x (Ubuntu 22.04 base)
Services:    rsync daemon, SSH
Uptime:      On-demand (manual power-on)
```

---
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


#!/usr/bin/env bash
set -euo pipefail

SRC="/srv/data/"
DEST="/srv/data/backup/current"
LOG="/srv/data/backup/backup-$(date +%F).log"

EXCLUDES=(
  --exclude="/backup/"
  --exclude="timeshift/"
  --exclude="*/cache/*"
  --exclude="*/tmp/*"
  --exclude="lost+found"
)

echo "===== BACKUP START $(date) =====" | tee -a "$LOG"

mkdir -p "$DEST"

rsync -aAXH \
  --numeric-ids \
  --one-file-system \
  --delete \
  --info=progress2 \
  "${EXCLUDES[@]}" \
  "$SRC" "$DEST" | tee -a "$LOG"

echo "===== BACKUP END $(date) =====" | tee -a "$LOG"

## Conclusion

This home lab demonstrates that sophisticated, reliable infrastructure can be built from modest resources through careful design, thoughtful constraints, and systems thinking. The project prioritizes **understanding over convenience**, **ownership over outsourcing**, and **reliability over bleeding-edge features**.

Every decision reflects real-world constraints: limited hardware, intermittent connectivity, power availability, and physical distance. The result is a system that serves its family users while providing invaluable hands-on learning in Linux administration, networking, storage design, and security.

This is not a theoretical exercise—it's a production system serving real users with real data. The documentation exists to ensure reproducibility, facilitate knowledge transfer, and serve as a reference for others building similar infrastructure under similar constraints.

---

## Author

**Arjun Rajesh**

Systems enthusiast, constraint-driven engineer, and advocate for self-hosted infrastructure.

---

## License

This documentation is provided as-is for educational purposes. Adapt freely to your own requirements.

---

**Project Status:** Active development and refinement

**Last Updated:** January 2026