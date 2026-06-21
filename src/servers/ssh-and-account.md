# SSH 접속 및 계정

공용 서버를 사용하려면 개인 계정과 SSH 접속 설정이 필요합니다.

## 계정 생성

1. **랩장에게 계정 생성을 요청**합니다.
2. 신규 계정은 `/home/{계정명}`에 생성되며, 기본 용량은 **최대 100GB**입니다.
3. 계정 생성 후 랩장이 `sudo visudo` 등을 통해 필요한 권한을 부여합니다.

::: warning
계정 정보(비밀번호, sudo 권한 등)는 랩장에게 직접 문의하세요. 이 가이드에는 보안상 계정 세부 정보를 기록하지 않습니다.
:::

## VPN 연결

교외에서 접속할 때는 먼저 [Yonsei VPN](https://yis.yonsei.ac.kr/ics/service/PolicyApplyInfo.do)을 신청·연결한 뒤 SSH를 사용합니다. ([참고 링크](../getting-started/links))

## SSH Config 설정

로컬 PC의 `~/.ssh/config`에 아래 형식으로 호스트를 추가합니다.

```
Host {호스트명_원하는_이름}
    HostName {서버_IP_주소}
    User {사용자_계정_id}
```

예시:

```
Host andlab-server1
    HostName 165.132.192.xxx
    User myaccount
```

저장 후 아래처럼 접속합니다.

```bash
ssh andlab-server1
```

## VS Code / Cursor Remote SSH

1. **Remote - SSH** 확장을 설치합니다.
2. `Host`에 지정한 이름으로 원격 연결합니다.
3. 연결 후 서버의 파일을 로컬 에디터에서 바로 편집할 수 있습니다.

`Host`, `HostName`, `User`는 위 SSH config와 동일하게 맞춥니다.

## 공용서버2 계정

공용서버1에 작업이 몰리거나 리소스가 부족하면, **공용서버2에도 계정을 생성**해 작업을 분산할 수 있습니다. 랩장에게 서버2 계정 생성을 요청하세요.

## 계정 생성 시 추가할 `.bashrc` 설정

계정이 만들어지면 [디스크·캐시 관리](./disk-and-cache) 페이지의 환경변수를 `~/.bashrc`에 추가합니다. 캐시 경로와 CPU 스레드 제한을 한 번 설정해 두면 이후 계속 적용됩니다.
