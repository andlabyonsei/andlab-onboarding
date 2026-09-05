# 리소스 사용 가이드

공용 서버는 **모든 랩원이 함께 쓰는 자원**입니다. 본인 작업이 RAM·CPU·GPU에 미치는 영향을 주기적으로 확인하는 습관이 필요합니다.

## 핵심 원칙

1. 작업 **실행 전·후**에 리소스 사용량을 확인합니다.
2. GPU 작업이라고 해도 **CPU/RAM을 많이 쓰는 경우**가 많으니 `nvidia-smi`만 보지 않습니다.
3. 장시간·대규모 작업은 **사전에 랩원에게 공유**합니다.
4. 작업 종료 후 **불필요한 프로세스·세션**을 정리합니다.
5. 공용서버1이 바쁘면 **공용서버2**로 작업을 분산합니다.


## 리소스 확인 명령어

| 명령어 | 확인 내용 |
|--------|-----------|
| `htop` | CPU, RAM, 프로세스 (대화형) |
| `top` | CPU, RAM (기본) |
| `free -h` | 메모리 사용량 요약 |
| `glances` | CPU, RAM, 디스크 등 통합 모니터링 |
| `nvidia-smi` | GPU 사용률, VRAM |
| `nvidia-smi -l 1` | GPU 1초마다 갱신 |

RAM이 거의 100%에 가까우면 OOM(Out of Memory)으로 프로세스가 강제 종료되거나 SSH가 느려질 수 있습니다.


## 실제 사례: Milvus OOM (2025.05)

Milvus 서버 재가동 중 반복적으로 끊기는 문제가 있었습니다. 원인 조사 결과:

- **Docker/GPU VRAM 문제가 아님**
- **시스템 RAM 부족(OOM)** 이 원인
- Milvus collection 수 증가 → 로드에 **약 200GB RAM** 필요
- 동시에 다른 사용자 실험이 RAM을 많이 사용 → **메모리 거의 100%**
- 결과: Milvus safe close 종료, SSH·일반 명령 지연

**교훈:** 벡터 DB collection 로드, 대용량 데이터 로딩, 멀티프로세싱 학습은 예상보다 RAM을 많이 씁니다.

자세한 공지 원문: [공지 메일 아카이브 — RAM·Milvus](./admin/notice-archive#ram-및-milvus-oom-2025-05)


## RAM을 많이 쓰는 작업 예시

- 대용량 데이터셋 전체 로딩 (`DataLoader` workers 많을 때)
- HuggingFace 대형 모델 로드 (GPU에 안 올라가면 RAM 사용)
- Milvus collection 로드
- `multiprocessing` / 높은 `num_workers`
- Jupyter kernel 방치


## 작업 전 체크리스트

```bash
free -h
nvidia-smi
htop   # q로 종료
```

- RAM 여유가 충분한가?
- GPU가 다른 사람에게 점유되어 있지 않은가?
- 비슷한 대규모 작업이 이미 돌고 있지 않은가?


## 작업 후 체크리스트

- 학습 스크립트·Jupyter·tmux 세션이 종료되었는가?
- `htop`에서 본인 프로세스가 남아 있지 않은가?

본인 프로세스 확인:

```bash
ps -u {계정명}
```


## `/home` 용량과 리소스

디스크가 가득 차도 시스템이 불안정해집니다. [디스크·캐시 관리](./disk-and-cache)와 함께 숙지하세요.

- 신규 계정: `/home` **최대 100GB**
- 가상환경·데이터·체크포인트는 `/mnt/nvme03/{계정명}/`
- `~/.bashrc`에 캐시·스레드 설정 필수


## 문제 발생 시

접속 지연, 명령 실행 지연, 서비스 이상이 보이면 **랩장·서버 관리자에게 빠르게 공유**해 주세요.
