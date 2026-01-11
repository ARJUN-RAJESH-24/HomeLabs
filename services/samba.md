# Samba Service

## Purpose
Samba provides file sharing for:
- Linux
- Android
- Windows
- TVs / media devices

It is the **primary cross-platform file access layer**.

## Shares
- `Family` → `/srv/data`
- Permissions controlled at filesystem level

## Config File
```text
/etc/samba/smb.conf
````

## Key Settings

* LAN-only access
* User authentication
* No guest access
* SMB2/SMB3 only

## Startup

```bash
sudo systemctl enable --now smbd
```

## Health Check

```bash
systemctl status smbd
smbclient -L localhost -U arjun
```

## Firewall

Required ports:

* 137–138/udp
* 139, 445/tcp

## Backup Policy

* Config file backed up
* No Samba metadata backed up

## Failure Policy

If Samba fails:

* SSH remains primary access
* Fix Samba only after confirming data integrity

````

---

