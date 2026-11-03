# Shared Servers Overview

ANDlab runs **two shared servers** for research. GPU training, large-scale experiments, the Milvus vector DB, and similar workloads run on these servers.

::: tip Server specs & status
See the [lab shared sheet](https://docs.google.com/spreadsheets/d/1TgqyIqoprkRPuUhh50y0tLeVOOxGXhKenrB_wsMH5Ng/edit?gid=1126439604#gid=1126439604) for each server's specs (RAM, GPU, storage) and current usage.
:::

## Rules Every New Member Must Know

1. **`/home` is for the OS only** — Each account gets **up to 100GB** by default. Store virtual environments, datasets, and checkpoints under `/mnt`.
2. **Check resources regularly** — Keep an eye on RAM, GPU VRAM, and CPU. ([Resource Usage Guide](./resource-usage))
3. **Spread the load** — If Shared Server 1 is crowded, create an account on Shared Server 2 and work there.
4. **Announce large jobs in advance** — Let labmates know before long training runs or loading large data.

## Server Access & Setup Manuals {#setup-manuals}

The manuals below cover the whole process: account creation, SSH access, editor connection, and installing CUDA, cuDNN, Anaconda, and PyTorch. Download the one that matches your server's OS version.

| Document | Download |
|------|----------|
| Linux (Ubuntu 22.04) manual v2.2 (Server 1) | <a href="/docs/linux-ubuntu-22.04-manual-v2.2.pdf" download="리눅스_(Ubuntu_22.04)_메뉴얼_v2.2.pdf">Download PDF (Korean)</a> |
| Linux (Ubuntu 24.04) manual v2.3 (Server 2) | <a href="/docs/linux-ubuntu-24.04-manual-v2.3.pdf" download="리눅스_(Ubuntu_24.04)_메뉴얼_v2.3.pdf">Download PDF (Korean)</a> |

::: info
The manuals are written in Korean, but the commands and screenshots are easy to follow. Ask a labmate if you get stuck.
:::

## Contents

| Document | Contents |
|------|------|
| [Disk & Cache Management](./disk-and-cache) | Using `/mnt`, `.bashrc` environment variables |
| [Resource Usage Guide](./resource-usage) | RAM/GPU monitoring, Grafana power monitoring, cleanup |
| [Milvus Vector DB](./milvus) | Attu access, Docker container management |
| [Common Commands](./common-commands) | Disk usage, shutdown, etc. |
| [Useful Shell Scripts](./useful-scripts) | ram_info, sysinfo, etc. |

## For Admins

The lab lead and server admins should also see the [Hardware Work Log](./admin/hardware-maintenance), [Hardware Work Guide](./admin/hardware-guide), [Accounts & Services](./admin/account-service), and [Notice Archive](./admin/notice-archive).
