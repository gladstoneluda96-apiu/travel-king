/**
 * 主题（日间 / 夜间）
 *
 * - 首次访问跟随系统 prefers-color-scheme
 * - 用户手动切换后写入 localStorage，之后以用户选择为准
 * - 主题通过 <html data-theme="light|dark"> 驱动 tokens.css 的变量组
 */

import { computed, ref } from 'vue'

export type ThemeMode = 'light' | 'dark'

const STORAGE_KEY = 'tripstar.theme'

const readStored = (): ThemeMode | null => {
  try {
    const value = window.localStorage.getItem(STORAGE_KEY)
    return value === 'light' || value === 'dark' ? value : null
  } catch {
    return null
  }
}

const prefersDark = () =>
  typeof window !== 'undefined' && window.matchMedia('(prefers-color-scheme: dark)').matches

export const theme = ref<ThemeMode>(readStored() ?? (prefersDark() ? 'dark' : 'light'))

export const isDark = computed(() => theme.value === 'dark')

export const applyTheme = (mode: ThemeMode) => {
  theme.value = mode
  if (typeof document === 'undefined') return
  const root = document.documentElement
  root.dataset.theme = mode
  root.style.colorScheme = mode
  document.querySelector('meta[name="theme-color"]')?.setAttribute('content', mode === 'dark' ? '#0a0f14' : '#f5f6f7')
}

export const setTheme = (mode: ThemeMode) => {
  applyTheme(mode)
  try {
    window.localStorage.setItem(STORAGE_KEY, mode)
  } catch {
    /* 隐私模式下写入失败时忽略 */
  }
}

export const toggleTheme = () => setTheme(theme.value === 'dark' ? 'light' : 'dark')

export const initTheme = () => {
  applyTheme(theme.value)
  // 用户没有手动选择时，跟随系统主题变化
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (event) => {
    if (!readStored()) applyTheme(event.matches ? 'dark' : 'light')
  })
}

/** 读取设计令牌的计算值，供 canvas 渲染（ECharts / 地图等）使用 */
export const cssVar = (name: string, fallback = ''): string => {
  if (typeof document === 'undefined') return fallback
  const value = getComputedStyle(document.documentElement).getPropertyValue(name).trim()
  return value || fallback
}
