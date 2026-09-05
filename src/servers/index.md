# 공용 서버 개요

ANDlab에서는 연구용 **공용 서버 2대**를 운영합니다. GPU 학습, 대규모 실험, Milvus 벡터 DB 등은 이 서버에서 수행합니다.

## 서버 구성 (요약)

| 항목 | 공용서버1 | 공용서버2 |
|------|-----------|-----------|
| 용도 | 주로 실험·Milvus | GPU 추가 장착, 작업 분산 |
| RAM | 16개 슬롯 (64GB 모듈) | 20개 슬롯 (서버1에서 이전 + 신규) |
| GPU | — | 4대 장착 예정 |
| 대용량 저장 | `/mnt/nvme02`, `/mnt/nvme03` | 동일 구조 |

::: info 신규 서버 계획
- 디스크: 1TB + 16TB 구성
- OS: Ubuntu 24.04 LTS (16TB 디스크에 설치 예정)
:::

## 신입생이 꼭 알아야 할 규칙

1. **`/home`은 운영체제 전용** — 계정당 기본 용량 **최대 100GB**. 가상환경·데이터셋·체크포인트는 `/mnt`에 저장합니다.
2. **리소스 확인 습관** — RAM, GPU VRAM, CPU를 주기적으로 확인합니다. ([리소스 사용 가이드](./resource-usage))
3. **서버 분산 사용** — 공용서버1에 작업이 몰리면 공용서버2 계정을 만들어 분산합니다.
4. **대규모 작업 사전 공유** — 장시간 학습·대용량 로딩 전에 랩원에게 알려 주세요.

## 가이드 목차

| 문서 | 내용 |
|------|------|
| [SSH 접속 및 계정](./ssh-and-account) | 계정 생성, SSH config, 에디터 연결 |
| [개발 환경 세팅](./environment-setup) | CUDA, cuDNN, Anaconda, PyTorch |
| [디스크·캐시 관리](./disk-and-cache) | `/mnt` 사용, `.bashrc` 환경변수 |
| [리소스 사용 가이드](./resource-usage) | RAM/GPU 모니터링, 정리 방법 |
| [Milvus 벡터 DB](./milvus) | Attu 접속, Docker 컨테이너 관리 |
| [자주 쓰는 명령어](./common-commands) | 용량 확인, shutdown 등 |
| [유용한 쉘 스크립트](./useful-scripts) | ram_info, sysinfo 등 |

## 관리자용

랩장·서버 관리자는 [하드웨어·유지보수](./admin/hardware-maintenance), [공지 메일 아카이브](./admin/notice-archive)도 참고하세요.
