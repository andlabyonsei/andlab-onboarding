# Useful Shell Scripts

Scripts for managing, checking, and downloading on the shared servers. The originals are in `src/public/scripts/` in the repository, and are also served at `/scripts/` after the build.

::: info
The scripts below are shown exactly as used on the servers, so some output labels and comments are in Korean.
:::


## ram_info.sh

**Purpose:** Shows at a glance which memory slots have RAM installed and detected. May require `sudo`.

```bash
#!/bin/bash

echo "=============================="
echo "  설치된 RAM 슬롯 정보"
echo "=============================="
printf "%-5s %-25s %-10s %-15s %-20s %-15s\n" \
    "No." "슬롯 위치 (Locator)" "크기" "타입" "속도" "제조사"
echo "-----------------------------------------------------------------------------------------------"

count=0
locator="" size="" type="" speed="" manufacturer=""

flush_entry() {
    if [[ -n "$size" && "$size" != "No Module Installed" && "$size" != "Unknown" ]]; then
        count=$((count + 1))
        printf "%-5s %-25s %-10s %-15s %-20s %-15s\n" \
            "$count" "$locator" "$size" "$type" "$speed" "$manufacturer"
    fi
    locator="" size="" type="" speed="" manufacturer=""
}

while IFS= read -r line; do
    # 새 블록 시작 시 이전 블록 출력
    if [[ "$line" == *"Memory Device"* && "$line" != *"Memory Device Mapped"* ]]; then
        flush_entry
        continue
    fi

    [[ "$line" =~ ^[[:space:]]*Locator:[[:space:]]+(.*) ]]      && locator="${BASH_REMATCH[1]}"
    [[ "$line" =~ ^[[:space:]]*Size:[[:space:]]+(.*) ]]         && size="${BASH_REMATCH[1]}"
    [[ "$line" =~ ^[[:space:]]*Type:[[:space:]]+(.*) ]]         && type="${BASH_REMATCH[1]}"
    [[ "$line" =~ ^[[:space:]]*Speed:[[:space:]]+(.*) ]]        && speed="${BASH_REMATCH[1]}"
    [[ "$line" =~ ^[[:space:]]*Manufacturer:[[:space:]]+(.*) ]] && manufacturer="${BASH_REMATCH[1]}"

done < <(sudo dmidecode -t memory)

# 마지막 블록 출력
flush_entry

echo "-----------------------------------------------------------------------------------------------"
echo "총 장착 모듈 수: $count"
```

**How to run:**

```bash
chmod +x ram_info.sh
./ram_info.sh
```

