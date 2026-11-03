# Accounts & Services

Reference for the lab lead and server admins when managing shared server accounts and services (Milvus, etc.).

## Default `.bashrc` for New Accounts (Admin) {#default-bashrc}

Add the following to every new account by default. Details: [Disk & Cache Management](../disk-and-cache)

```bash
# Cache PATH
export HF_HOME=/mnt/nvme03/home/{username}/.cache/huggingface
export TORCH_HOME=/mnt/nvme03/home/{username}/.cache/torch
export PIP_CACHE_DIR=/mnt/nvme03/home/{username}/.cache/pip

# NUM_THREADS
export TOKENIZERS_PARALLELISM=false
export OMP_NUM_THREADS=8
export MKL_NUM_THREADS=8
```

Granting permissions: `sudo visudo`


## Milvus Paths

- docker-compose: `/mnt/nvme02/home/lurker18/Documents/Milvus/docker-compose.yml`
- Attu: `http://165.132.192.52:8000/#/connect`

See [Milvus Vector DB](../milvus).
