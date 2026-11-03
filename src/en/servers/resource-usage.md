# Resource Usage Guide

The shared servers are **resources used by every lab member**. Make a habit of checking how your jobs affect RAM, CPU, and GPU.

## Key Principles

1. Check resource usage **before and after** running a job.
2. Even GPU jobs often **use a lot of CPU/RAM** — don't look only at `nvidia-smi`.
3. **Tell labmates in advance** about long or large-scale jobs.
4. Clean up **leftover processes and sessions** when you're done.
5. If Shared Server 1 is busy, move work to **Shared Server 2**.

::: tip GPU usage
Check who is using which GPU and until when in the **GPU usage** tab of the [lab shared sheet](https://docs.google.com/spreadsheets/d/1TgqyIqoprkRPuUhh50y0tLeVOOxGXhKenrB_wsMH5Ng/edit?gid=1126439604#gid=1126439604), and record your own schedule there too. For other resources, see [Resources](../getting-started/links).
:::


## Commands to Check Resources

| Command | Shows |
|--------|-----------|
| `htop` | CPU, RAM, processes (interactive) |
| `top` | CPU, RAM (basic) |
| `free -h` | Memory usage summary |
| `glances` | Combined monitoring of CPU, RAM, disk, etc. |
| `nvidia-smi` | GPU utilization, VRAM |
| `nvidia-smi -l 1` | GPU status refreshed every second |

When RAM is close to 100%, processes can be killed by OOM (Out of Memory) and SSH may become slow.


## Grafana Power Monitoring {#grafana-power-monitoring}

To deal with server power supply issues, we set up Grafana dashboards that show the shared servers' **power usage in real time**. Check them before starting large GPU jobs or when a server seems unstable.

| Server | Grafana URL |
|------|--------------|
| Shared Server 1 | [http://165.132.192.52:3000/](http://165.132.192.52:3000/) |
| Shared Server 2 | [http://165.132.193.69:3000/](http://165.132.193.69:3000/) |

::: info
A VPN connection is required from off campus.
:::


## Real Case: Milvus OOM (2025.05)

Milvus kept dropping while being restarted. The investigation found:

- **Not a Docker or GPU VRAM problem**
- The cause was **insufficient system RAM (OOM)**
- More Milvus collections → loading needed **about 200GB of RAM**
- At the same time, other users' experiments were using a lot of RAM → **memory at nearly 100%**
- Result: Milvus shut down via safe close, and SSH and ordinary commands lagged

**Lesson:** Loading vector DB collections, loading large data, and multiprocessing training use more RAM than you'd expect.

Full notice: [Notice Archive — RAM & Milvus](./admin/notice-archive#ram-milvus-oom-2025-05)


## Jobs That Use a Lot of RAM

- Loading an entire large dataset (especially with many `DataLoader` workers)
- Loading large HuggingFace models (uses RAM if they don't fit on the GPU)
- Loading Milvus collections
- `multiprocessing` / high `num_workers`
- Idle Jupyter kernels left running


## Before-Job Checklist

```bash
free -h
nvidia-smi
htop   # press q to quit
```

- Is there enough free RAM?
- Is the GPU free (not used by someone else)?
- Is a similar large job already running?


## After-Job Checklist

- Have your training scripts, Jupyter, and tmux sessions ended?
- Are any of your processes still left in `htop`?

Check your processes:

```bash
ps -u {username}
```


## `/home` Space and Resources

A full disk also makes the system unstable. Read this together with [Disk & Cache Management](./disk-and-cache).

- New accounts: `/home` **up to 100GB**
- Virtual environments, data, and checkpoints go in `/mnt/nvme03/{username}/`
- Cache and thread settings in `~/.bashrc` are required


## When Something Goes Wrong

If you notice slow logins, slow commands, or service problems, **tell the lab lead or server admin right away**.