Related log: [Hardware Work Log](./admin/hardware-maintenance#ram-failure-2026-06-15)


## check_accounts_permissions.sh

**Purpose:** Prints a summary of group permissions for each account with UID 1000 or above.

```bash
cut -d: -f1,3 /etc/passwd | awk -F: '$2 >= 1000 {print $1}' | while read user; do 
    printf "%-15s : %s\n" "$user" "$(groups $user)"
done
```

**How to run:**

```bash
chmod +x check_accounts_permissions.sh
./check_accounts_permissions.sh
```


## collect_sysinfo.sh

**Purpose:** Collects the host's system information (CPU, RAM, disks, GPU, OS, etc.) and saves it to a file.

```bash
#!/usr/bin/env bash

OUT="sysinfo_$(hostname)_$(date +%Y%m%d).txt"

{
  echo "===== BASIC ====="
  echo "Hostname: $(hostname)"
  echo "Date: $(date)"
  echo "Uptime: $(uptime -p)"

  echo
  echo "===== OS / KERNEL ====="
  echo "OS:"
  cat /etc/os-release 2>/dev/null
  echo
  echo "Kernel: $(uname -r)"

  echo
  echo "===== CPU ====="
  lscpu

  echo
  echo "===== MEMORY ====="
  free -h
  echo
  echo "Detailed (dmidecode, root only):"
  sudo dmidecode -t memory 2>/dev/null || echo "dmidecode not available or no permission"

  echo
  echo "===== DISKS / FILESYSTEMS ====="
  lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
  echo
  df -h

  echo
  echo "===== GPU (nvidia-smi) ====="
  if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi -L
    echo
    nvidia-smi
  else
    echo "nvidia-smi not found"
  fi

  echo
  echo "===== NETWORK ====="
  ip -brief addr
  echo
  echo "NICs:"
  lspci | grep -i -E 'ethernet|network'
} > "$OUT"

echo "Saved to $OUT"
```

**How to run:**

```bash
chmod +x collect_sysinfo.sh
./collect_sysinfo.sh
```

Output file: `sysinfo_{hostname}_{date}.txt`


## check_disk_usage.sh

**Purpose:** Checks disk usage under `/home` and in specified paths, and saves it as CSV. Requires `sudo`.

```bash
#!/usr/bin/env bash

set -u
export LC_ALL=C

TIMESTAMP=$(date +%F_%H%M%S)
OUTPUT_CSV="disk_usage_report_${TIMESTAMP}.csv"

# 조회할 개별 계정 경로 목록
paths=(
    "/home/{계정명}",
    "/mnt/nvme02/User/{계정명}"
    "/mnt/nvme02/home/{계정명}"
    "/mnt/nvme03/home/{계정명}"
)

# CSV 헤더 생성
echo "계정명,용량" > "$OUTPUT_CSV"

# 터미널 출력 헤더
printf "%-55s %12s\n" "계정명(경로)" "용량"
printf "%-55s %12s\n" "-------------------------------------------------------" "------------"

add_row() {
    local path="$1"
    local size="$2"

    printf "%-55s %12s\n" "$path" "$size"
    printf "\"%s\",\"%s\"\n" "$path" "$size" >> "$OUTPUT_CSV"
}

# 1) /home 하위 1단계 조회
while read -r size path; do
    add_row "$path" "$size"
done < <(sudo du -xh /home --max-depth=1 2>/dev/null | sort -h)

# 2) 개별 지정 경로 조회
for path in "${paths[@]}"; do
    if [ ! -e "$path" ]; then
        add_row "$path" "NOT_FOUND"
        continue
    fi

    size=$(sudo du -sh "$path" 2>/dev/null | awk '{print $1}')

    if [ -z "${size:-}" ]; then
        add_row "$path" "ERROR"
    else
        add_row "$path" "$size"
    fi
done

echo
echo "완료: $OUTPUT_CSV"
```

**How to run:**

::: tip
Edit the `paths` array in the script for the current server and accounts before running it.
:::

```bash
chmod +x check_disk_usage.sh
./check_disk_usage.sh
```

Output file: `disk_usage_report_{date_time}.csv`


## gpu_users.sh

**Purpose:** Prints a table of processes, users, and memory share for each GPU.

```bash
#!/bin/bash
# gpu_users.sh - GPU 사용 프로세스 + 사용자 + GPU index + 메모리 점유율 표시

set -euo pipefail

# GPU 메타정보 캐시 (uuid -> index/total/used)
declare -A UUID_TO_INDEX
declare -A UUID_TO_MEM_TOTAL
declare -A UUID_TO_MEM_USED

# GPU 목록 읽기
# format 예: GPU-xxxx, 0, 40960, 1024
while IFS=',' read -r uuid index total used; do
  uuid=$(echo "$uuid" | xargs)
  index=$(echo "$index" | xargs)
  total=$(echo "$total" | xargs)
  used=$(echo "$used" | xargs)

  UUID_TO_INDEX["$uuid"]="$index"
  UUID_TO_MEM_TOTAL["$uuid"]="$total"
  UUID_TO_MEM_USED["$uuid"]="$used"
done < <(nvidia-smi --query-gpu=gpu_uuid,index,memory.total,memory.used --format=csv,noheader,nounits)

echo "======================================================================="
echo " GPU Process / User (with GPU index + memory share)"
echo " $(date)"
echo "======================================================================="
printf "%-4s %-7s %-12s %-20s %-18s %-14s %-14s\n" \
  "GPU" "PID" "USER" "PROCESS" "PROC_MEM" "PROC%TOTAL" "GPU_USED/TOT(%)"
echo "-----------------------------------------------------------------------"

# 프로세스 목록 읽기
# format 예: 12345, GPU-xxxx, 2048
# (compute-apps가 없으면 아무 것도 안 나올 수 있음)
nvidia-smi --query-compute-apps=pid,gpu_uuid,used_memory --format=csv,noheader,nounits 2>/dev/null | \
while IFS=',' read -r pid uuid proc_mem; do
  pid=$(echo "$pid" | xargs)
  uuid=$(echo "$uuid" | xargs)
  proc_mem=$(echo "$proc_mem" | xargs)

  gpu_index="${UUID_TO_INDEX[$uuid]:-?}"
  gpu_total="${UUID_TO_MEM_TOTAL[$uuid]:-0}"
  gpu_used="${UUID_TO_MEM_USED[$uuid]:-0}"

  # PID -> user/command
  user=$(ps -o user= -p "$pid" 2>/dev/null | xargs || true)
  comm=$(ps -o comm= -p "$pid" 2>/dev/null | xargs || true)
  if [[ -z "${user:-}" ]]; then
    user="(exited)"
    comm="N/A"
  fi

  # 프로세스가 GPU 총 메모리에서 차지하는 비율
  if [[ "$gpu_total" -gt 0 ]]; then
    proc_pct=$(awk -v m="$proc_mem" -v t="$gpu_total" 'BEGIN { printf "%.1f%%", (m/t)*100 }')
    gpu_pct=$(awk -v u="$gpu_used" -v t="$gpu_total" 'BEGIN { printf "%.1f%%", (u/t)*100 }')
  else
    proc_pct="N/A"
    gpu_pct="N/A"
  fi

  proc_mem_str="${proc_mem}MiB"
  gpu_mem_str="${gpu_used}/${gpu_total}MiB(${gpu_pct})"

  printf "%-4s %-7s %-12s %-20s %-18s %-14s %-14s\n" \
    "$gpu_index" "$pid" "$user" "$comm" "$proc_mem_str" "$proc_pct" "$gpu_mem_str"
done

echo "======================================================================="
```

**How to run:**

```bash
chmod +x gpu_users.sh
./gpu_users.sh
```


## top_mem_procs.sh

**Purpose:** Prints the processes using the most RAM and the total per account.

```bash
#!/bin/bash
# top_mem_procs.sh - RAM 점유율 높은 프로세스 및 계정 출력

echo "========================================"
echo " [프로세스별 RAM 점유율 TOP 20]"
echo "========================================"
printf "%-12s %-8s %-6s %-10s %s\n" "USER" "PID" "%MEM" "RSS(GB)" "COMMAND"
echo "------------------------------------------------------------"
ps aux --no-headers --sort=-%mem | head -20 | awk '{
    printf "%-12s %-8s %-6s %-10.3f %s\n", $1, $2, $4, $6/1024/1024, $11
}'

echo ""
echo "========================================"
echo " [계정별 RAM 사용량 합계]"
echo "========================================"
printf "%-15s %s\n" "USER" "TOTAL_RSS(GB)"
echo "-----------------------------"
ps aux --no-headers | awk '{mem[$1] += $6} END {
    for (user in mem)
        printf "%-15s %.3f\n", user, mem[user]/1024/1024
}' | sort -k2 -rn
```

**How to run:**

```bash
chmod +x top_mem_procs.sh
./top_mem_procs.sh
```


## download_hf_model.py

**Purpose:** Downloads Hugging Face model snapshots to `/mnt/nvme01/huggingface/models`.

```python
from huggingface_hub import snapshot_download

MODELS_ROOT = "/mnt/nvme01/huggingface/models"
MODEL_IDS = []

for repo_id in MODEL_IDS:
    local_dir = f"{MODELS_ROOT}/{repo_id}"
    local_path = snapshot_download(
        repo_id=repo_id,
        repo_type="model",
        local_dir=local_dir,
    )
    print(f"Model snapshot downloaded to: {local_path}")
```

**How to run:**

::: tip
Uncomment the models you need in the `MODEL_IDS` list before running. `huggingface_hub` must be installed.
:::

```bash
python hf/download_hf_model.py
```


## download_hf_dataset.py

**Purpose:** Downloads Hugging Face dataset snapshots (parquet) to `/mnt/nvme03/huggingface/datasets`.

```python
from huggingface_hub import snapshot_download

DATASETS_ROOT = "/mnt/nvme03/huggingface/datasets"
DATASET_IDS = []

for repo_id in DATASET_IDS:
    local_dir = f"{DATASETS_ROOT}/{repo_id}"
    local_path = snapshot_download(
        repo_id=repo_id,
        repo_type="dataset",
        local_dir=local_dir,
        allow_patterns=["*.parquet"],
    )
    print(f"Dataset snapshot downloaded to: {local_path}")
```

**How to run:**

::: tip
Uncomment the datasets you need in the `DATASET_IDS` list before running.
:::

```bash
python hf/download_hf_dataset.py
```


## Downloading & Deploying Scripts

If you have cloned the guide repository locally:

```bash
# From the repository root
cp src/public/scripts/*.sh ~/
cp -r src/public/scripts/hf ~/
chmod +x ~/*.sh
```

To copy scripts directly to a server, use `scp`.

```bash
scp src/public/scripts/ram_info.sh {user}@{server}:~/
scp -r src/public/scripts/hf {user}@{server}:~/
```
