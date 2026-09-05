# Milvus 벡터 DB

랩실에서는 **Milvus**를 벡터 데이터베이스로 운영합니다. 웹 UI인 **Attu**로 collection 상태를 확인·관리할 수 있습니다.

::: tip 자세한 가이드
Milvus 기반 RAG 구축·활용 방법은 <a href="/docs/milvus-rag-manual.pdf" target="_blank" rel="noopener noreferrer">Milvus기반 RAG 메뉴얼</a> PDF를 참조하세요. 링크를 누르면 새 창에서 열립니다.
:::

## Attu 접속

브라우저에서 아래 주소로 접속합니다 (VPN 연결 필요할 수 있음).

```
http://165.132.192.52:8000/#/connect
```

Attu에서 Milvus 인스턴스에 연결한 뒤, **Status** 컬럼에서 collection을 on/off 할 수 있습니다.


## Docker 컨테이너 상태 확인

```bash
sudo docker ps -a | grep milvus
```

실행 중인 컨테이너 ID와 상태를 확인합니다.


## 컨테이너 시작 / 종료

```bash
# 시작
sudo docker compose -f /mnt/nvme02/home/lurker18/Documents/Milvus/docker-compose.yml up -d

# 종료
sudo docker compose -f /mnt/nvme02/home/lurker18/Documents/Milvus/docker-compose.yml down
```

::: warning
Milvus는 **대량의 RAM**을 사용합니다 (collection 로드 시 수십~200GB 수준). 가동 전 [리소스 사용 가이드](./resource-usage)를 확인하고, RAM 여유가 충분할 때만 기동하세요.
:::


## 설정 파일 복사 (milvus.yaml)

컨테이너 ID를 확인한 뒤 호스트의 설정을 컨테이너에 복사할 때:

```bash
docker cp milvus.yaml <milvus_container_id>:/milvus/configs/milvus.yaml
```

`<milvus_container_id>`는 `docker ps`에서 `milvus` 관련 컨테이너 ID로 바꿉니다.


## 사용 시 주의사항

1. **collection 수·크기가 늘면 RAM 요구량도 증가**합니다.
2. Milvus 기동 실패 시 Docker 문제가 아니라 **RAM OOM**인 경우가 많습니다 — `free -h`, `glances`로 확인하세요.
3. 서버 재부팅·Milvus 중단 공지가 있으면 [공지 아카이브](./admin/notice-archive)를 참고하세요.
4. Milvus 관련 작업(재시작, 설정 변경)은 **담당자·랩장과 협의** 후 진행합니다.


## 관련 문서

- [리소스 사용 가이드](./resource-usage) — RAM 모니터링
- [공지 메일 아카이브 — Milvus OOM](./admin/notice-archive#ram-및-milvus-oom-2025-05)
