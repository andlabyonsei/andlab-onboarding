# 하드웨어·유지보수

랩장·서버 관리자를 위한 하드웨어 이슈·유지보수 기록입니다.

## RAM과 GPU 비례

GPU VRAM이 늘면 **시스템 RAM도 함께 늘려야** 합니다. 대형 모델·Milvus collection 로드 시 RAM 요구량이 급증합니다.

---

## 2026.06.15 — 공용서버1 RAM 불량

### 상황

- 주문한 RAM 16개가 설치되어 있었으나 **1개가 인식되지 않음**
- xdnode 엔지니어 방문 점검 → **RAM 1개 불량** 확인, 무상 보상·교체
- 교체 후 정상 인식

### 점검 명령어

```bash
sudo dmidecode -t memory | egrep "Locator:|Bank Locator:|Size:"
```

또는 [ram_info.sh](../useful-scripts#ram_infosh) 실행

### 슬롯 vs RAM 불량

| 증상 | 대응 |
|------|------|
| 특정 모듈만 인식 안 됨 | 해당 RAM 교체 |
| 슬롯 자체 문제 | **메인보드 교체** 필요할 수 있음 |

공용서버1 메인보드 A/S 보증은 보통 3년이며, 당시 **2년 경과** 상태였습니다. 메인보드 이슈는 **최대한 빠르게** 대응해야 합니다.

---

## 2026.05.24 — RAM 재배치·증설

### 작업 내용

| 서버 | 변경 |
|------|------|
| 공용서버1 | 기존 RAM 16개 → 서버2로 이동. 신규 SK하이닉스 RAM 15개 중 12개 장착 (+ 추후 4개 추가 예정) |
| 공용서버2 | 서버1에서 온 16개 + 기존 4개 = **총 20개**. GPU 1대 추가로 **총 4대** 예정 |

### 예산·서류

- 배정 예산 내 구매 부품은 **제조사가 달라도** 구매 직후·설치 후·정상 작동 확인 **사진** 필요
- 구매 → 설치 → 동작 확인 3단계 문서화

---

## 신규 서버 스펙 (계획)

| 항목 | 내용 |
|------|------|
| 디스크 | 1TB + 16TB |
| OS 설치 디스크 | 16TB |
| OS | Ubuntu 24.04 LTS |

---

## 계정 생성 시 기본 `.bashrc` (관리자)

신규 계정에 아래를 기본 추가합니다. 상세: [디스크·캐시 관리](../disk-and-cache)

```bash
# Cache PATH
export HF_HOME=/mnt/nvme03/home/{계정명}/.cache/huggingface
export TORCH_HOME=/mnt/nvme03/home/{계정명}/.cache/torch
export PIP_CACHE_DIR=/mnt/nvme03/home/{계정명}/.cache/pip

# NUM_THREADS
export TOKENIZERS_PARALLELISM=false
export OMP_NUM_THREADS=8
export MKL_NUM_THREADS=8
```

권한 할당: `sudo visudo`

---

## Milvus 운영 경로

- docker-compose: `/mnt/nvme02/home/lurker18/Documents/Milvus/docker-compose.yml`
- Attu: `http://165.132.192.52:8000/#/connect`

[Milvus 벡터 DB](../milvus) 참고

---

## 향후 TODO

- [ ] 서버 종료/구동 명령을 스크립트로 정리·공유 → [useful-scripts](../useful-scripts)에 반영됨
- [ ] ram_info.sh 공용서버1·2 배포 유지
