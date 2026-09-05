#!/usr/bin/env bash

set -u
export LC_ALL=C

TIMESTAMP=$(date +%F_%H%M%S)
OUTPUT_CSV="disk_usage_report_${TIMESTAMP}.csv"

# 조회할 개별 경로 목록
paths=(
    "/mnt/nvme01/etc/finetuned-model_0326_again/"
    "/mnt/nvme02/User/utopiamath/"
    "/mnt/nvme02/home"
    "/mnt/nvme02/home/acl"
    "/mnt/nvme02/home/dada09"
    "/mnt/nvme02/home/lurker"
    "/mnt/nvme02/home/lurker18/"
    "/mnt/nvme02/home/minky/"
    "/mnt/nvme02/home/tdrag/"
    "/mnt/nvme02/home/yeonjun_mark2/"
    "/mnt/nvme03/home/"
    "/mnt/nvme03/home/seyeonjun_/"
    "/mnt/nvme03/home/sjk/"
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
