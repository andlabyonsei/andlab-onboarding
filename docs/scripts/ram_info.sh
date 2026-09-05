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
