# 디스크·캐시 관리

공용 서버의 `/home` 파티션은 OS와 로그·패키지 업데이트용 여유 공간이 필요합니다. **대용량 파일은 반드시 `/mnt` 하위에 저장**해야 합니다.

## 왜 `/mnt`를 써야 하나요?

- `/home` 전체가 루트 파티션(`/`)과 같은 디스크에 있으며, **계정당 기본 100GB** 제한이 있습니다.
- 루트 파티션이 가득 차면 로그 기록 불가, 패키지 설치 실패, 학습 중 체크포인트 저장 실패, 심하면 **부팅 실패**까지 발생할 수 있습니다.
- 실제 사례: `/home`만 약 1.5TB 사용 → 전체 1.8TB 중 여유 공간 소진 ([공지 아카이브](./admin/notice-archive))

**목표:** 루트 파티션에 **최소 300~400GB(약 20%)** 여유 공간 유지

---

## 저장 위치 규칙

| 항목 | 저장 위치 | `/home`에 두면 안 되는 이유 |
|------|-----------|---------------------------|
| conda 가상환경 | `/mnt/nvme03/{계정명}/envs/` | 환경 하나에 수 GB~수십 GB |
| HuggingFace 캐시 | `/mnt/nvme03/{계정명}/.cache/huggingface` | 모델 다운로드 수 GB~수백 GB |
| PyTorch 캐시 | `/mnt/nvme03/{계정명}/.cache/torch` | 사전학습 가중치 |
| pip 캐시 | `/mnt/nvme03/{계정명}/.cache/pip` | 패키지 wheel 누적 |
| 데이터셋 | `/mnt/nvme03/{계정명}/datasets/` | 대용량 |
| 체크포인트 (.pt, .ckpt) | `/mnt/nvme03/{계정명}/checkpoints/` | 학습마다 수 GB |
| 실험 로그 (Tensorboard, WandB) | `/mnt/nvme03/{계정명}/logs/` | 장기 누적 |

`/mnt/nvme02/home/{계정명}` 경로를 쓰는 경우도 있으니, 랩장에게 본인에게 배정된 경로를 확인하세요.

---

## 가상환경을 `/mnt`에 생성

```bash
conda create -p /mnt/nvme03/{계정명}/envs/{가상환경명} python=3.10
conda activate /mnt/nvme03/{계정명}/envs/{가상환경명}
```

---

## 캐시 경로 변경 (`~/.bashrc`)

아래 내용을 `~/.bashrc`에 추가합니다. `{계정명}`을 본인 ID로 바꿉니다.

```bash
# Cache PATH
export HF_HOME=/mnt/nvme03/{계정명}/.cache/huggingface
export TORCH_HOME=/mnt/nvme03/{계정명}/.cache/torch
export PIP_CACHE_DIR=/mnt/nvme03/{계정명}/.cache/pip

# NUM_THREADS — CPU 스레드 과다 점유 방지
export TOKENIZERS_PARALLELISM=false
export OMP_NUM_THREADS=8
export MKL_NUM_THREADS=8
```

적용:

```bash
source ~/.bashrc
```

한 줄씩 추가하려면:

```bash
echo 'export TOKENIZERS_PARALLELISM=false' >> ~/.bashrc
echo 'export OMP_NUM_THREADS=8' >> ~/.bashrc
echo 'export MKL_NUM_THREADS=8' >> ~/.bashrc
source ~/.bashrc
```

::: tip
스레드 제한은 서버 전체 안정성뿐 아니라, 개인 실험 속도에도 도움이 되는 경우가 많습니다.
:::

---

## 용량 확인

본인 `/home` 사용량:

```bash
du -sh ~
du -sh ~/.cache
```

전체 `/home` 계정별 용량 (관리자 또는 본인 확인):

```bash
sudo du -sh /home/* | sort -h
```

---

## 정리 방법

### 1. 사용하지 않는 가상환경 삭제

```bash
conda env list
conda remove -p /mnt/nvme03/{계정명}/envs/사용안하는환경 --all
```

### 2. conda·pip 캐시 정리

```bash
conda clean --all
pip cache purge
```

### 3. 오래된 체크포인트·로그

- 학습 종료 후 **best 모델만** 남기고 이전 epoch `.pt`, `.ckpt` 삭제
- 불필요한 Tensorboard·텍스트 로그 삭제

### 4. `/home`에 쌓인 `.cache` 삭제

캐시 경로를 `/mnt`로 옮긴 뒤, 기존 `~/.cache` 내용은 삭제해도 됩니다 (필요한 파일 백업 후).

---

## 신규 계정 생성 시 (관리자)

새 계정 `.bashrc`에 위 **Cache PATH**와 **NUM_THREADS** 블록을 기본으로 넣어 주세요. ([공용서버관리 메모](./admin/hardware-maintenance))
