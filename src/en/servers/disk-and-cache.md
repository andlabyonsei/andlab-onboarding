# Disk & Cache Management

The `/home` partition on the shared servers needs free space for the OS, logs, and package updates. **Always store large files under `/mnt`.**

## Why Use `/mnt`?

- All of `/home` lives on the same disk as the root partition (`/`), and each account is limited to **100GB by default**.
- When the root partition fills up, logs can't be written, package installs fail, checkpoints fail to save during training, and in the worst case **the server fails to boot**.
- Real case: `/home` alone used about 1.5TB → free space on the 1.8TB disk was exhausted ([Notice Archive](./admin/notice-archive))

**Goal:** Keep **at least 300–400GB (about 20%)** free on the root partition.


## Shared Model & Dataset Storage (Shared Server 1)

On Shared Server 1, models and datasets downloaded from HuggingFace and elsewhere are kept in shared paths. **First check whether the model or dataset you need already exists.** If it does, use it from this path instead of downloading a duplicate to your personal directory.

| Path | Contents |
|------|------|
| `/mnt/nvme01/huggingface/models` | Models downloaded from HuggingFace |
| `/mnt/nvme03/huggingface/datasets` | Datasets downloaded from HuggingFace, etc. |

```bash
ls /mnt/nvme01/huggingface/models
ls /mnt/nvme03/huggingface/datasets
```

To add new ones, download them to the paths above with the [download_hf_model.py](./useful-scripts#download-hf-model-py) / [download_hf_dataset.py](./useful-scripts#download-hf-dataset-py) scripts.


## Where to Store Things (Example)

| Item | Location | Why not in `/home` |
|------|-----------|---------------------------|
| conda environments | `/mnt/nvme04/{username}/envs/` | Several GB to tens of GB per environment |
| HuggingFace cache | `/mnt/nvme04/{username}/.cache/huggingface` | Model downloads of several GB to hundreds of GB |
| PyTorch cache | `/mnt/nvme04/{username}/.cache/torch` | Pretrained weights |
| pip cache | `/mnt/nvme04/{username}/.cache/pip` | Accumulated package wheels |
| Checkpoints (.pt, .ckpt) | `/mnt/nvme04/{username}/checkpoints/` | Several GB per training run |
| Experiment logs (Tensorboard, WandB) | `/mnt/nvme04/{username}/logs/` | Accumulate over time |

Some members use `/mnt/nvme02/home/{username}` instead — ask the lab lead which path is assigned to you.


## Create Virtual Environments Under `/mnt`

```bash
conda create -p /mnt/nvme04/{username}/envs/{env_name} python=3.10
conda activate /mnt/nvme04/{username}/envs/{env_name}
```


## Change Cache Paths (`~/.bashrc`)

Add the following to `~/.bashrc`, replacing `{username}` with your ID.

```bash
# Cache PATH
export HF_HOME=/mnt/nvme04/{username}/.cache/huggingface
export TORCH_HOME=/mnt/nvme04/{username}/.cache/torch
export PIP_CACHE_DIR=/mnt/nvme04/{username}/.cache/pip

# NUM_THREADS — prevent hogging CPU threads
export TOKENIZERS_PARALLELISM=false
export OMP_NUM_THREADS=8
export MKL_NUM_THREADS=8
```

Apply:

```bash
source ~/.bashrc
```

To add lines one at a time:

```bash
echo 'export TOKENIZERS_PARALLELISM=false' >> ~/.bashrc
echo 'export OMP_NUM_THREADS=8' >> ~/.bashrc
echo 'export MKL_NUM_THREADS=8' >> ~/.bashrc
source ~/.bashrc
```

::: tip
Limiting threads keeps the whole server stable, and often speeds up your own experiments too.
:::


## Check Disk Usage

Your own `/home` usage:

```bash
du -sh ~
du -sh ~/.cache
```

Usage of every account in `/home` (admins, or to check your own):

```bash
sudo du -sh /home/* | sort -h
```


## Cleanup

### 1. Remove unused virtual environments

```bash
conda env list
conda remove -p /mnt/nvme04/{username}/envs/{env_name} --all
```

### 2. Clear conda and pip caches

```bash
conda clean --all
pip cache purge
```

### 3. Old checkpoints and logs

- After training, keep **only the best model** and delete `.pt` / `.ckpt` files from earlier epochs
- Delete unneeded Tensorboard and text logs

### 4. Delete `.cache` left in `/home`

After moving your cache paths to `/mnt`, you can delete the old contents of `~/.cache` (back up anything you need first).


## When Creating New Accounts (Admin)

Add the **Cache PATH** and **NUM_THREADS** blocks above to every new account's `.bashrc` by default. ([Accounts & Services](./admin/account-service#default-bashrc))
