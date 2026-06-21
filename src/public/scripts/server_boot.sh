#!/bin/bash
# server_boot.sh — 재부팅 후 기본 상태 점검
# 사용: ./server_boot.sh

set -euo pipefail

echo "=== AND Lab Post-Boot Check ==="
echo "Host: $(hostname)"
echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
echo ""

check_ok() { echo "[OK] $1"; }
check_warn() { echo "[WARN] $1"; }

echo "--- Disk ---"
df -h / /home 2>/dev/null || df -h /
ROOT_USE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
if [[ $ROOT_USE -lt 80 ]]; then
  check_ok "Root partition usage: ${ROOT_USE}%"
else
  check_warn "Root partition usage: ${ROOT_USE}% (80% 이상 — 정리 필요)"
fi
echo ""

echo "--- Memory ---"
free -h
echo ""

echo "--- GPU ---"
if command -v nvidia-smi &>/dev/null; then
  nvidia-smi --query-gpu=name,memory.total,memory.used --format=csv,noheader
  check_ok "nvidia-smi"
else
  check_warn "nvidia-smi not available"
fi
echo ""

echo "--- Docker (milvus) ---"
if command -v docker &>/dev/null; then
  MILVUS=$(docker ps -a 2>/dev/null | grep -i milvus || true)
  if [[ -n "$MILVUS" ]]; then
    echo "$MILVUS"
    check_ok "Milvus containers listed"
  else
    check_warn "No milvus containers found (또는 docker 권한 없음)"
  fi
else
  check_warn "docker not installed"
fi
echo ""

echo "--- SSH reachable ---"
check_ok "Boot check complete"
