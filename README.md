# ANDlab 가이드

연세대학교 ANDlab 신입생·연구원을 위한 랩실 가이드 사이트입니다. [VitePress](https://vitepress.dev)로 만들고 Vercel로 배포합니다.

## 로컬 실행

Node.js 20 이상이 필요합니다.

```bash
npm install
npm run dev       # 개발 서버 (http://localhost:5173)
npm run build     # 정적 사이트 빌드 → src/.vitepress/dist
npm run preview   # 빌드 결과 미리보기
```

## 폴더 구조

```
src/
├── index.md              # 홈
├── getting-started/      # 시작하기 (출입, 참고 자료)
├── servers/              # 공용 서버 가이드
│   └── admin/            # 서버 관리 (랩장·관리자)
├── operations/           # 랩실 운영 (프린터, 폐기물, 구매 등)
├── public/               # 그대로 배포되는 정적 파일
│   ├── docs/             # 다운로드용 PDF·HWP
│   ├── images/
│   └── scripts/          # 서버용 쉘·Python 스크립트
└── .vitepress/
    ├── config.mts        # 사이트 설정, 상단 메뉴·사이드바
    └── theme/            # 커스텀 CSS
```

## 문서 추가·수정

- **새 페이지:** 해당 섹션 폴더에 `.md` 파일을 만들고, [`config.mts`](src/.vitepress/config.mts)의 `sidebar`에 등록합니다.
- **다운로드 파일:** `src/public/docs/` 아래에 **영문 파일명**으로 넣고, 원래 이름으로 저장되도록 `download` 속성을 붙여 링크합니다.

  ```html
  <a href="/docs/purchasing/delivery-proof-form.hwp" download="납품증빙서류_양식.hwp">HWP 다운로드</a>
  ```

- **페이지 내 링크:** 한글 제목 앵커도 그대로 쓸 수 있습니다. 예: `[구매 절차](./purchasing#_1-구매-전-확인)`
- 수정 후 `npm run build`로 깨진 링크가 없는지 확인합니다. 존재하지 않는 페이지로의 링크가 있으면 빌드가 실패합니다.

## 배포

`main` 브랜치에 push하면 Vercel이 자동으로 빌드·배포합니다. 설정은 [`vercel.json`](vercel.json)에 있습니다.

> [!WARNING]
> 이 사이트는 **공개**되어 있습니다. 비밀번호·토큰, 개인 연락처, 예산 금액 등 민감한 정보는 페이지나 첨부 파일에 넣지 마세요.
