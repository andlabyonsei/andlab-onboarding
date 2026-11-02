# 공용 서버 개요

ANDlab에서는 연구용 **공용 서버 2대**를 운영합니다. GPU 학습, 대규모 실험, Milvus 벡터 DB 등은 이 서버에서 수행합니다.

::: tip 서버 구성·현황
서버별 사양(RAM, GPU, 저장장치)과 현재 사용 현황은 [랩실 공용 시트](https://docs.google.com/spreadsheets/d/1TgqyIqoprkRPuUhh50y0tLeVOOxGXhKenrB_wsMH5Ng/edit?gid=1126439604#gid=1126439604)에서 확인하세요.
:::

## 신입생이 꼭 알아야 할 규칙

1. **`/home`은 운영체제 전용** — 계정당 기본 용량 **최대 100GB**. 가상환경·데이터셋·체크포인트는 `/mnt`에 저장합니다.
2. **리소스 확인 습관** — RAM, GPU VRAM, CPU를 주기적으로 확인합니다. ([리소스 사용 가이드](./resource-usage))
3. **서버 분산 사용** — 공용서버1에 작업이 몰리면 공용서버2 계정을 만들어 분산합니다.
4. **대규모 작업 사전 공유** — 장시간 학습·대용량 로딩 전에 랩원에게 알려 주세요.

## 서버 접속·환경 세팅 매뉴얼

계정 생성, SSH 접속, 에디터 연결, CUDA·cuDNN·Anaconda·PyTorch 설치 등 전체 절차는 아래 매뉴얼에 정리되어 있습니다. 사용하는 서버의 OS 버전에 맞는 문서를 내려받아 따라해 주세요.

| 문서 | 다운로드 |
|------|----------|
| 리눅스 (Ubuntu 22.04) 메뉴얼 v2.2 (서버1) | <a href="/docs/linux-ubuntu-22.04-manual-v2.2.pdf" download="리눅스_(Ubuntu_22.04)_메뉴얼_v2.2.pdf">PDF 다운로드</a> |
| 리눅스 (Ubuntu 24.04) 메뉴얼 v2.3 (서버2) | <a href="/docs/linux-ubuntu-24.04-manual-v2.3.pdf" download="리눅스_(Ubuntu_24.04)_메뉴얼_v2.3.pdf">PDF 다운로드</a> |

## 가이드 목차

| 문서 | 내용 |
|------|------|
| [디스크·캐시 관리](./disk-and-cache) | `/mnt` 사용, `.bashrc` 환경변수 |
| [리소스 사용 가이드](./resource-usage) | RAM/GPU 모니터링, Grafana 전력 모니터링, 정리 방법 |
| [Milvus 벡터 DB](./milvus) | Attu 접속, Docker 컨테이너 관리 |
| [자주 쓰는 명령어](./common-commands) | 용량 확인, shutdown 등 |
| [유용한 쉘 스크립트](./useful-scripts) | ram_info, sysinfo 등 |

## 관리자용

랩장·서버 관리자는 [하드웨어 작업 이력](./admin/hardware-maintenance), [하드웨어 작업 가이드](./admin/hardware-guide), [계정·서비스 관리](./admin/account-service), [공지 아카이브](./admin/notice-archive)도 참고하세요.
