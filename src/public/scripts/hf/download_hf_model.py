from huggingface_hub import snapshot_download

MODELS_ROOT = "/mnt/nvme01/huggingface/models"
MODEL_IDS = [
    # "ahmed-masry/chartgemma",
    # "ahmed-masry/ChartInstruct-LLama2",
    # "mPLUG/TinyChart-3B-768",
    # "mPLUG/TinyChart-3B-768-siglip",  # TinyChart vision tower
    # "llava-hf/llava-1.5-7b-hf",
    # "HuggingFaceM4/idefics2-8b",
    # "allenai/Molmo-7B-D-0924",
]

for repo_id in MODEL_IDS:
    local_dir = f"{MODELS_ROOT}/{repo_id}"
    local_path = snapshot_download(
        repo_id=repo_id,
        repo_type="model",
        local_dir=local_dir,
    )
    print(f"Model snapshot downloaded to: {local_path}")
