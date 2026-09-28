<template>
  <nav class="nav">
    <div class="nav-inner">
      <button class="brand" type="button" @click="handleBrandClick">
        <span class="brand-mark" aria-hidden="true"></span>
        <span class="brand-name">TripKing</span>
      </button>

      <div class="nav-actions">
        <a
          class="nav-icon"
          title="GitHub"
          aria-label="GitHub"
          href="https://github.com/1sdv/TripStar"
          target="_blank"
          rel="noreferrer"
        >
          <PhGithubLogo :size="18" weight="fill" />
        </a>

        <a-select
          v-model:value="locale"
          class="nav-lang"
          size="small"
          :aria-label="t('app.language.label')"
          :bordered="false"
        >
          <a-select-option value="zh-CN">{{ t('app.language.zh') }}</a-select-option>
          <a-select-option value="ja-JP">{{ t('app.language.ja') }}</a-select-option>
          <a-select-option value="en-US">{{ t('app.language.en') }}</a-select-option>
        </a-select>

        <button
          class="nav-icon"
          type="button"
          :title="t('settings.open')"
          :aria-label="t('settings.open')"
          @click="openSettingsDialog"
        >
          <PhGearSix :size="18" />
        </button>

        <button
          class="nav-icon"
          type="button"
          :title="isDark ? t('app.theme.toLight') : t('app.theme.toDark')"
          :aria-label="isDark ? t('app.theme.toLight') : t('app.theme.toDark')"
          @click="toggleTheme"
        >
          <PhSun v-if="isDark" :size="18" />
          <PhMoon v-else :size="18" />
        </button>

        <button class="nav-cta" type="button" @click="handleCtaClick">
          <span>{{ t('home.nav.cta') }}</span>
          <PhArrowRight :size="15" weight="bold" />
        </button>
      </div>
    </div>
    <a-modal
      v-model:open="settingsVisible"
      class="settings-modal"
      :title="t('settings.title')"
      :width="820"
      :confirm-loading="settingsSaving"
      :ok-text="t('settings.saveApply')"
      :cancel-text="t('settings.cancel')"
      @ok="saveSettingsNow"
    >
      <a-spin :spinning="settingsLoading">
        <section class="runtime-settings-panel">

          <a-form layout="vertical" class="runtime-settings-form">
            <div class="runtime-settings-grid">
              <a-form-item>
                <template #label>
                  <span class="field-label">{{ t('settings.labels.apiBaseUrl') }}</span>
                </template>
                <a-input
                  v-model:value="settingsForm.api_base_url"
                  :placeholder="t('settings.placeholders.apiBaseUrl')"
                  allow-clear
                />
              </a-form-item>

              <a-form-item>
                <template #label>
                  <span class="field-label">{{ t('settings.labels.amapJsKey') }}</span>
                </template>
                <a-input-password v-model:value="settingsForm.vite_amap_web_js_key" allow-clear />
              </a-form-item>

              <a-form-item>
                <template #label>
                  <span class="field-label">{{ t('settings.labels.amapWebKey') }}</span>
                </template>
                <a-input-password v-model:value="settingsForm.vite_amap_web_key" allow-clear />
              </a-form-item>

              <a-form-item>
                <template #label>
                  <span class="field-label">{{ t('settings.labels.googleMapsApiKey') }}</span>
                </template>
                <a-input-password
                  v-model:value="settingsForm.google_maps_api_key"
                  :placeholder="t('settings.placeholders.googleMapsApiKey')"
                  allow-clear
                />
              </a-form-item>

              <a-form-item>
                <template #label>
                  <span class="field-label">{{ t('settings.labels.googleMapsProxy') }}</span>
                </template>
                <a-input
                  v-model:value="settingsForm.google_maps_proxy"
                  :placeholder="t('settings.placeholders.googleMapsProxy')"
                  allow-clear
                />
              </a-form-item>

              <a-form-item>
                <template #label>
                  <span class="field-label">{{ t('settings.labels.openaiBaseUrl') }}</span>
                </template>
                <a-input
                  v-model:value="settingsForm.openai_base_url"
                  :placeholder="t('settings.placeholders.openaiBaseUrl')"
                  allow-clear
                />
              </a-form-item>

              <a-form-item>
                <template #label>
                  <span class="field-label">{{ t('settings.labels.openaiModel') }}</span>
                </template>
                <a-input
                  v-model:value="settingsForm.openai_model"
                  :placeholder="t('settings.placeholders.openaiModel')"
                  allow-clear
                />
              </a-form-item>

              <a-form-item>
                <template #label>
                  <span class="field-label">{{ t('settings.labels.openaiApiKey') }}</span>
                </template>
                <a-input-password v-model:value="settingsForm.openai_api_key" allow-clear />
              </a-form-item>
            </div>

            <a-form-item class="runtime-settings-full">
              <template #label>
                <span class="field-label">{{ t('settings.labels.xhsCookie') }}</span>
              </template>
              <a-textarea
                v-model:value="settingsForm.xhs_cookie"
                :rows="4"
                :placeholder="t('settings.placeholders.xhsCookie')"
                allow-clear
              />
            </a-form-item>
          </a-form>
        </section>
      </a-spin>
    </a-modal>
  </nav>
