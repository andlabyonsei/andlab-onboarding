#!/bin/bash
# check_accounts_permissions.sh — 일반 사용자 계정의 그룹·sudo 권한 요약
# 사용: ./check_accounts_permissions.sh

set -euo pipefail

echo "=== AND Lab Account Permissions ==="
echo "Host: $(hostname)"
echo "Date: $(date -Iseconds)"
echo ""

printf "%-20s %-40s %s\n" "USER" "GROUPS" "SUDO"
printf "%-20s %-40s %s\n" "----" "------" "----"

while IFS=: read -r user _ uid _ _ home shell; do
  if [[ $uid -ge 1000 && $uid -lt 65534 ]]; then
    groups=$(groups "$user" 2>/dev/null | sed "s/^${user} : //")
    if sudo -l -U "$user" 2>/dev/null | grep -q "may run"; then
      sudo_status="yes"
    else
      sudo_status="no"
    fi
    printf "%-20s %-40s %s\n" "$user" "$groups" "$sudo_status"
  fi
done < /etc/passwd

echo ""
echo "상세 sudo 규칙은: sudo visudo / sudo cat /etc/sudoers.d/"
