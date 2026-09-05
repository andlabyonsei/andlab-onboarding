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
