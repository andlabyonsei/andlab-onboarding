#!/bin/bash
# collect_sysinfo.sh — 시스템 정보 수집 후 파일 저장
# 사용: ./collect_sysinfo.sh
# 출력: sysinfo_{hostname}_{YYYYMMDD}.txt

set -euo pipefail

HOST=$(hostname -s)
DATE=$(date +%Y%m%d)
OUTFILE="sysinfo_${HOST}_${DATE}.txt"

{
  echo "=== AND Lab System Info ==="
  echo "Collected: $(date -Iseconds)"
  echo "Hostname: $(hostname -f)"
  echo ""

  echo "=== OS ==="
  if [[ -f /etc/os-release ]]; then
    cat /etc/os-release
  else
    uname -a
  fi
  echo ""

  echo "=== CPU ==="
  if [[ -f /proc/cpuinfo ]]; then
    grep -m1 "model name" /proc/cpuinfo
    echo "Cores: $(nproc)"
  fi
  echo ""

  echo "=== Memory ==="
  free -h
  echo ""
  if command -v dmidecode &>/dev/null; then
    echo "--- RAM slots (summary) ---"
    if [[ $EUID -ne 0 ]]; then
      sudo dmidecode -t memory 2>/dev/null | egrep "Locator:|Size:" || true
    else
      dmidecode -t memory | egrep "Locator:|Size:" || true
    fi
  fi
  echo ""

  echo "=== Disk ==="
  df -h
  echo ""

  echo "=== GPU ==="
  if command -v nvidia-smi &>/dev/null; then
    nvidia-smi
  else
    echo "nvidia-smi not available"
  fi
  echo ""

  echo "=== Docker (milvus) ==="
  if command -v docker &>/dev/null; then
    docker ps -a 2>/dev/null | grep -i milvus || echo "No milvus containers or no permission"
  else
    echo "docker not installed"
  fi
  echo ""

  echo "=== /home usage (top 10) ==="
  if [[ $EUID -eq 0 ]]; then
    du -sh /home/* 2>/dev/null | sort -h | tail -10
  else
    sudo du -sh /home/* 2>/dev/null | sort -h | tail -10 || echo "sudo required for /home du"
  fi

} | tee "$OUTFILE"

echo ""
echo "Saved to: $OUTFILE"
