# 자주 쓰는 명령어

공용 서버에서 자주 쓰는 CLI 명령어를 정리했습니다.

## 계정·디렉토리

### 계정별 home 디렉토리 경로 (UID 1000~65533)

```bash
awk -F: '$3 >= 1000 && $3 < 65534 {printf "%-20s %s\n", $1 ":", $6}' /etc/passwd
```

### `/home` 계정별 용량 (정렬)

```bash
sudo du -sh /home/* | sort -h
```

### 본인 홈 용량

```bash
du -sh ~
du -sh ~/.cache
```

---

## 리소스 모니터링

```bash
htop
top
free -h
glances
nvidia-smi
nvidia-smi -l 1
```

---

## 서버 종료·재부팅

### shutdown 예약 (UTC 기준)

```bash
sudo shutdown -h {UTC_시간}
```

예: `sudo shutdown -h 14:00` (서버 로컬 시간대 확인 필요)

### 예약된 shutdown 확인

```bash
cat /run/systemd/shutdown/scheduled
```

### 예약 취소

```bash
sudo shutdown -c
```

::: danger
`shutdown`, `reboot`는 **관리자·랩장 승인 후** 실행하세요. 다른 사용자 작업에 영향을 줍니다.
:::

편의 스크립트: [유용한 쉘 스크립트 — server_shutdown.sh / server_boot.sh](./useful-scripts)

---

## RAM 하드웨어 확인 (관리자)

슬롯별 RAM 설치·인식 상태:

```bash
sudo dmidecode -t memory | egrep "Locator:|Bank Locator:|Size:"
```

| 출력 | 의미 |
|------|------|
| `Size: No Module Installed` | 미설치 또는 인식 안 됨 |
| `Size: 64 GB` | 정상 설치 (예: 64GB 모듈) |

스크립트 버전: [ram_info.sh](./useful-scripts#ram_infosh)

---

## 권한·시스템 정보 (관리자)

```bash
# sudoers 편집 (권한 할당)
sudo visudo

# 계정별 권한 확인 스크립트
./check_accounts_permissions.sh

# 시스템 정보 수집 → sysinfo_{호스트}_{날짜}.txt
./collect_sysinfo.sh
```

스크립트 설명: [유용한 쉘 스크립트](./useful-scripts)

---

## Docker (Milvus)

```bash
sudo docker ps -a | grep milvus
```

자세한 내용: [Milvus 벡터 DB](./milvus)

---

## conda·캐시 정리

```bash
conda env list
conda clean --all
pip cache purge
```

자세한 내용: [디스크·캐시 관리](./disk-and-cache)
