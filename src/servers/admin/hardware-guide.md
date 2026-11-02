# 하드웨어 작업 가이드

랩장·서버 관리자가 하드웨어 작업 시 참고하는 방법·원칙입니다. 지난 작업 기록은 [하드웨어 작업 이력](./hardware-maintenance)을, 업체 점검·A/S가 필요하면 [업체 연락처](./vendor-contacts)를 참고하세요.

## RAM과 GPU 비례

GPU VRAM이 늘면 **시스템 RAM도 함께 늘려야** 합니다. 대형 모델·Milvus collection 로드 시 RAM 요구량이 급증합니다.


## RAM 점검·불량 판별

관련 이력: [2026.06.15 — 공용서버1 RAM 불량](./hardware-maintenance#_2026-06-15-—-공용서버1-ram-불량)

### 점검 명령어

```bash
sudo dmidecode -t memory | egrep "Locator:|Bank Locator:|Size:"
```

또는 [ram_info.sh](../useful-scripts#ram-info-sh) 실행

### 슬롯 vs RAM 불량

| 증상 | 대응 |
|------|------|
| 특정 모듈만 인식 안 됨 | 해당 RAM 교체 |
| 슬롯 자체 문제 | **메인보드 교체** 필요할 수 있음 |


## SSD 추가 설치 시 마운트

새 SSD를 장착한 뒤 디스크를 확인하고, `/etc/fstab`에 등록해 재부팅 후에도 자동으로 마운트되도록 설정합니다. 공용 서버는 `/mnt/nvme01`, `/mnt/nvme02` … 처럼 **디스크별 마운트 지점**을 사용합니다.

### 1. 새 디스크 확인

```bash
sudo fdisk -l
```

- 출력에서 `Disk /dev/nvme…n1` 항목의 **용량·모델명**으로 새로 장착한 SSD를 찾습니다.
- 기존 디스크는 이미 파티션(`/dev/nvme0n1p1` 등)이 있고, 새 디스크는 파티션이 없는 경우가 많습니다.
- `lsblk -f`로 보면 디스크별 파티션, 파일시스템, **현재 마운트 위치**를 한눈에 확인할 수 있습니다.

::: danger 디스크 확인
디스크 이름을 잘못 고르면 **기존 데이터가 삭제**됩니다. 파티션 생성·포맷 전에 용량과 모델명으로 새 디스크가 맞는지 반드시 두 번 확인하세요.
:::

### 2. 파티션 생성·포맷 (새 디스크인 경우)

```bash
# 예: 새 디스크가 /dev/nvme4n1 인 경우
sudo parted /dev/nvme4n1 --script mklabel gpt mkpart primary ext4 0% 100%
sudo mkfs.ext4 /dev/nvme4n1p1
```

이미 데이터가 있는 디스크를 옮겨 단 경우에는 이 단계를 **건너뜁니다**.

### 3. 마운트 지점 생성

```bash
sudo mkdir -p /mnt/nvme04
```

### 4. `/etc/fstab`에 디스크와 마운트 지점 매칭

디스크 이름(`/dev/nvme4n1p1`)은 장착 순서나 재부팅에 따라 **바뀔 수 있으므로**, fstab에는 고유값인 **UUID**로 등록합니다.

```bash
sudo blkid /dev/nvme4n1p1
# /dev/nvme4n1p1: UUID="1234abcd-..." TYPE="ext4" ...
```

fstab을 수정하기 전에 백업합니다.

```bash
sudo cp /etc/fstab /etc/fstab.bak
sudo vi /etc/fstab
```

파일 맨 아래에 한 줄을 추가합니다.

```
# <디스크 UUID>                            <마운트 지점>  <파일시스템>  <옵션>             <dump> <pass>
UUID=1234abcd-xxxx-xxxx-xxxx-xxxxxxxxxxxx  /mnt/nvme04    ext4          defaults,nofail    0      2
```

| 항목 | 설명 |
|------|------|
| `UUID=…` | `blkid`로 확인한 파티션 UUID |
| 마운트 지점 | 3단계에서 만든 디렉터리 |
| `defaults,nofail` | `nofail`이 있으면 디스크 인식에 실패해도 **부팅이 멈추지 않음** |
| `0 2` | 백업 안 함 / 루트(`1`) 다음 순서로 부팅 시 파일시스템 검사 |

`vi`에서 `i`로 입력 모드, 수정 후 `Esc` → `:wq`로 저장합니다.

### 5. 적용 및 확인

```bash
sudo systemctl daemon-reload
sudo mount -a        # fstab 전체 마운트 — 오류가 없어야 함
df -h | grep nvme    # 새 마운트 지점과 용량 확인
lsblk -f
```

::: warning 재부팅 전 반드시 `mount -a`
fstab에 오타(UUID, 경로 등)가 있으면 재부팅 시 **서버가 부팅되지 않을 수** 있습니다. `sudo mount -a`가 오류 없이 끝나는지 확인한 뒤 재부팅하세요. 문제가 생기면 백업해 둔 `/etc/fstab.bak`으로 되돌립니다.
:::

### 6. 사용 권한 설정 (필요 시)

```bash
sudo chmod 755 /mnt/nvme04
sudo mkdir -p /mnt/nvme04/{계정명}
sudo chown {계정명}:{계정명} /mnt/nvme04/{계정명}
```

새 디스크를 랩원 저장 공간으로 쓰는 경우, [디스크·캐시 관리](../disk-and-cache)의 저장 위치 안내도 함께 갱신하세요.


## GPU별 소비전력 제한

여러 GPU가 동시에 풀로드로 돌면 서버 전력 사용량이 급증해 셧다운으로 이어질 수 있습니다. ([2026.09 전원 셧다운 사례](./notice-archive#공용-서버-전원-공급-차단·셧다운-2026-09)) NVIDIA GPU는 **전력 상한(Power Limit)을 낮추는 방법**이 가장 간단하고 효과적입니다. 아래 명령어의 변경 작업에는 **root 권한**이 필요합니다.

전력 사용량은 [Grafana 전력 모니터링](../resource-usage#grafana-전력-모니터링)에서 함께 확인하세요.

### 1. 현재 상태와 설정 가능 범위 확인

```bash
nvidia-smi --query-gpu=index,name,power.draw,power.limit,power.min_limit,power.max_limit --format=csv
```

### 2. 전력 상한 설정

```bash
# 모든 GPU를 200W로 제한
sudo nvidia-smi -pl 200

# 0번 GPU만 200W로 제한
sudo nvidia-smi -i 0 -pl 200
```

값은 1단계에서 확인한 최소~최대 범위 안에서 지정해야 합니다.

### 3. 클럭 상한 고정

```bash
# 지원 클럭 확인
nvidia-smi -q -d SUPPORTED_CLOCKS

# GPU 코어 클럭을 300~1500MHz로 제한
sudo nvidia-smi -i 0 -lgc 300,1500

# 메모리 클럭 제한(지원 모델만 가능, 값은 위 목록을 참고)
sudo nvidia-smi -i 0 -lmc 405,5001

# 원래대로 복구
sudo nvidia-smi -i 0 -rgc
sudo nvidia-smi -i 0 -rmc
```

### 4. 유휴 전력 낮추기

```bash
# 퍼시스턴스 모드 활성화
sudo systemctl enable --now nvidia-persistenced

# GPU를 점유 중인 프로세스 확인
nvidia-smi
```

GUI 없는 서버에서는 퍼시스턴스 모드를 켜면 드라이버 초기화가 반복되지 않아, 유휴 상태에서 저전력 상태를 유지하기가 더 쉽습니다. 작업이 없는데도 전력 소모가 높다면 GPU를 점유한 채 남아 있는 프로세스가 없는지도 확인해 보세요. ([gpu_users.sh](../useful-scripts#gpu-users-sh)로 GPU별 사용자 확인 가능)

### 5. 재부팅 후에도 유지하기

`nvidia-smi -pl` 설정은 재부팅하면 초기화되므로, 계속 적용하려면 systemd 서비스로 등록하세요. `/etc/systemd/system/gpu-power-limit.service` 파일을 다음 내용으로 만듭니다.

```ini
[Unit]
Description=Set GPU power limit
After=nvidia-persistenced.service

[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-smi -pl 200

[Install]
WantedBy=multi-user.target
```

GPU마다 다른 값을 주려면 `ExecStart=/usr/bin/nvidia-smi -i 0 -pl 200`처럼 GPU 번호를 지정한 줄을 여러 개 넣습니다.

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now gpu-power-limit.service
```

### 적용 시 참고 사항

- **권장 시작값:** 먼저 기본 상한의 70~80% 정도로 낮춰 보세요. 이 구간에서는 성능 저하가 전력 절감 폭보다 작은 경우가 많지만, 워크로드에 따라 다르므로 실제 작업으로 확인해야 합니다.
- **효과 확인:** 아래 명령으로 전력(`pwr`)과 클럭(`mclk`, `pclk`)을 실시간으로 볼 수 있습니다.

  ```bash
  nvidia-smi dmon -s pc
  ```

- **주의할 점:** 클라우드나 가상화 환경에서는 권한이나 GPU 모델의 제약으로 이 설정이 막혀 있을 수 있습니다.
- 전력 상한을 바꿨다면 랩원들에게 공지하고, [하드웨어 작업 이력](./hardware-maintenance)에 날짜와 설정값을 기록해 두세요.

::: details AMD GPU인 경우
```bash
# 현재 전력 확인
rocm-smi --showpower

# 0번 GPU의 전력 상한을 200W로 설정
sudo rocm-smi -d 0 --setpoweroverdrive 200

# 저전력 성능 레벨로 고정(성능이 크게 떨어질 수 있음)
sudo rocm-smi -d 0 --setperflevel low

# 원래대로 복구
sudo rocm-smi -d 0 --setperflevel auto
```
:::
