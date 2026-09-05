#!/bin/bash
# server_shutdown.sh — 서버 종료 예약 (관리자용)
# 사용: sudo ./server_shutdown.sh [시간]
# 예:   sudo ./server_shutdown.sh 14:00

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Error: root 권한이 필요합니다. sudo ./server_shutdown.sh 로 실행하세요." >&2
  exit 1
fi

TIME="${1:-}"

echo "=== ANDlab Server Shutdown ==="
echo "Host: $(hostname)"
echo "현재 로그인 사용자:"
who
echo ""
echo "현재 리소스:"
free -h
echo ""

if [[ -n "$TIME" ]]; then
  echo "예약 종료: $TIME"
  echo "취소: sudo shutdown -c"
  shutdown -h "$TIME"
else
  echo "사용법: sudo $0 [시간]"
  echo "예:     sudo $0 14:00"
  echo ""
  echo "즉시 종료는: sudo shutdown -h now"
  echo "예약 확인:   cat /run/systemd/shutdown/scheduled"
fi
