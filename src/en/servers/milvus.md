# Milvus Vector DB

The lab runs **Milvus** as its vector database. You can check and manage collections in **Attu**, its web UI.

## Downloads

See the manuals below for building and using RAG with Milvus. Download the one for the server you use.

| Material | Download |
|------|----------|
| Milvus-based RAG manual (Server 1) | <a href="/docs/milvus/milvus-rag-manual-server1.pdf" download="Milvus기반 RAG 메뉴얼_서버1.pdf">Download PDF (Korean)</a> |
| Milvus-based RAG manual (Server 2) | <a href="/docs/milvus/milvus-rag-manual-server2.pdf" download="Milvus기반 RAG 메뉴얼_서버2.pdf">Download PDF (Korean)</a> |
| Vector DB build example (DiskANN) | <a href="/docs/milvus/build_vectordb_milvus_diskann.py" download="Build_VectorDB[Milvus]_DiskANN.py">Download .py</a> |

## Example: Building a Vector DB (DiskANN)

This example embeds documents with SentenceTransformer, stores them in a Milvus collection (`DISKANN` index, `IP` metric), and runs a search. Before running it, change the values below for your environment.

- `token` — your Milvus account (`<username>:<password>`)
- `model_folder`, `data_folder` — paths to the embedding model and dataset
- `dataset_name`, `collection_name` — the dataset to load and the collection name

<<< @/public/docs/milvus/build_vectordb_milvus_diskann.py

## Accessing Attu

Open the URL below in your browser (a VPN connection may be required).

```
http://165.132.192.52:8000/#/connect
```

After connecting Attu to the Milvus instance, you can turn collections on/off in the **Status** column.


## Check Docker Container Status

```bash
sudo docker ps -a | grep milvus
```

Shows the IDs and status of the running containers.


## Start / Stop Containers

```bash
# Start
sudo docker compose -f /mnt/nvme02/home/lurker18/Documents/Milvus/docker-compose.yml up -d

# Stop
sudo docker compose -f /mnt/nvme02/home/lurker18/Documents/Milvus/docker-compose.yml down
```

::: warning
Milvus uses **a lot of RAM** (tens of GB up to about 200GB when loading collections). Check the [Resource Usage Guide](./resource-usage) before starting it, and only start it when there is enough free RAM.
:::


## Copy the Config File (milvus.yaml)

To copy the host's config into the container after checking the container ID:

```bash
docker cp milvus.yaml <milvus_container_id>:/milvus/configs/milvus.yaml
```

Replace `<milvus_container_id>` with the ID of the `milvus` container from `docker ps`.


## Usage Notes

1. **More and larger collections mean more RAM.**
2. When Milvus fails to start, the cause is often **RAM OOM**, not Docker — check with `free -h` and `glances`.
3. For notices about server reboots or Milvus downtime, see the [Notice Archive](./admin/notice-archive).
4. Any Milvus work (restarts, config changes) must be **agreed with the person in charge and the lab lead** first.


## Related Documents

- [Resource Usage Guide](./resource-usage) — RAM monitoring
- [Notice Archive — Milvus OOM](./admin/notice-archive#ram-milvus-oom-2025-05)