</template>

<script setup lang="ts">
import { PhArrowRight, PhGearSix, PhGithubLogo, PhMoon, PhSun } from '@phosphor-icons/vue'
import { isDark, toggleTheme } from '@/services/theme'
import { reactive, ref } from 'vue'
import { message } from 'ant-design-vue'
import { useI18n } from 'vue-i18n'
import type { RuntimeSettings } from '@/types'
import { getRuntimeSettings, saveRuntimeSettings } from '@/services/api'

const { t, locale } = useI18n()
const settingsVisible = ref(false)
const settingsLoading = ref(false)
const settingsSaving = ref(false)
const settingsForm = reactive<RuntimeSettings>({
  api_base_url: '',
  vite_amap_web_key: '',
  vite_amap_web_js_key: '',
  google_maps_api_key: '',
  google_maps_proxy: '',
  xhs_cookie: '',
  openai_api_key: '',
  openai_base_url: '',
  openai_model: '',
})

const emit = defineEmits<{
  (e: 'brand-click'): void
  (e: 'cta-click'): void
}>()

const handleBrandClick = () => {
  emit('brand-click')
}

const handleCtaClick = () => {
  emit('cta-click')
}

const applyRuntimeSettings = (settings: RuntimeSettings) => {
  settingsForm.api_base_url = settings.api_base_url || ''
  settingsForm.vite_amap_web_key = settings.vite_amap_web_key || ''
  settingsForm.vite_amap_web_js_key = settings.vite_amap_web_js_key || ''
  settingsForm.google_maps_api_key = settings.google_maps_api_key || ''
  settingsForm.google_maps_proxy = settings.google_maps_proxy || ''
  settingsForm.xhs_cookie = settings.xhs_cookie || ''
  settingsForm.openai_api_key = settings.openai_api_key || ''
  settingsForm.openai_base_url = settings.openai_base_url || ''
  settingsForm.openai_model = settings.openai_model || ''
}

const openSettingsDialog = async () => {
  settingsVisible.value = true
  settingsLoading.value = true
  try {
    const settings = await getRuntimeSettings()
    applyRuntimeSettings(settings)
  } catch (error: any) {
    message.error(error?.message || t('settings.messages.loadFailed'))
  } finally {
    settingsLoading.value = false
  }
}

