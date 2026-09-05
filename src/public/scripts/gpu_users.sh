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
