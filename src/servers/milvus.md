# Milvus 벡터 DB

랩실에서는 **Milvus**를 벡터 데이터베이스로 운영합니다. 웹 UI인 **Attu**로 collection 상태를 확인·관리할 수 있습니다.

## 자료 다운로드

Milvus 기반 RAG 구축·활용 방법은 아래 매뉴얼을 참조하세요. 사용하는 서버에 맞는 문서를 내려받으면 됩니다.

| 자료 | 다운로드 |
|------|----------|
| Milvus기반 RAG 메뉴얼 (서버1) | <a href="/docs/milvus/milvus-rag-manual-server1.pdf" download="Milvus기반 RAG 메뉴얼_서버1.pdf">PDF 다운로드</a> |
| Milvus기반 RAG 메뉴얼 (서버2) | <a href="/docs/milvus/milvus-rag-manual-server2.pdf" download="Milvus기반 RAG 메뉴얼_서버2.pdf">PDF 다운로드</a> |
| 벡터 DB 구축 예제 (DiskANN) | <a href="/docs/milvus/build_vectordb_milvus_diskann.py" download="Build_VectorDB[Milvus]_DiskANN.py">.py 다운로드</a> |

## 예제 코드: 벡터 DB 구축 (DiskANN)

SentenceTransformer로 문서를 임베딩해 Milvus collection(`DISKANN` 인덱스, `IP` 메트릭)에 저장하고, 검색까지 해 보는 예제입니다. 실행 전 아래 값을 본인 환경에 맞게 수정하세요.

- `token` — 본인 Milvus 계정 (`<username>:<password>`)
- `model_folder`, `data_folder` — 임베딩 모델·데이터셋 경로
- `dataset_name`, `collection_name` — 적재할 데이터셋과 collection 이름

<<< @/public/docs/milvus/build_vectordb_milvus_diskann.py

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
- [공지 아카이브 — Milvus OOM](./admin/notice-archive#ram-및-milvus-oom-2025-05)