const saveSettingsNow = async () => {
  settingsSaving.value = true
  try {
    const payload: RuntimeSettings = {
      api_base_url: settingsForm.api_base_url,
      vite_amap_web_key: settingsForm.vite_amap_web_key,
      vite_amap_web_js_key: settingsForm.vite_amap_web_js_key,
      google_maps_api_key: settingsForm.google_maps_api_key,
      google_maps_proxy: settingsForm.google_maps_proxy,
      xhs_cookie: settingsForm.xhs_cookie,
      openai_api_key: settingsForm.openai_api_key,
      openai_base_url: settingsForm.openai_base_url,
      openai_model: settingsForm.openai_model,
    }
    const saved = await saveRuntimeSettings(payload)
    applyRuntimeSettings(saved)
    message.success(t('settings.messages.saved'))
    settingsVisible.value = false
  } catch (error: any) {
    message.error(error?.message || t('settings.messages.saveFailed'))
  } finally {
    settingsSaving.value = false
  }
}
</script>

<style scoped>
.nav {
  position: fixed;
  inset: 0 0 auto 0;
  z-index: var(--z-nav);
  height: var(--nav-h);
  background: var(--nav-bg);
  border-bottom: 1px solid var(--line);
  backdrop-filter: blur(14px) saturate(130%);
  -webkit-backdrop-filter: blur(14px) saturate(130%);
}

.nav-inner {
  height: 100%;
  max-width: var(--page-max);
  margin-inline: auto;
  padding-inline: clamp(16px, 4vw, 32px);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--sp-4);
}

.brand {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 0;
  border: 0;
  background: none;
  color: var(--text-1);
  cursor: pointer;
}

.brand-mark {
  width: 22px;
  height: 22px;
  background: linear-gradient(140deg, var(--accent), var(--accent-strong));
  clip-path: polygon(50% 0%, 62% 38%, 100% 50%, 62% 62%, 50% 100%, 38% 62%, 0% 50%, 38% 38%);
}

.brand-name {
  font-size: var(--fs-base);
  font-weight: 600;
  letter-spacing: 0.02em;
}

.nav-actions {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
}

.nav-icon {
  width: 38px;
  height: 38px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border: 1px solid transparent;
  border-radius: var(--r-sm);
  background: transparent;
  color: var(--text-2);
  cursor: pointer;
  transition: color var(--dur) var(--ease), background var(--dur) var(--ease), border-color var(--dur) var(--ease);
}

.nav-icon:hover {
  color: var(--text-1);
  background: var(--bg-2);
  border-color: var(--line);
}

.nav-icon:active {
  transform: translateY(1px);
}

.nav-lang {
  width: 96px;
}

.nav-lang :deep(.ant-select-selector) {
  background: transparent !important;
  border-color: transparent !important;
}

.nav-lang :deep(.ant-select-selection-item) {
  color: var(--text-2);
  font-size: var(--fs-sm);
}

.nav-lang:hover :deep(.ant-select-selector) {
  background: var(--bg-2) !important;
}

.nav-cta {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  height: 38px;
  padding-inline: 16px;
  border: 0;
  border-radius: var(--r-sm);
  background: var(--accent);
  color: var(--accent-ink);
  font-size: var(--fs-sm);
  font-weight: 600;
  white-space: nowrap;
  cursor: pointer;
  transition: background var(--dur) var(--ease), transform var(--dur-fast) var(--ease);
}

.nav-cta:hover {
  background: var(--accent-strong);
}

.nav-cta:active {
  transform: translateY(1px) scale(0.99);
}

/* 设置弹窗 */
.settings-modal :deep(.ant-modal-body) {
  padding-top: var(--sp-2);
}

.runtime-settings-form :deep(.ant-form-item) {
  margin-bottom: var(--sp-4);
}

.runtime-settings-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0 var(--sp-5);
}

.runtime-settings-full {
  grid-column: 1 / -1;
}

.field-label {
  color: var(--text-2);
  font-size: var(--fs-sm);
}

@media (max-width: 720px) {
  .nav-lang {
    display: none;
  }

  .runtime-settings-grid {
    grid-template-columns: minmax(0, 1fr);
  }
}
</style>
