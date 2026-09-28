<template>
  <a-config-provider :theme="themeConfig">
    <div id="app">
      <router-view />
    </div>
  </a-config-provider>
</template>

<script setup lang="ts">
import { computed, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { theme as antdTheme } from 'ant-design-vue'
import { setAppLocale, type AppLocale } from '@/i18n'
import { isDark } from '@/services/theme'

const { t, locale } = useI18n()

const sharedToken = {
  fontFamily:
    "'Outfit Variable', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', system-ui, -apple-system, sans-serif",
  fontSize: 15,
  borderRadius: 12,
  borderRadiusLG: 16,
  borderRadiusSM: 8,
  controlHeight: 40,
  controlHeightLG: 46,
  wireframe: false,
}

// 夜间：与 tokens.css 的暗色变量一致
const darkConfig = {
  algorithm: antdTheme.darkAlgorithm,
  token: {
    ...sharedToken,
    colorPrimary: '#f2603c',
    colorInfo: '#f2603c',
    colorLink: '#ff8562',
    colorLinkHover: '#ffa184',
    colorBgBase: '#0a0f14',
    colorBgContainer: '#101821',
    colorBgElevated: '#16202a',
    colorBgLayout: '#0a0f14',
    colorBorder: 'rgba(226, 238, 248, 0.14)',
    colorBorderSecondary: 'rgba(226, 238, 248, 0.10)',
    colorText: '#e8eff6',
    colorTextSecondary: 'rgba(232, 239, 246, 0.70)',
    colorTextTertiary: 'rgba(232, 239, 246, 0.55)',
    boxShadow: '0 12px 28px rgba(2, 8, 14, 0.34)',
    boxShadowSecondary: '0 28px 64px rgba(2, 8, 14, 0.46)',
  },
  components: {
    Button: { primaryShadow: 'none', defaultShadow: 'none' },
    Select: { optionSelectedBg: '#1d2935', optionActiveBg: '#16202a' },
    Tabs: { itemSelectedColor: '#f2603c', inkBarColor: '#f2603c', itemColor: 'rgba(232, 239, 246, 0.7)' },
    Modal: { contentBg: '#16202a', headerBg: '#16202a' },
    Message: { contentBg: '#16202a' },
    Empty: { colorTextDescription: 'rgba(232, 239, 246, 0.55)' },
  },
}

// 日间：与 tokens.css 的日间变量一致（强调色压深以保证白底上的对比度）
const lightConfig = {
  algorithm: antdTheme.defaultAlgorithm,
  token: {
    ...sharedToken,
    colorPrimary: '#b33512',
    colorInfo: '#b33512',
    colorLink: '#a83110',
    colorLinkHover: '#8f2a0c',
    colorBgBase: '#f5f6f7',
    colorBgContainer: '#ffffff',
    colorBgElevated: '#ffffff',
    colorBgLayout: '#f5f6f7',
    colorBorder: 'rgba(16, 26, 36, 0.16)',
    colorBorderSecondary: 'rgba(16, 26, 36, 0.10)',
    colorText: '#111a22',
    colorTextSecondary: 'rgba(17, 26, 34, 0.68)',
    colorTextTertiary: 'rgba(17, 26, 34, 0.55)',
    boxShadow: '0 2px 4px rgba(16, 26, 36, 0.06), 0 12px 28px rgba(16, 26, 36, 0.08)',
    boxShadowSecondary: '0 2px 4px rgba(16, 26, 36, 0.06), 0 28px 64px rgba(16, 26, 36, 0.12)',
  },
  components: {
    Button: { primaryShadow: 'none', defaultShadow: 'none' },
    Select: { optionSelectedBg: '#eef1f4', optionActiveBg: '#f5f6f7' },
    Tabs: { itemSelectedColor: '#b33512', inkBarColor: '#b33512', itemColor: 'rgba(17, 26, 34, 0.74)' },
    Empty: { colorTextDescription: 'rgba(17, 26, 34, 0.55)' },
  },
}

const themeConfig = computed(() => (isDark.value ? darkConfig : lightConfig))

watch(
  locale,
  (nextLocale) => {
    setAppLocale(nextLocale as AppLocale)
    document.title = t('app.title')
  },
  { immediate: true }
)
</script>
