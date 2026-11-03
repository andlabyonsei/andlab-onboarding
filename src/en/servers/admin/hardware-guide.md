# Hardware Work Guide

Methods and principles for the lab lead and server admins when doing hardware work. For past work, see the [Hardware Work Log](./hardware-maintenance); for vendor inspections or repairs, see [Vendor Contacts](./vendor-contacts).

## Scale RAM with GPUs

When GPU VRAM grows, **system RAM must grow too**. Loading large models or Milvus collections sharply increases RAM demand.


## RAM Check & Fault Diagnosis {#ram-check}

Related log: [2026.06.15 — Shared Server 1 RAM Failure](./hardware-maintenance#ram-failure-2026-06-15)

### Check command

```bash
sudo dmidecode -t memory | egrep "Locator:|Bank Locator:|Size:"
```

Or run [ram_info.sh](../useful-scripts#ram-info-sh)

### Bad slot vs. bad RAM

| Symptom | Action |
|------|------|
| Only a specific module is not detected | Replace that RAM module |
| Problem with the slot itself | May need a **motherboard replacement** |


## Mounting a Newly Installed SSD

After installing a new SSD, identify the disk and register it in `/etc/fstab` so it mounts automatically after reboots. The shared servers use **one mount point per disk**, such as `/mnt/nvme01`, `/mnt/nvme02`, …

### 1. Identify the new disk

```bash
sudo fdisk -l
```

- Find the newly installed SSD among the `Disk /dev/nvme…n1` entries by its **size and model name**.
- Existing disks already have partitions (e.g. `/dev/nvme0n1p1`); new disks usually have none.
- `lsblk -f` shows each disk's partitions, file systems, and **current mount points** at a glance.

::: danger Double-check the disk
Picking the wrong disk **erases existing data**. Before partitioning or formatting, verify twice — by size and model name — that it is the new disk.
:::

### 2. Partition and format (new disks only)

```bash
# Example: the new disk is /dev/nvme4n1
sudo parted /dev/nvme4n1 --script mklabel gpt mkpart primary ext4 0% 100%
sudo mkfs.ext4 /dev/nvme4n1p1
```

**Skip** this step if you moved over a disk that already has data.

### 3. Create the mount point

```bash
sudo mkdir -p /mnt/nvme04
```

### 4. Map the disk to the mount point in `/etc/fstab`

Device names (`/dev/nvme4n1p1`) **can change** depending on install order or reboots, so register the disk in fstab by its unique **UUID**.

```bash
sudo blkid /dev/nvme4n1p1
# /dev/nvme4n1p1: UUID="1234abcd-..." TYPE="ext4" ...
```

Back up fstab before editing it.

```bash
sudo cp /etc/fstab /etc/fstab.bak
sudo vi /etc/fstab
```

Add one line at the bottom of the file.

```
# <disk UUID>                              <mount point>  <filesystem>  <options>          <dump> <pass>
UUID=1234abcd-xxxx-xxxx-xxxx-xxxxxxxxxxxx  /mnt/nvme04    ext4          defaults,nofail    0      2
```

| Field | Description |
|------|------|
| `UUID=…` | Partition UUID from `blkid` |
| Mount point | The directory created in step 3 |
| `defaults,nofail` | With `nofail`, **boot does not stop** even if the disk isn't detected |
| `0 2` | No backup / file system check at boot after root (`1`) |

In `vi`, press `i` for insert mode; after editing, press `Esc` → `:wq` to save.

### 5. Apply and verify

```bash
sudo systemctl daemon-reload
sudo mount -a        # mount everything in fstab — should finish with no errors
df -h | grep nvme    # check the new mount point and size
lsblk -f
```

::: warning Always run `mount -a` before rebooting
A typo in fstab (UUID, path, etc.) can **prevent the server from booting**. Make sure `sudo mount -a` finishes without errors before rebooting. If something goes wrong, restore the backup `/etc/fstab.bak`.
:::

### 6. Set permissions (if needed)

```bash
sudo chmod 755 /mnt/nvme04
sudo mkdir -p /mnt/nvme04/{username}
sudo chown {username}:{username} /mnt/nvme04/{username}
```

If the new disk will be used as storage for lab members, also update the storage locations in [Disk & Cache Management](../disk-and-cache).


## Per-GPU Power Limits

When several GPUs run at full load at the same time, server power usage spikes and can cause a shutdown. ([2026.09 power shutdown case](./notice-archive#power-shutdown-2026-09)) For NVIDIA GPUs, **lowering the power limit** is the simplest and most effective approach. The commands below that change settings require **root privileges**.

Check power usage on [Grafana Power Monitoring](../resource-usage#grafana-power-monitoring) as well.

### Per-Server Settings

These are the GPU power limits currently applied to the shared servers. If the power limit was reset after a reboot, run the commands below again on that server.

| Server | Power limit per GPU |
|------|----------------|
| Server 1 | 300W |
| Server 2 | 500W |

::: code-group
```bash [Server 1]
sudo nvidia-smi -pm 1     # enable persistence mode
sudo nvidia-smi -pl 300   # limit all GPUs to 300W
```

```bash [Server 2]
sudo nvidia-smi -pm 1     # enable persistence mode
sudo nvidia-smi -pl 500   # limit all GPUs to 500W
```
:::

If you change these values, update this table and the commands too. The general setup steps follow below.

### 1. Check current status and allowed range

```bash
nvidia-smi --query-gpu=index,name,power.draw,power.limit,power.min_limit,power.max_limit --format=csv
```

### 2. Set the power limit

```bash
# Limit all GPUs to 200W
sudo nvidia-smi -pl 200

# Limit only GPU 0 to 200W
sudo nvidia-smi -i 0 -pl 200
```

The value must be within the min–max range from step 1.

### 3. Lock clock limits

```bash
# Check supported clocks
nvidia-smi -q -d SUPPORTED_CLOCKS

# Limit the GPU core clock to 300–1500MHz
sudo nvidia-smi -i 0 -lgc 300,1500

# Limit the memory clock (supported models only; pick values from the list above)
sudo nvidia-smi -i 0 -lmc 405,5001

# Restore defaults
sudo nvidia-smi -i 0 -rgc
sudo nvidia-smi -i 0 -rmc
```

### 4. Reduce idle power

```bash
# Enable persistence mode
sudo systemctl enable --now nvidia-persistenced

# Check processes holding the GPU
nvidia-smi
```

On headless servers, enabling persistence mode avoids repeated driver initialization, making it easier to stay in a low-power state when idle. If power draw is high with no jobs running, check for leftover processes still holding the GPU. ([gpu_users.sh](../useful-scripts#gpu-users-sh) shows users per GPU)

### 5. Keep settings after reboot

`nvidia-smi -pl` settings reset on reboot. To keep them, register a systemd service. Create `/etc/systemd/system/gpu-power-limit.service` with the following content.

```ini
[Unit]
Description=Set GPU power limit
After=nvidia-persistenced.service

[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-smi -pl 200

[Install]
WantedBy=multi-user.target
```

To use different values per GPU, add several lines with GPU indices, such as `ExecStart=/usr/bin/nvidia-smi -i 0 -pl 200`.

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now gpu-power-limit.service
```

### Notes

- **Recommended starting point:** First try lowering to about 70–80% of the default limit. In this range the performance loss is often smaller than the power savings, but it depends on the workload, so verify with real jobs.
- **Check the effect:** The command below shows power (`pwr`) and clocks (`mclk`, `pclk`) in real time.

  ```bash
  nvidia-smi dmon -s pc
  ```

- **Caveat:** In cloud or virtualized environments, these settings may be blocked by permissions or GPU model restrictions.
- If you change the power limit, notify lab members and record the date and values in the [Hardware Work Log](./hardware-maintenance).

::: details For AMD GPUs
```bash
# Check current power
rocm-smi --showpower

# Set GPU 0's power limit to 200W
sudo rocm-smi -d 0 --setpoweroverdrive 200

# Lock to the low-power performance level (performance may drop significantly)
sudo rocm-smi -d 0 --setperflevel low

# Restore defaults
sudo rocm-smi -d 0 --setperflevel auto
```
:::
