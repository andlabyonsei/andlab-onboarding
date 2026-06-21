import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'AND Lab 가이드',
  description: '연세대학교 AND Lab 신입생·연구원을 위한 랩실 가이드',
  lang: 'ko-KR',
  themeConfig: {
    nav: [
      { text: '시작하기', link: '/getting-started/' },
      { text: '공용 서버', link: '/servers/' },
      { text: '랩실 운영', link: '/operations/' },
      { text: '연구·논문', link: '/research/' },
    ],
    sidebar: {
      '/getting-started/': [
        {
          text: '시작하기',
          items: [
            { text: '소개', link: '/getting-started/' },
            { text: '랩실 출입 방법', link: '/getting-started/lab-access' },
            { text: '참고 링크', link: '/getting-started/links' },
          ],
        },
      ],
      '/servers/': [
        {
          text: '공용 서버',
          items: [
            { text: '개요', link: '/servers/' },
            { text: 'SSH 접속 및 계정', link: '/servers/ssh-and-account' },
            { text: '개발 환경 세팅', link: '/servers/environment-setup' },
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
            { text: '하드웨어·유지보수', link: '/servers/admin/hardware-maintenance' },
            { text: '공지 메일 아카이브', link: '/servers/admin/notice-archive' },
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
          ],
        },
      ],
      '/research/': [
        {
          text: '연구·논문',
          items: [
            { text: '개요', link: '/research/' },
            { text: 'KSCI 논문 제출', link: '/research/ksci-submission' },
          ],
        },
      ],
    },
    socialLinks: [],
    footer: {
      message: 'AND Lab 내부 가이드',
      copyright: 'Copyright © AND Lab',
    },
    search: {
      provider: 'local',
    },
  },
})
