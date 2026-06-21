# 개발 환경 세팅

공용 서버에서 딥러닝·NLP 실험을 하려면 CUDA, Python 가상환경, PyTorch 등을 설정해야 합니다.

## 전체 순서

1. 계정 생성 및 SSH 접속 ([SSH 접속 및 계정](./ssh-and-account))
2. CUDA 환경변수 설정
3. cuDNN 버전 확인
4. Anaconda로 가상환경 생성
5. CUDA용 PyTorch 설치
6. [디스크·캐시 관리](./disk-and-cache) 설정

---

## 1. CUDA 환경변수

서버에 설치된 CUDA **12.8**을 기본으로 사용합니다. `~/.bashrc`에 아래를 추가합니다.

```bash
echo 'export PATH=/usr/local/cuda-12.8/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

적용 확인:

```bash
nvcc --version
```

---

## 2. cuDNN 확인

```bash
cat /usr/local/cuda-12.8/include/cudnn_version.h | grep CUDNN_MAJOR -A 2
```

출력에서 `CUDNN_MAJOR`, `CUDNN_MINOR` 버전을 확인합니다. PyTorch 설치 시 이 CUDA/cuDNN 버전과 맞는 빌드를 선택하세요.

---

## 3. Anaconda 설치

서버에 Anaconda가 없거나 개인 환경이 필요하면 [Linux Anaconda 설치 가이드](https://www.anaconda.com/docs/getting-started/anaconda/install/linux-install#wget)를 참고합니다.

::: warning
가상환경은 `/home`이 아닌 **`/mnt/nvme03/{계정명}/envs/`** 에 생성하세요. ([디스크·캐시 관리](./disk-and-cache))
:::

---

## 4. 가상환경 생성

Python **3.11.10** 예시:

```bash
conda create -p /mnt/nvme03/{계정명}/envs/myenv python=3.11.10
conda activate /mnt/nvme03/{계정명}/envs/myenv
```

`{계정명}`을 본인 계정 ID로 바꿉니다.

---

## 5. PyTorch (CUDA) 설치

[CUDA 전용 PyTorch 다운로드 페이지](https://pytorch.org/get-started/locally/)에서 OS, CUDA 버전(12.8), 패키지 관리자(conda/pip)를 선택해 표시되는 설치 명령을 복사합니다.

예시 (버전은 사이트 안내에 맞게 변경):

```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
```

설치 후 GPU 인식 확인:

```bash
python -c "import torch; print(torch.cuda.is_available()); print(torch.cuda.get_device_name(0))"
```

---

## 6. 에디터 원격 연결

[SSH 접속 및 계정](./ssh-and-account)에서 설정한 `Host`로 VS Code/Cursor Remote SSH에 연결하면, 서버에서 바로 코드를 실행·디버깅할 수 있습니다.

---

## 체크리스트

- [ ] `nvcc --version`으로 CUDA 12.8 인식
- [ ] cuDNN 버전 확인
- [ ] 가상환경을 `/mnt/nvme03/{계정명}/envs/`에 생성
- [ ] PyTorch `torch.cuda.is_available()` == True
- [ ] `.bashrc`에 캐시·스레드 환경변수 추가 ([디스크·캐시 관리](./disk-and-cache))
