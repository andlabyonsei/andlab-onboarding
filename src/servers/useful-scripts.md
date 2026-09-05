# 유용한 쉘 스크립트

공용 서버 관리·점검·다운로드에 쓰는 스크립트입니다. 원본은 저장소 `docs/scripts/`에 있으며, 빌드 후 `/scripts/` 경로로도 접근할 수 있습니다.


## ram_info.sh

**용도:** 메모리 슬롯별 설치·인식 상태를 한눈에 확인합니다. `sudo` 권한이 필요할 수 있습니다.

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

**실행 방법:**

```bash
chmod +x ram_info.sh
./ram_info.sh
```

관련 이력: [하드웨어·유지보수](./admin/hardware-maintenance#20260615-공용서버1-ram-불량)


## check_accounts_permissions.sh

**용도:** UID 1000 이상 계정별 그룹 권한을 요약 출력합니다.

```bash
cut -d: -f1,3 /etc/passwd | awk -F: '$2 >= 1000 {print $1}' | while read user; do 
    printf "%-15s : %s\n" "$user" "$(groups $user)"
done
```

**실행 방법:**

```bash
chmod +x check_accounts_permissions.sh
./check_accounts_permissions.sh
```


## collect_sysinfo.sh

**용도:** 호스트의 시스템 정보(CPU, RAM, 디스크, GPU, OS 등)를 수집해 파일로 저장합니다.

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

**실행 방법:**

```bash
chmod +x collect_sysinfo.sh
./collect_sysinfo.sh
```

출력 파일명: `sysinfo_{호스트이름}_{실행날짜}.txt`


## check_disk_usage.sh

**용도:** `/home` 하위와 지정 경로의 디스크 사용량을 조회하고 CSV로 저장합니다. `sudo` 권한이 필요합니다.

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

**실행 방법:**

::: tip
스크립트 안의 `paths` 배열을 현재 서버·계정에 맞게 수정한 뒤 실행하세요.
:::

```bash
chmod +x check_disk_usage.sh
./check_disk_usage.sh
```

출력 파일명: `disk_usage_report_{날짜_시간}.csv`


## gpu_users.sh

**용도:** GPU별 사용 프로세스·사용자·메모리 점유율을 표로 출력합니다.

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

**실행 방법:**

```bash
chmod +x gpu_users.sh
./gpu_users.sh
```


## top_mem_procs.sh

**용도:** RAM 점유율 상위 프로세스와 계정별 합계를 출력합니다.

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

**실행 방법:**

```bash
chmod +x top_mem_procs.sh
./top_mem_procs.sh
```


## download_hf_model.py

**용도:** Hugging Face 모델을 `/mnt/nvme01/huggingface/models`로 스냅샷 다운로드합니다.

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

**실행 방법:**

::: tip
`MODEL_IDS` 목록에서 필요한 모델의 주석을 해제한 뒤 실행하세요. `huggingface_hub`가 설치되어 있어야 합니다.
:::

```bash
python hf/download_hf_model.py
```


## download_hf_dataset.py

**용도:** Hugging Face 데이터셋(parquet)을 `/mnt/nvme03/huggingface/datasets`로 스냅샷 다운로드합니다.

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

**실행 방법:**

::: tip
`DATASET_IDS` 목록에서 필요한 데이터셋의 주석을 해제한 뒤 실행하세요.
:::

```bash
python hf/download_hf_dataset.py
```


## 스크립트 다운로드·배포

로컬에서 가이드 저장소를 clone한 경우:

```bash
# 저장소 루트에서
cp docs/scripts/*.sh ~/
cp -r docs/scripts/hf ~/
chmod +x ~/*.sh
```

서버에 직접 옮길 때는 `scp`를 사용합니다.

```bash
scp docs/scripts/ram_info.sh {계정}@{서버}:~/
scp -r docs/scripts/hf {계정}@{서버}:~/
```
