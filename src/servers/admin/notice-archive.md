# 공지 메일 아카이브

랩실에 발송되었던 공용 서버 관련 공지 메일을 가이드 형태로 정리했습니다. 정책·배경 이해에 참고하세요.

---

## RAM 및 Milvus OOM (2025.05)

**배경:** 5/31 Milvus 재가동 중 반복 중단. Docker/GPU VRAM이 아닌 **시스템 RAM OOM**이 원인.

**요약:**

- Milvus collection 증가 → 로드에 **약 200GB RAM** 필요
- 다른 사용자 실험으로 RAM 거의 포화 (~100%)
- Milvus safe close, SSH·명령 지연
- 동국님·요한님이 학교 방문 재부팅으로 복구

**협조 요청 (현재도 유효):**

1. `htop`, `free -h`, `glances`, `nvidia-smi`로 주기적 확인
2. GPU 작업도 RAM/CPU 사용 확인
3. 대규모 작업 사전 공유, 종료 후 프로세스 정리
4. 공용서버1 부하 시 **공용서버2** 계정으로 분산
5. [디스크·캐시 관리](../disk-and-cache)의 `.bashrc` 설정 적용

**캐시·가상환경 (민경님 팁 정리):**

```bash
conda create -p /mnt/nvme03/계정명/envs/myenv python=3.10
conda activate /mnt/nvme03/계정명/envs/myenv

export HF_HOME=/mnt/nvme03/계정명/.cache/huggingface
export TORCH_HOME=/mnt/nvme03/계정명/.cache/torch
export PIP_CACHE_DIR=/mnt/nvme03/계정명/.cache/pip

export TOKENIZERS_PARALLELISM=false
export OMP_NUM_THREADS=8
export MKL_NUM_THREADS=8
```

---

## `/home` 용량 관리 공지 (2025 — 루트 파티션 포화)

**배경:** 루트 파티션(`/`) 사용률 거의 100%. 전체 ~1.8TB 중 `/home`만 ~1.5TB 사용.

**루트 100% 시 위험:**

- 로그 기록 불가 → 장애 분석 불가
- 패키지 설치/업데이트 실패
- 가상환경 생성 실패
- 체크포인트·임시파일 저장 실패
- 프로세스 비정상 종료, **부팅 실패** 가능

**조치 요청 (정책으로 계속 적용):**

1. 미사용 conda/venv 삭제, `conda clean --all`
2. 오래된 체크포인트·로그 삭제 (best만 유지)
3. 대용량 데이터는 `/mnt/nvme03` 또는 클라우드로 이동
4. `~/.cache` 정리

**목표:** 루트 파티션 **300~400GB 이상** 여유 확보

---

## 계정별 정리·신규 관리 지침 (2025)

### 1. 계정별 데이터 정리

- `/home` 사용량 **100GB 이하** 권장
- 당시 대상 계정 예: `chlduswns99`, `sunga`, `dongkuk`, `seyeon` (이력 참고용)

### 2. 장기 미사용 계정 삭제 예고

- 예: `/home/dada09`, `/home/aaai`, `/mnt/nvme02/home/dada09`
- 보관 필요 데이터는 사전 백업

### 3. 향후 관리 규칙 (신규)

| 규칙 | 내용 |
|------|------|
| 계정 위치 | `/home`에 생성, 계정당 **최대 100GB** |
| 대용량 데이터 | `/mnt` 하위 |
| 가상환경 | `/mnt/nvme03/{계정명}/envs/` |
| 캐시 | HF_HOME, TORCH_HOME, PIP_CACHE_DIR → `/mnt` |
| 데이터·결과물 | 데이터셋, 체크포인트, Tensorboard/WandB 로그 → `/mnt/nvme03/{계정명}/` |

---

## 랩원 추가 팁 (nvme02 사용 예시)

일부 랩원은 `/mnt/nvme02`를 사용 중입니다. 본인에게 배정된 마운트 경로는 랩장에게 확인하세요. 원칙은 동일합니다: **대용량은 `/home`이 아닌 `/mnt`**.

---

## 관련 가이드

- [디스크·캐시 관리](../disk-and-cache)
- [리소스 사용 가이드](../resource-usage)
- [Milvus 벡터 DB](../milvus)
