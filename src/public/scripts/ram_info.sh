#!/bin/bash
# ram_info.sh — 메모리 슬롯별 설치·인식 상태 확인
# 사용: ./ram_info.sh  (sudo 권한 필요할 수 있음)

set -euo pipefail

echo "=== AND Lab RAM Info ==="
echo "Host: $(hostname)"
echo "Date: $(date -Iseconds)"
echo ""

if command -v dmidecode &>/dev/null; then
  if [[ $EUID -ne 0 ]]; then
    echo "(sudo로 dmidecode 실행)"
    sudo dmidecode -t memory | egrep "Locator:|Bank Locator:|Size:"
  else
    dmidecode -t memory | egrep "Locator:|Bank Locator:|Size:"
  fi
else
  echo "Error: dmidecode not found" >&2
  exit 1
fi

echo ""
echo "--- 해석 ---"
echo "  Size: No Module Installed  → 미설치 또는 인식 실패"
echo "  Size: 64 GB (등)           → 정상 설치"
