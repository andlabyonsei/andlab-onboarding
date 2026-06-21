# 유용한 쉘 스크립트

공용 서버 관리·점검에 쓰는 스크립트입니다. 공용서버1, 2에 배포되어 있으며, 이 가이드 저장소에도 동일 내용이 포함되어 있습니다.

스크립트 파일은 저장소 `src/public/scripts/` 디렉토리에 있습니다. 빌드 후 `/scripts/ram_info.sh` 등으로 접근할 수 있습니다.

---

## ram_info.sh

**용도:** 메모리 슬롯별 설치·인식 상태를 한눈에 확인합니다.

```bash
chmod +x ram_info.sh
./ram_info.sh
```

내부적으로 `dmidecode`를 사용합니다. `sudo` 권한이 필요할 수 있습니다.

**출력 해석:**

- `Size: No Module Installed` — 슬롯 비어 있음 또는 인식 실패(불량 RAM 가능)
- `Size: 64 GB` — 64GB 모듈 정상 인식

RAM 1개가 인식되지 않으면 해당 모듈 불량일 수 있으며, 슬롯 자체 문제면 **메인보드 교체**가 필요할 수 있습니다 (보증 기간 확인 필요).

관련 이력: [하드웨어·유지보수](./admin/hardware-maintenance#20260615-공용서버1-ram-불량)

---

## check_accounts_permissions.sh

**용도:** 계정별 그룹·sudo 권한 등을 요약 출력합니다.

```bash
chmod +x check_accounts_permissions.sh
./check_accounts_permissions.sh
```

신규 계정 추가 후 `visudo` 설정이 올바른지 점검할 때 사용합니다.

---

## collect_sysinfo.sh

**용도:** 호스트의 시스템 정보(CPU, RAM, 디스크, GPU, OS 등)를 수집해 파일로 저장합니다.

```bash
chmod +x collect_sysinfo.sh
./collect_sysinfo.sh
```

출력 파일명: `sysinfo_{호스트이름}_{실행날짜}.txt`

하드웨어 변경·장애 대응 시 기록용으로 활용합니다.

---

## server_shutdown.sh

**용도:** 서버 종료 전 안내 메시지 출력 및 `shutdown` 예약을 돕는 래퍼 스크립트입니다.

```bash
chmod +x server_shutdown.sh
sudo ./server_shutdown.sh [UTC_시간]
```

::: danger
반드시 다른 사용자에게 공지한 뒤, 랩장 승인 하에 실행하세요.
:::

---

## server_boot.sh

**용도:** 서버 재가동 후 기본 상태 점검 (디스크, RAM, GPU, Docker)을 순서대로 확인합니다.

```bash
chmod +x server_boot.sh
./server_boot.sh
```

재부팅 직후 Milvus·실험 환경이 정상인지 확인할 때 사용합니다.

---

## 스크립트 다운로드·배포

로컬에서 가이드 저장소를 clone한 경우:

```bash
# 저장소 루트에서
cp src/public/scripts/*.sh ~/
chmod +x ~/*.sh
```

서버에 직접 옮길 때는 `scp`를 사용합니다.

```bash
scp src/public/scripts/ram_info.sh {계정}@{서버}:~/
```

---

## 스크립트 소스

각 스크립트 전문은 저장소 `src/public/scripts/` 디렉토리에서 확인할 수 있습니다.
