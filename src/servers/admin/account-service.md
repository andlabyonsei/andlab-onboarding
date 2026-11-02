# 계정·서비스 관리

랩장·서버 관리자가 공용 서버 계정과 서비스(Milvus 등)를 관리할 때 참고하는 내용입니다.

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


## Milvus 운영 경로

- docker-compose: `/mnt/nvme02/home/lurker18/Documents/Milvus/docker-compose.yml`
- Attu: `http://165.132.192.52:8000/#/connect`

[Milvus 벡터 DB](../milvus) 참고
