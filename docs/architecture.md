# Architecture

## Roles
- **ThinkPad**: primary server
- **Arch Predator**: control / client

## Storage
- `/` → SSD (OS only)
- `/srv/data` → HDD (authoritative data)
- `/backup` → bind mount for backup tooling

## Network
- LAN-first
- Static IPs where possible
- No dependency on DNS for core access
- SSH always available on LAN

## Philosophy
- Every service must survive:
  - no internet
  - reboot
  - power loss
