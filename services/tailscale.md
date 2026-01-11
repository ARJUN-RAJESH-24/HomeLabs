# 🌐 `services/tailscale.md`

```md
# Tailscale Service

## Purpose
Tailscale provides **remote access** to the homelab
when LAN access is not available.

It is **not required** for daily operation.

## Status
Currently:
- Installed
- Disabled / deferred
- Not part of core stack

## Intended Use
- SSH access from outside LAN
- Optional subnet routing
- No exit-node usage planned

## Security Model
- Key-based SSH only
- Firewall rules scoped to tailscale0
- No exposed public ports

## Install (when re-enabled)
```bash
sudo apt install tailscale
sudo systemctl enable --now tailscaled
sudo tailscale up
````

## Health Check

```bash
tailscale status
ip route | grep tailscale
```

## Failure Policy

If Tailscale breaks:

* Disable it
* Do NOT debug remotely
* LAN access always takes priority

## Rule

The homelab must remain:

* Fully usable without Tailscale
* Fully bootable offline

```

---
