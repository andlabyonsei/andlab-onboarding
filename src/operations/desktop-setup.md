# 데스크톱 Windows 설치

랩실에 새 데스크톱이 들어오면 Ventoy USB로 Windows 11을 설치합니다. BIOS 설정부터 초기 설정까지 실제 설치 화면으로 정리한 가이드를 내려받아 따라해 주세요.

| 문서 | 다운로드 |
|------|----------|
| Ventoy USB로 Windows 11 설치하기 | <a href="/docs/ventoy-windows11-install-guide.pdf" download="Ventoy Windows 설치 가이드.pdf">PDF 다운로드</a> |

## 준비물

1. **Ventoy USB** — Ventoy2Disk로 USB에 Ventoy를 설치합니다 (USB의 기존 데이터는 지워짐).
2. **Windows ISO** — ISO 파일을 Ventoy 파티션에 복사합니다. 별도 굽기 작업은 필요 없습니다.
3. **백업** — 설치할 디스크의 자료를 백업하고, 라이선스 방식과 설치 권한을 확인합니다.

## 설치 흐름

| 단계 | 내용 |
|------|------|
| BIOS 설정 | 부팅 직후 `Del` 키로 진입 (기가바이트 보드 기준) → Boot 탭에서 **Secure Boot 끄기** → Save & Exit |
| Ventoy 부팅 | ISO 목록에서 설치할 Windows ISO 선택 → **Boot in normal mode** (안 되면 wimboot mode) |
| Windows 설치 | 설치 옵션·제품 키·에디션 선택 → 내부 디스크에 파티션 생성 후 **가장 큰 주 파티션**에 설치 |
| 초기 설정 | 인터넷 없이 진행하려면 네트워크 화면에서 `Shift + F10` → `oobe\bypassnro` 입력 → 재시작 후 **인터넷에 연결되어 있지 않음** 선택 |
| 개인 정보 설정 | 위치·내 장치 찾기·진단 데이터 등은 필요에 따라 선택 |

::: warning 디스크 선택 주의
파티션 화면의 디스크 번호는 PC마다 다릅니다. **Ventoy USB 디스크를 선택하지 않도록** 용량과 이름을 확인하세요.
:::

## 설치 후 확인

- Ventoy USB 제거
- 랜·GPU 드라이버 설치, Windows 업데이트
- 인터넷 연결 후 정품 인증 상태 확인
- 필요하면 BIOS에서 Secure Boot를 다시 켜고 부팅 확인
