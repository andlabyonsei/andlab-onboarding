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
