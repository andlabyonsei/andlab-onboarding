from huggingface_hub import snapshot_download

DATASETS_ROOT = "/mnt/nvme03/huggingface/datasets"
DATASET_IDS = [
    # "HuggingFaceFV/finevideo",
]

for repo_id in DATASET_IDS:
    local_dir = f"{DATASETS_ROOT}/{repo_id}"
    local_path = snapshot_download(
        repo_id=repo_id,
        repo_type="dataset",
        local_dir=local_dir,
        allow_patterns=["*.parquet"],
    )
    print(f"Dataset snapshot downloaded to: {local_path}")
