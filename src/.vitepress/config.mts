import { defineConfig, type DefaultTheme } from 'vitepress'
import taskLists from 'markdown-it-task-lists'

// VitePress 기본 slugify와 동일하되, NFKD로 분해된 한글을 NFC로 다시 합친다.
// (기본값은 한글 앵커를 자모 단위로 분해해 `[링크](./page#한글-제목)`가 동작하지 않음)
const rControl = /[\u0000-\u001f]/g
const rSpecial = /[\s~`!@#$%^&*()\-_+=[\]{}|\\;:"'“”‘’<>,.?/]+/g
const rCombining = /[̀-ͯ]/g
const slugify = (str: string) =>
  str
    .normalize('NFKD')
    .replace(rCombining, '')
    .replace(rControl, '')
    .replace(rSpecial, '-')
    .replace(/-{2,}/g, '-')
    .replace(/^-+|-+$/g, '')
    .replace(/^(\d)/, '_$1')
    .toLowerCase()
    .normalize('NFC')

// 한국어(기본, `/`) — 영어 페이지는 `src/en/` 아래 같은 경로에 둔다.
const koThemeConfig: DefaultTheme.Config = {
  nav: [
    { text: '시작하기', link: '/getting-started/' },
    { text: '공용 서버', link: '/servers/' },
    { text: '랩실 운영', link: '/operations/' },
  ],
  sidebar: {
    '/getting-started/': [
      {
        text: '시작하기',
        items: [
          { text: '소개', link: '/getting-started/' },
          { text: '랩실 출입 방법', link: '/getting-started/lab-access' },
          { text: '참고 자료', link: '/getting-started/links' },
        ],
      },
    ],
    '/servers/': [
      {
        text: '공용 서버',
        items: [
          { text: '개요', link: '/servers/' },
          { text: '디스크·캐시 관리', link: '/servers/disk-and-cache' },
          { text: '리소스 사용 가이드', link: '/servers/resource-usage' },
          { text: 'Milvus 벡터 DB', link: '/servers/milvus' },
          { text: '자주 쓰는 명령어', link: '/servers/common-commands' },
          { text: '유용한 쉘 스크립트', link: '/servers/useful-scripts' },
        ],
      },
      {
        text: '서버 관리 (랩장·관리자)',
        collapsed: true,
        items: [
          { text: '하드웨어 작업 이력', link: '/servers/admin/hardware-maintenance' },
          { text: '하드웨어 작업 가이드', link: '/servers/admin/hardware-guide' },
          { text: '계정·서비스 관리', link: '/servers/admin/account-service' },
          { text: '공지 아카이브', link: '/servers/admin/notice-archive' },
          { text: '업체 연락처', link: '/servers/admin/vendor-contacts' },
        ],
      },
    ],
    '/operations/': [
      {
        text: '랩실 운영',
        items: [
          { text: '개요', link: '/operations/' },
          { text: '웹마스터 업무', link: '/operations/webmaster' },
          { text: '프린터 설정', link: '/operations/printers' },
          { text: '폐기물 처리', link: '/operations/waste-disposal' },
          { text: '데스크톱 Windows 설치', link: '/operations/desktop-setup' },
          { text: '연구간접비 물품 구매', link: '/operations/purchasing' },
        ],
      },
    ],
  },
  footer: {
    message: 'ANDlab 내부 가이드',
    copyright: 'Copyright © ANDlab',
  },
}

const enThemeConfig: DefaultTheme.Config = {
  nav: [
    { text: 'Getting Started', link: '/en/getting-started/' },
    { text: 'Shared Servers', link: '/en/servers/' },
    { text: 'Lab Operations', link: '/en/operations/' },
  ],
  sidebar: {
    '/en/getting-started/': [
      {
        text: 'Getting Started',
        items: [
          { text: 'Introduction', link: '/en/getting-started/' },
          { text: 'Lab Door Access', link: '/en/getting-started/lab-access' },
          { text: 'Resources', link: '/en/getting-started/links' },
        ],
      },
    ],
    '/en/servers/': [
      {
        text: 'Shared Servers',
        items: [
          { text: 'Overview', link: '/en/servers/' },
          { text: 'Disk & Cache Management', link: '/en/servers/disk-and-cache' },
          { text: 'Resource Usage Guide', link: '/en/servers/resource-usage' },
          { text: 'Milvus Vector DB', link: '/en/servers/milvus' },
          { text: 'Common Commands', link: '/en/servers/common-commands' },
          { text: 'Useful Shell Scripts', link: '/en/servers/useful-scripts' },
        ],
      },
      {
        text: 'Server Admin (Lab Lead & Admins)',
        collapsed: true,
        items: [
          { text: 'Hardware Work Log', link: '/en/servers/admin/hardware-maintenance' },
          { text: 'Hardware Work Guide', link: '/en/servers/admin/hardware-guide' },
          { text: 'Accounts & Services', link: '/en/servers/admin/account-service' },
          { text: 'Notice Archive', link: '/en/servers/admin/notice-archive' },
          { text: 'Vendor Contacts', link: '/en/servers/admin/vendor-contacts' },
        ],
      },
    ],
    '/en/operations/': [
      {
        text: 'Lab Operations',
        items: [
          { text: 'Overview', link: '/en/operations/' },
          { text: 'Webmaster Duties', link: '/en/operations/webmaster' },
          { text: 'Printer Setup', link: '/en/operations/printers' },
          { text: 'Waste Disposal', link: '/en/operations/waste-disposal' },
          { text: 'Desktop Windows Install', link: '/en/operations/desktop-setup' },
          { text: 'Purchasing (Indirect Costs)', link: '/en/operations/purchasing' },
        ],
      },
    ],
  },
  footer: {
    message: 'ANDlab Internal Guide',
    copyright: 'Copyright © ANDlab',
  },
}

export default defineConfig({
  head: [['link', { rel: 'icon', type: 'image/png', href: '/logo.png' }]],
  markdown: {
    anchor: { slugify },
    config(md) {
      md.use(taskLists, { enabled: true, label: true })
    },
  },
  locales: {
    root: {
      label: '한국어',
      lang: 'ko-KR',
      title: 'ANDlab 가이드',
      description: '연세대학교 ANDlab 신입생·연구원을 위한 랩실 가이드',
      themeConfig: koThemeConfig,
    },
    en: {
      label: 'English',
      lang: 'en-US',
      title: 'ANDlab Guide',
      description: 'Lab guide for new students and researchers at ANDlab, Yonsei University',
      themeConfig: enThemeConfig,
    },
  },
  themeConfig: {
    logo: '/logo.png',
    socialLinks: [
      { icon: 'github', link: 'https://github.com/andlabyonsei/andlab-onboarding' },
    ],
    search: {
      provider: 'local',
    },
  },
})
