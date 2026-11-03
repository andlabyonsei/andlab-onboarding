# Notice Archive

Notices about the shared servers (emails and messages) that were shared in the lab, organized as a guide. Use them to understand the policies and their background.

::: tip Original emails
For notices sent by email, the **Original email** links open the original PDF in a new window (in Korean). The original files are also in `src/public/docs/mail/` in the repository.
:::

## Server Power Supply Loss & Shutdowns (2026.09) {#power-shutdown-2026-09}

**Summary:** After the wall outlet lost power and Shared Servers 1 and 2 shut down, shutdowns kept recurring under heavy GPU load while the servers ran on a temporary power connection. In the end, the server vendor ([Miruware](./vendor-contacts#miruware)) **installed a dedicated power receptacle for the servers**, which resolved the power supply problem.

### Timeline

| Date | Details |
|------|------|
| 09.15 | Around 17:21, Shared Servers 1 and 2 shut down at the same time. The cause was that **the wall outlet powering both servers lost power**. Temporarily connected to another outlet and restarted |
| 09.16 | The vendor said the power supply and cables need **custom manufacturing, taking about a week**, and advised that powering servers from ordinary household outlets is **a fire risk**. A repair request for the broken outlet was sent to the campus facilities office via the department office |
| 09.16 | Shared Servers 1 and 2 **suspended** until power was stable. Afterwards, access was allowed only for file backups and data migration (no GPU training or compute). Both servers shut down again due to GPU use during backups |
| 09.16–17 | With only one server able to run, Server 2 was shut down after backups and **only Server 1 ran**. Members were asked to coordinate job schedules within each group |
| 09.23 | Server 1 shut down again early in the morning. While unstable on temporary power, **several GPUs ran at full load at once**, overloading the power supply |
| 09.23 | Following a technician's warning that the equipment becomes sensitive after a shutdown and may fail more often, usage was limited to **at most 2 GPUs per group** |
| 09.30 | The vendor scheduled server power work (servers must be powered off during the visit) |
| 10.02 | Server 2 restored after the equipment work. Right after recovery, 4 GPUs (including unassigned ones) were used at once, and Server 2 went down again about 10–15 minutes later |

### Resolution

- The vendor (Miruware) **installed a receptacle** for server power, supplying stable power instead of an ordinary outlet

![Power receptacle installed for the servers](/images/server-power-receptacle.jpg)

*The server power cable connected to the industrial receptacle (red circle) installed on the wall. Servers are not connected to the ordinary household outlet at the top right.*
- Afterwards, [Grafana Power Monitoring](../resource-usage#grafana-power-monitoring) was introduced to check server power usage in real time

### Lessons

1. **Never connect servers to ordinary household outlets** — insufficient power and fire risk
2. Running several GPUs at full load at once sharply increases total server power usage. **Use only the GPUs assigned to you**, and check power status on Grafana before large jobs.
3. Once a power-related shutdown happens, the equipment becomes sensitive and failures recur more easily, so keep the load especially low right after recovery.


## Shared Server 1 Disk Cleanup & Excessive Sessions (2026.07)

Original email: <a href="/docs/mail/disk-cleanup-sessions.pdf" target="_blank" rel="noopener noreferrer">Notice on Shared Server 1 disk cleanup and excessive session creation (Korean)</a>

**Background (2026.07.18):** A notice about two issues on Shared Server 1: **(1) disk cleanup** and **(2) session limits**.

### 1. Disk cleanup

- Shared Server 1 **main drive usage exceeded 90%** → possible slowdowns and delays
- Clean up unneeded caches, old checkpoints and logs, etc. in `/home`
- Keep personal account usage **at or below 100GB**, as previously instructed
- The list of accounts that needed urgent cleanup at the time is in the image attached to the original email

### 2. Excessive sessions · access limits

**Symptom:** Users reported that `sudo` failed with a "No space left on device" error.

**Cause:** Not a lack of disk space, but **exhaustion of the shared system cache space** used by `sudo` and others. Access logs from 7/17 showed **close to several thousand sessions** opened at once by a specific account. This is far more than a person could open manually, so it was presumed that **AI agents such as Claude or Cursor opened too many sessions in parallel**.

**Impact:** Too many sessions exhaust resources needed for system control, making `sudo` unusable and creating **a risk for all users**.

**Actions & requests:**

- Limited each personal account on Shared Server 1 to **at most 10 sessions** (applied with help from 건일)
- Work in a **single session** when possible
- AI agents may be used, but take care not to affect other users — e.g. **check their parallel session and connection options**


## Per-Account Cleanup & New Management Rules (2026.03)

Original email: <a href="/docs/mail/root-partition-policy.pdf" target="_blank" rel="noopener noreferrer">Notice on freeing root partition space and shared server management rules (Korean)</a>

**Background (2026.03.05):** Following the earlier `/home` space notice, this notice set out per-account cleanup and **ongoing management rules**.

### 1. Per-account data cleanup

- Keep `/home` usage **at or below 100GB**
- If you have technical difficulty freeing space, say so in advance

### 2. Planned deletion of long-unused accounts

- Back up any data you need before deletion
- Accounts spread across other disks were also to be cleaned up gradually after checking whether they are still needed

### 3. Ongoing management rules (new · still in effect)

| Rule | Details |
|------|------|
| Account location & quota | Created and managed in `/home`, **up to 100GB** per account |
| Large data | Under `/mnt`, not `/home` |
| Virtual environments | `conda create -p /mnt/nvme03/{username}/envs/{env_name}` |
| Caches | `HF_HOME`, `TORCH_HOME`, `PIP_CACHE_DIR` → `/mnt/nvme03/{username}/.cache/...` (add to `.bashrc`) |
| Data & outputs | Datasets, `.pt`/`.ckpt`, Tensorboard/WandB logs, etc. → `/mnt/nvme03/{username}/` |


## `/home` Space Management Notice (2026.03)

Original email: <a href="/docs/mail/home-disk-shortage.pdf" target="_blank" rel="noopener noreferrer">Notice on shared server disk space shortage (Korean)</a>

**Background (2026.03.04):** The root partition (`/`) was nearly **100%** full. Of the roughly **1.8TB** core area where the OS is installed, `/home` alone used about **1.5TB**, leaving practically no room for system operation.

**Risks when root is at 100%:**

- Logs can't be written → no way to analyze failures
- Package installs/updates fail
- Python virtual environments can't be created
- Checkpoints fail to save during model training
- Code errors because temporary files can't be created
- Services/processes terminate abnormally
- In the worst case, **the system fails to boot**

If this continues, research can halt and servers become unstable. As a rule, `/home` is reserved for the OS and large data is moved to `/mnt`.

**Requested actions (still in effect as policy):**

1. Delete unused conda/venv environments and clear caches with `conda clean --all`
2. Delete `.pt`/`.ckpt` files from earlier epochs after training → keep **only the best**, and clean up Tensorboard and text logs
3. Compress large data and outputs, then move them to `/mnt/nvme03` or personal cloud storage
4. Clean up `~/.cache` (`/home/*/.cache`) — clearing caches alone frees a lot of space

**Goal:** Keep **at least 300–400GB** (about 20% of the total) free on the root partition for logs, package updates, etc.

Tips from the same thread on storing virtual environments, caches, and outputs in `/mnt` were later reflected in the management rules. Some members use `/mnt/nvme02`, so ask the lab lead which mount path is assigned to you.


## RAM & Milvus OOM (2025.05) {#ram-milvus-oom-2025-05}

Original email: <a href="/docs/mail/ram-milvus-oom.pdf" target="_blank" rel="noopener noreferrer">Notice on the shared server RAM shortage and request for cooperation on resource usage (Korean)</a>

**Background (2025.05.31):** Attempts to restart Milvus kept stopping partway through. The cause was not Docker or a lack of GPU VRAM but **system RAM OOM (Out of Memory)**.

**Situation at the time:**

- As Milvus collections grew, normal startup and loading required **about 200GB of RAM**
- Other users' experiments were already using a large amount of RAM → overall server memory usage was **nearly 100%** (per glances)
- Milvus could not load all collections and stopped via **safe close**
- Affected **overall server usability**, including slow SSH logins and slow commands
- Recovered by an on-site reboot at school

Loading large models, loading vector DB collections, multiprocessing, and similar tasks can use more RAM than expected. Code you run as a "GPU job" may actually be CPU/RAM-heavy, so check system RAM along with VRAM.

**Requests (still valid):**

1. Regularly check CPU, RAM, and GPU usage with `htop`, `top`, `free -h`, `glances`, and `nvidia-smi`
2. Announce long or large jobs in advance when possible, and check for leftover processes and sessions afterwards
3. If Shared Server 1 is crowded, create an account on **Shared Server 2** and spread the load
4. Apply the `/home` space management and CPU thread limit settings from [Disk & Cache Management](../disk-and-cache) to your account

**Cache, virtual environment, and thread limits (recommended in `.bashrc`)**

```bash
# Create virtual environments under /mnt
conda create -p /mnt/nvme03/[username]/envs/myenv python=3.10
conda activate /mnt/nvme03/[username]/envs/myenv

# Move HuggingFace / PyTorch / pip caches to /mnt
export HF_HOME=/mnt/nvme03/[username]/.cache/huggingface
export TORCH_HOME=/mnt/nvme03/[username]/.cache/torch
export PIP_CACHE_DIR=/mnt/nvme03/[username]/.cache/pip

# Prevent hogging CPU threads (often speeds up your own experiments too)
export TOKENIZERS_PARALLELISM=false
export OMP_NUM_THREADS=8
export MKL_NUM_THREADS=8
```

Keep **large files** — virtual environments, caches, datasets, model checkpoints, experiment logs — **not in `/home`** but in separate storage such as `/mnt/nvme03/[username]/`.


## Extra Tip for Members (nvme02 example)

Some members use `/mnt/nvme02`. Ask the lab lead which mount path is assigned to you. The principle is the same: **large data goes in `/mnt`, not `/home`**.
