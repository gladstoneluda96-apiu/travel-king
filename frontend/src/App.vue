<template>
  <a-config-provider :theme="themeConfig">
    <div id="app">
      <router-view />
    </div>
  </a-config-provider>
</template>

<script setup lang="ts">
import { watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { theme } from 'ant-design-vue'
import { setAppLocale, type AppLocale } from '@/i18n'

const { t, locale } = useI18n()

// Ant Design Vue 跟随暗色令牌，界面里不再出现浅色组件
const themeConfig = {
  algorithm: theme.darkAlgorithm,
  token: {
    colorPrimary: '#f2603c',
    colorInfo: '#f2603c',
    colorBgBase: '#0a0f14',
    colorBgContainer: '#101821',
    colorBgElevated: '#16202a',
    colorBgLayout: '#0a0f14',
    colorBorder: 'rgba(226, 238, 248, 0.14)',
    colorBorderSecondary: 'rgba(226, 238, 248, 0.10)',
    colorText: '#e8eff6',
    colorTextSecondary: 'rgba(232, 239, 246, 0.70)',
    colorTextTertiary: 'rgba(232, 239, 246, 0.46)',
    fontFamily:
      "'Outfit Variable', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', system-ui, -apple-system, sans-serif",
    fontSize: 15,
    borderRadius: 12,
    borderRadiusLG: 16,
    borderRadiusSM: 8,
    controlHeight: 40,
    controlHeightLG: 46,
    boxShadow: '0 12px 28px rgba(2, 8, 14, 0.34)',
    boxShadowSecondary: '0 28px 64px rgba(2, 8, 14, 0.46)',
    wireframe: false,
  },
  components: {
    Button: { primaryShadow: 'none', defaultShadow: 'none' },
    Select: { optionSelectedBg: '#1d2935', optionActiveBg: '#16202a' },
    Tabs: { itemSelectedColor: '#f2603c', inkBarColor: '#f2603c', itemColor: 'rgba(232, 239, 246, 0.7)' },
    Modal: { contentBg: '#16202a', headerBg: '#16202a' },
    Message: { contentBg: '#16202a' },
    Empty: { colorTextDescription: 'rgba(232, 239, 246, 0.46)' },
  },
}

watch(
  locale,
  (nextLocale) => {
    setAppLocale(nextLocale as AppLocale)
    document.title = t('app.title')
  },
  { immediate: true }
)
</script>
