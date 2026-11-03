# Common Commands

Frequently used CLI commands on the shared servers.

## Accounts & Directories

### Home directory of each account (UID 1000–65533)

```bash
awk -F: '$3 >= 1000 && $3 < 65534 {printf "%-20s %s\n", $1 ":", $6}' /etc/passwd
```

### Disk usage per account in `/home` (sorted)

```bash
sudo du -sh /home/* | sort -h
```

### Your own home usage

```bash
du -sh ~
du -sh ~/.cache
```


## Resource Monitoring

```bash
htop
top
free -h
glances
nvidia-smi
nvidia-smi -l 1
```


## Shutdown & Reboot

### Schedule a shutdown (UTC)

```bash
sudo shutdown -h {UTC_time}
```

Example: `sudo shutdown -h 14:00` (check the server's local time zone)

### Check a scheduled shutdown

```bash
cat /run/systemd/shutdown/scheduled
```

### Cancel a scheduled shutdown

```bash
sudo shutdown -c
```

::: danger
Run `shutdown` and `reboot` **only with approval from an admin or the lab lead**. They affect other users' jobs.
:::

Helper scripts: [Useful Shell Scripts — server_shutdown.sh / server_boot.sh](./useful-scripts)


## Check RAM Hardware (Admin)

Installation and detection status of RAM in each slot:

```bash
sudo dmidecode -t memory | egrep "Locator:|Bank Locator:|Size:"
```

| Output | Meaning |
|------|------|
| `Size: No Module Installed` | Not installed or not detected |
| `Size: 64 GB` | Installed correctly (e.g. a 64GB module) |

Script version: [ram_info.sh](./useful-scripts#ram-info-sh)


## Permissions & System Info (Admin)

```bash
# Edit sudoers (grant permissions)
sudo visudo

# Check permissions per account
./check_accounts_permissions.sh

# Collect system info → sysinfo_{host}_{date}.txt
./collect_sysinfo.sh
```

Script details: [Useful Shell Scripts](./useful-scripts)


## Docker (Milvus)

```bash
sudo docker ps -a | grep milvus
```

Details: [Milvus Vector DB](./milvus)


## conda & Cache Cleanup

```bash
conda env list
conda clean --all
pip cache purge
```

Details: [Disk & Cache Management](./disk-and-cache)
