<template>
  <div class="page">
    <NavBar @brand-click="scrollToTop" @cta-click="scrollToForm" />

    <header class="hero">
      <div class="hero-inner">
        <div class="hero-copy">
          <p class="hero-eyebrow">{{ t('home.heroBadge') }}</p>
          <h1 class="hero-title">{{ t('home.titleLine') }}</h1>
          <p class="hero-desc">{{ t('home.heroDesc') }}</p>
          <div class="hero-actions">
            <button class="btn-primary" type="button" @click="scrollToForm">
              <span>{{ t('home.nav.cta') }}</span>
              <PhArrowRight :size="16" weight="bold" />
            </button>
            <a class="hero-gh" href="https://github.com/1sdv/TripStar" target="_blank" rel="noreferrer">
              <PhGithubLogo :size="17" weight="fill" />
              <span>GitHub</span>
            </a>
          </div>
        </div>

        <figure class="hero-figure">
          <img :src="heroRoute" :alt="t('home.heroCardAlt')" width="1800" height="1240" />
          <figcaption class="hero-figure-caption">
            <span class="hero-figure-title">{{ t('home.heroCardTitle') }}</span>
            <span class="hero-figure-route">{{ t('home.heroCardCaption') }}</span>
          </figcaption>
        </figure>
      </div>
    </header>

    <section ref="formRef" class="planner">
      <div
        class="planner-panel"
        :class="{ 'is-visible': formVisible }"
        :style="panelHeight === 'auto' ? undefined : { minHeight: panelHeight + 'px' }"
        ref="panelRef"
      >
        <a-form v-show="!loading" :model="formData" layout="vertical" @finish="handleSubmit">
          <div class="step">
            <div class="step-head"><h3>{{ t('home.step1') }}</h3>
            </div>

            <!-- 多城市动态列表 -->
            <div class="city-list">
              <div v-for="(cs, idx) in formData.cities" :key="idx" class="city-row">
                <a-form-item class="city-row-name" :rules="[{ required: true, message: t('home.cityRequired') }]">
                  <template #label>
                    <span class="field-label">{{ t('home.cityNLabel', { n: idx + 1 }) }}</span>
                  </template>
                  <a-input
                    v-model:value="cs.city"
                    :placeholder="t('home.cityPlaceholder')"
                    size="large"
                    class="field-input"
                  />
                </a-form-item>
                <a-form-item class="city-row-days">
                  <template #label>
                    <span class="field-label">{{ t('home.cityStayDays') }}</span>
                  </template>
                  <a-input-number
                    v-model:value="cs.days"
                    :min="1"
                    :max="15"
                    size="large"
                    class="field-input"
                    style="width: 100%"
                  />
                </a-form-item>
                <button
                  v-if="formData.cities.length > 1"
                  type="button"
                  class="city-remove-btn"
                  @click="removeCity(idx)"
                >×</button>
              </div>
              <button type="button" class="city-add-btn" @click="addCity">
                + {{ t('home.addCity') }}
              </button>
            </div>

            <!-- 日期与天数 -->
            <div class="grid grid-date">
              <a-form-item name="start_date" :rules="formRules.startDate">
                <template #label>
                  <span class="field-label">{{ t('home.startDateLabel') }}</span>
                </template>
                <a-date-picker
                  v-model:value="formData.start_date"
                  style="width: 100%"
                  size="large"
                  class="field-input"
                  :placeholder="t('home.startDatePlaceholder')"
                />
              </a-form-item>

              <a-form-item>
                <template #label>
                  <span class="field-label">{{ t('home.travelDaysLabel') }}</span>
                </template>
                <div class="days-chip">
                  <span class="days-number">{{ totalDays }}</span>
                  <span class="days-unit">{{ t('home.travelDaysUnit') }}</span>
                </div>
              </a-form-item>
            </div>
          </div>

          <div class="step">
            <div class="step-head"><h3>{{ t('home.step2') }}</h3>
            </div>
            <div class="grid grid2">
              <a-form-item name="transportation">
                <template #label>
                  <span class="field-label">{{ t('home.transportationLabel') }}</span>
                </template>
                <a-select v-model:value="formData.transportation" size="large" class="field-select">
                  <a-select-option value="公共交通">{{ t('home.transportation.public') }}</a-select-option>
                  <a-select-option value="自驾">{{ t('home.transportation.drive') }}</a-select-option>
                  <a-select-option value="步行">{{ t('home.transportation.walk') }}</a-select-option>
                  <a-select-option value="混合">{{ t('home.transportation.mixed') }}</a-select-option>
                </a-select>
              </a-form-item>

              <a-form-item name="accommodation">
                <template #label>
                  <span class="field-label">{{ t('home.accommodationLabel') }}</span>
                </template>
                <a-select v-model:value="formData.accommodation" size="large" class="field-select">
                  <a-select-option value="经济型酒店">{{ t('home.accommodation.budget') }}</a-select-option>
                  <a-select-option value="舒适型酒店">{{ t('home.accommodation.comfort') }}</a-select-option>
                  <a-select-option value="豪华酒店">{{ t('home.accommodation.luxury') }}</a-select-option>
                  <a-select-option value="民宿">{{ t('home.accommodation.homestay') }}</a-select-option>
                </a-select>
              </a-form-item>
            </div>

            <a-form-item name="preferences">
              <template #label>
                <span class="field-label">{{ t('home.interestsLabel') }}</span>
              </template>
              <div class="interest-grid">
                <a-checkbox-group v-model:value="formData.preferences" class="interest-group">
                  <label
                    v-for="item in interestOptions"
                    :key="item.value"
                    class="interest-pill"
                    :class="{ active: formData.preferences.includes(item.value) }"
                    @click.prevent="togglePreference(item.value)"
                  >
                    {{ t(item.labelKey) }}
                  </label>
                </a-checkbox-group>
              </div>
            </a-form-item>
          </div>

          <div class="step">
            <div class="step-head"><h3>{{ t('home.step3') }}</h3>
            </div>
            <a-form-item name="free_text_input">
              <div class="field-textarea">
                <a-textarea
                  v-model:value="formData.free_text_input"
                  :placeholder="t('home.specialNeedsPlaceholder')"
                  :rows="4"
                  size="large"
                  class="special-textarea"
                />
              </div>
            </a-form-item>
          </div>

          <a-form-item>
            <button type="submit" class="btn-primary submit-btn" :class="{ loading }" :disabled="loading">
              <span v-if="!loading">{{ t('home.submit') }}</span>
              <span v-else class="loading-row">
                <i class="spinner"></i>
                {{ t('home.submitting') }}
              </span>
            </button>
          </a-form-item>
        </a-form>

        <!-- Node Loading Stepper -->
        <div v-show="loading" class="stepper-wrapper">
          <div class="stepper-header">
            <h2 class="stepper-title">{{ t('home.loading.planCode', { code: planCode }) }}</h2>
            <p class="stepper-subtitle">{{ t('home.loading.preparing') }}</p>
          </div>
          
          <div class="stepper-container">
            <!-- Step 1: Searching Attractions -->
            <div class="step-node" :class="{ active: loadingProgress >= 0 && loadingProgress <= 30, completed: loadingProgress > 30 }">
              <div class="node-icon">
                <i v-if="loadingProgress >= 0 && loadingProgress <= 30" class="spinner-small"></i>
                <PhMapPin :size="19" weight="duotone" />
              </div>
              <p class="node-text">{{ loadingProgress > 30 ? t('home.loading.searchedAttractions') : t('home.loading.searchingAttractions') }}</p>
            </div>
            <div class="step-divider" :class="{ completed: loadingProgress > 30 }"></div>

            <!-- Step 2: Weather -->
            <div class="step-node" :class="{ active: loadingProgress > 30 && loadingProgress <= 50, completed: loadingProgress > 50 }">
              <div class="node-icon">
                <i v-if="loadingProgress > 30 && loadingProgress <= 50" class="spinner-small"></i>
                <PhCloudSun :size="19" weight="duotone" />
              </div>
              <p class="node-text">{{ loadingProgress > 50 ? t('home.loading.queriedWeather') : t('home.loading.queryingWeather') }}</p>
            </div>
            <div class="step-divider" :class="{ completed: loadingProgress > 50 }"></div>

            <!-- Step 3: Hotels -->
            <div class="step-node" :class="{ active: loadingProgress > 50 && loadingProgress <= 70, completed: loadingProgress > 70 }">
              <div class="node-icon">
                <i v-if="loadingProgress > 50 && loadingProgress <= 70" class="spinner-small"></i>
                <PhBed :size="19" weight="duotone" />
              </div>
              <p class="node-text">{{ loadingProgress > 70 ? t('home.loading.recommendedHotels') : t('home.loading.recommendingHotels') }}</p>
            </div>
            <div class="step-divider" :class="{ completed: loadingProgress > 70 }"></div>

            <!-- Step 4: Planning -->
            <div class="step-node" :class="{ active: loadingProgress > 70 && loadingProgress < 100, completed: loadingProgress >= 100 }">
              <div class="node-icon">
                <i v-if="loadingProgress > 70 && loadingProgress < 100" class="spinner-small"></i>
                <PhCheckCircle :size="19" weight="duotone" />
              </div>
              <p class="node-text">{{ loadingProgress >= 100 ? t('home.loading.done') : t('home.loading.generatingPlan') }}</p>
            </div>
          </div>
          
          <div class="stepper-footer">
            <h3>{{ loadingStatus }}</h3>
            <p v-if="loadingProgress < 100">{{ t('home.loading.workingTogether') }}</p>
            <p v-else>{{ t('home.loading.donePrepare') }}</p>
          </div>
        </div>
      </div>
    </section>

    <section class="history">
      <div class="history-panel">
        <div class="history-head">
          <div>
            <p class="history-eyebrow">{{ t('home.history.eyebrow') }}</p>
            <h3 class="history-title">{{ t('home.history.title') }}</h3>
          </div>
          <a-button type="link" class="history-refresh" @click="loadHistoryPlans">
            {{ t('home.history.refresh') }}
          </a-button>
        </div>

        <div v-if="historyLoading" class="history-loading">
          {{ t('common.loading') }}
        </div>
        <a-empty v-else-if="historyPlans.length === 0" :description="t('home.history.empty')" />
        <div v-else class="history-list">
          <button
            v-for="item in historyPlans"
            :key="item.plan_id"
            type="button"
            class="history-item"
            @click="openHistoryPlan(item.plan_id)"
          >
            <div class="history-item-main">
              <div class="history-route">
                <span class="history-city">{{ item.city }}</span>
                <span class="history-date">{{ item.start_date }} {{ t('common.to') }} {{ item.end_date }}</span>
              </div>
              <p class="history-meta">
                <span>Plan ID: {{ item.plan_id }}</span>
                <span>{{ item.travel_days }}{{ t('home.travelDaysUnit') }}</span>
                <span>{{ t('home.history.updatedAt') }} {{ formatHistoryTime(item.updated_at) }}</span>
              </p>
              <p v-if="item.overall_suggestions" class="history-summary">{{ item.overall_suggestions }}</p>
            </div>
            <span class="history-open">{{ t('home.history.open') }}</span>
          </button>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { message } from 'ant-design-vue'
import { generateTripPlan, getTripHistory } from '@/services/api'
import { getCurrentLocale } from '@/i18n'
import NavBar from '@/components/NavBar.vue'
import { PhArrowRight, PhBed, PhCheckCircle, PhCloudSun, PhGithubLogo, PhMapPin } from '@phosphor-icons/vue'
import heroRoute from '@/assets/hero-route.png'
import type { TripFormData, TripTaskEvent, TripHistoryItem, CityStay } from '@/types'
import type { Dayjs } from 'dayjs'

type LandingFormData = {
  cities: Array<{ city: string; days: number }>
  start_date: Dayjs | null
  transportation: string
  accommodation: string
  preferences: string[]
  free_text_input: string
}

const router = useRouter()
const { t } = useI18n()

const loading = ref(false)
const loadingProgress = ref(0)
const loadingStatus = ref('')
const formRef = ref<HTMLElement | null>(null)
const panelRef = ref<HTMLElement | null>(null)
const panelHeight = ref<number | string>('auto')
const formVisible = ref(false)
let formObserver: IntersectionObserver | null = null
const planCode = ref('')
const historyLoading = ref(false)
const historyPlans = ref<TripHistoryItem[]>([])

const getStageStatusText = (stage: TripTaskEvent['stage']) => {
  if (stage === 'submitted' || stage === 'initializing') return t('home.loading.initializing')
  if (stage === 'attraction_search') return t('home.loading.searchingAttractions')
  if (stage === 'weather_search') return t('home.loading.queryingWeather')
  if (stage === 'hotel_search') return t('home.loading.recommendingHotels')
  if (stage === 'planning') return t('home.loading.generatingPlan')
  if (stage === 'graph_building') return t('home.loading.generatingPlan')
  if (stage === 'completed') return t('home.loading.done')
  return t('home.loading.initializing')
}

const interestOptions = [
  { value: '历史文化', labelKey: 'home.interests.history' },
  { value: '自然风光', labelKey: 'home.interests.nature' },
  { value: '美食', labelKey: 'home.interests.food' },
  { value: '购物', labelKey: 'home.interests.shopping' },
  { value: '艺术', labelKey: 'home.interests.art' },
  { value: '休闲', labelKey: 'home.interests.leisure' },
]

const formRules = computed(() => ({
  startDate: [{ required: true, message: t('home.startDateRequired') }],
}))

const formData = reactive<LandingFormData>({
  cities: [{ city: '', days: 2 }],
  start_date: null,
  transportation: '公共交通',
  accommodation: '经济型酒店',
  preferences: [],
  free_text_input: '',
})

const totalDays = computed(() => formData.cities.reduce((sum, cs) => sum + (cs.days || 1), 0))

const computedEndDate = computed(() => {
  if (!formData.start_date) return null
  return formData.start_date.add(totalDays.value - 1, 'day')
})

const addCity = () => {
  if (formData.cities.length >= 5) return
  formData.cities.push({ city: '', days: 2 })
}

const removeCity = (index: number) => {
  if (formData.cities.length <= 1) return
  formData.cities.splice(index, 1)
}

const togglePreference = (value: string) => {
  const index = formData.preferences.indexOf(value)
  if (index === -1) formData.preferences.push(value)
  else formData.preferences.splice(index, 1)
}

const scrollToTop = () => window.scrollTo({ top: 0, behavior: 'smooth' })
const scrollToForm = () => {
  if (formRef.value) {
    const y = formRef.value.getBoundingClientRect().top + window.scrollY - 65
    window.scrollTo({ top: y, behavior: 'smooth' })
  }
}

const formatHistoryTime = (value: string) => {
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return value
  return date.toLocaleString()
}

const openHistoryPlan = (planId: string) => {
  if (!planId) return
  sessionStorage.removeItem('tripPlan')
  sessionStorage.removeItem('graphData')
  sessionStorage.setItem('planId', planId)
  router.push({ path: '/result', query: { plan_id: planId } })
}

const loadHistoryPlans = async () => {
  historyLoading.value = true
  try {
    historyPlans.value = await getTripHistory(8)
  } catch (error: any) {
    historyPlans.value = []
    message.error(error.message || t('home.history.loadFailed'))
  } finally {
    historyLoading.value = false
  }
}

onMounted(() => {
  // 表单面板进入视口后再淡入（使用 IntersectionObserver，不监听 scroll 事件）
  if (panelRef.value) {
    formObserver = new IntersectionObserver(
      (entries) => {
        if (entries.some((entry) => entry.isIntersecting)) {
          formVisible.value = true
          formObserver?.disconnect()
          formObserver = null
        }
      },
      { rootMargin: '0px 0px -12% 0px' }
    )
    formObserver.observe(panelRef.value)
  }
  void loadHistoryPlans()
})
onUnmounted(() => {
  formObserver?.disconnect()
  formObserver = null
})

const handleSubmit = async () => {
  // 校验：至少一个城市名非空
  const validCities = formData.cities.filter(cs => cs.city.trim())
  if (validCities.length === 0) {
    message.error(t('home.atLeastOneCity'))
    return
  }
  if (!formData.start_date) {
    message.error(t('home.messages.selectDate'))
    return
  }
  if (totalDays.value > 30) {
    message.warning(t('home.messages.travelDaysTooLong'))
    return
  }

  if (panelRef.value) {
    panelHeight.value = panelRef.value.offsetHeight
  }

  loading.value = true
  loadingProgress.value = 5
  loadingStatus.value = t('home.loading.initializing')
  planCode.value = ''

  try {
    sessionStorage.removeItem('tripPlan')
    sessionStorage.removeItem('graphData')
    sessionStorage.removeItem('planId')

    const citiesPayload: CityStay[] = validCities.map(cs => ({ city: cs.city.trim(), days: cs.days || 1 }))
    const endDate = computedEndDate.value!

    const requestData: TripFormData = {
      city: citiesPayload[0].city,
      cities: citiesPayload,
      start_date: formData.start_date.format('YYYY-MM-DD'),
      end_date: endDate.format('YYYY-MM-DD'),
      travel_days: totalDays.value,
      transportation: formData.transportation,
      accommodation: formData.accommodation,
      preferences: formData.preferences,
      free_text_input: formData.free_text_input,
      language: getCurrentLocale(),
    }

    const response = await generateTripPlan(requestData, {
      onTaskCreated: (task) => {
        planCode.value = task.plan_id || task.task_id
        loadingProgress.value = 5
        loadingStatus.value = t('home.loading.initializing')
      },
      onTaskEvent: (event) => {
        if (event.plan_id) planCode.value = event.plan_id
        if (Number.isFinite(event.progress)) {
          loadingProgress.value = Math.max(0, Math.min(100, event.progress))
        }
        loadingStatus.value = event.message || getStageStatusText(event.stage)
      }
    })

    loadingProgress.value = 100
    loadingStatus.value = t('home.loading.done')

    if (response.success && response.data) {
      const planId = response.plan_id || planCode.value
      sessionStorage.setItem('tripPlan', JSON.stringify(response.data))
      if (response.graph_data) sessionStorage.setItem('graphData', JSON.stringify(response.graph_data))
      if (planId) sessionStorage.setItem('planId', planId)
      message.success(t('home.messages.generateSuccess'))
      setTimeout(() => {
        if (planId) {
          router.push({ path: '/result', query: { plan_id: planId } })
        } else {
          router.push('/result')
        }
      }, 500)
    } else {
      sessionStorage.removeItem('tripPlan')
      sessionStorage.removeItem('graphData')
      sessionStorage.removeItem('planId')
      message.error(response.message || t('home.messages.generateFailed'))
    }
  } catch (error: any) {
    sessionStorage.removeItem('tripPlan')
    sessionStorage.removeItem('graphData')
    sessionStorage.removeItem('planId')
    message.error(error.message || t('home.messages.generateRetry'))
  } finally {
    setTimeout(() => {
      loading.value = false
      loadingProgress.value = 0
      loadingStatus.value = ''
      panelHeight.value = 'auto'
    }, 1000)
  }
}
</script>

<style scoped>
.page {
  min-height: 100dvh;
  background: var(--bg-0);
  color: var(--text-1);
}

/* ---------------- 首屏 ---------------- */

.hero {
  padding: calc(var(--nav-h) + var(--sp-8)) 0 var(--sp-8);
  border-bottom: 1px solid var(--line);
}

.hero-inner {
  max-width: var(--page-max);
  margin-inline: auto;
  padding-inline: clamp(16px, 4vw, 32px);
  display: grid;
  grid-template-columns: minmax(0, 1.05fr) minmax(0, 1fr);
  align-items: center;
  gap: var(--sp-8);
}

.hero-eyebrow {
  color: var(--text-3);
  font-size: var(--fs-sm);
  letter-spacing: var(--ls-wide);
  text-transform: uppercase;
}

.hero-title {
  margin-top: var(--sp-3);
  font-size: var(--fs-display);
  font-weight: 600;
  color: var(--text-1);
}

.hero-desc {
  margin-top: var(--sp-4);
  max-width: 46ch;
  color: var(--text-2);
  font-size: var(--fs-md);
  line-height: var(--lh-body);
}

.hero-actions {
  margin-top: var(--sp-6);
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: var(--sp-5);
}

.btn-primary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--sp-2);
  height: 46px;
  padding-inline: var(--sp-5);
  border: 0;
  border-radius: var(--r-sm);
  background: var(--accent);
  color: var(--accent-ink);
  font-size: var(--fs-base);
  font-weight: 600;
  cursor: pointer;
  transition: background var(--dur) var(--ease), transform var(--dur-fast) var(--ease);
}

.btn-primary:hover {
  background: var(--accent-strong);
}

.btn-primary:active {
  transform: translateY(1px) scale(0.995);
}

.hero-gh {
  display: inline-flex;
  align-items: center;
  gap: var(--sp-2);
  color: var(--text-2);
  font-size: var(--fs-sm);
}

.hero-gh:hover {
  color: var(--text-1);
}

.hero-figure {
  margin: 0;
  overflow: hidden;
  background: var(--bg-1);
  border: 1px solid var(--line-strong);
  border-radius: var(--r-lg);
  box-shadow: var(--shadow-2);
}

.hero-figure img {
  display: block;
  width: 100%;
  height: auto;
}

.hero-figure-caption {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: var(--sp-4);
  padding: var(--sp-4) var(--sp-5);
  border-top: 1px solid var(--line);
}

.hero-figure-title {
  font-size: var(--fs-base);
  font-weight: 600;
}

.hero-figure-route {
  color: var(--text-3);
  font-size: var(--fs-sm);
}

/* ---------------- 规划表单 ---------------- */

.planner {
  padding: var(--sp-8) 0 var(--sp-7);
}

.planner-panel {
  max-width: 880px;
  margin-inline: auto;
  padding: clamp(20px, 3vw, 40px);
  background: var(--bg-1);
  border: 1px solid var(--line);
  border-radius: var(--r-lg);
  opacity: 0.3;
  transform: translate3d(0, 20px, 0);
  transition: opacity var(--dur-slow) var(--ease), transform var(--dur-slow) var(--ease);
}

.planner-panel.is-visible {
  opacity: 1;
  transform: none;
}

.planner-panel :deep(.ant-form-item) {
  margin-bottom: 0;
}

.planner-panel :deep(.ant-form-item-label) {
  padding-bottom: var(--sp-2);
}

.step {
  padding-block: var(--sp-7);
  border-top: 1px solid var(--line);
}

.step:first-of-type {
  padding-top: 0;
  border-top: 0;
}

.step > * + * {
  margin-top: var(--sp-5);
}

.step-head {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
}

.step-head h3 {
  font-size: var(--fs-lg);
  font-weight: 600;
}

.field-label {
  color: var(--text-2);
  font-size: var(--fs-sm);
}

.field-input {
  border-radius: var(--r-sm);
}

.field-select :deep(.ant-select-selector) {
  border-radius: var(--r-sm) !important;
}

.special-textarea {
  border-radius: var(--r-sm);
}

.grid {
  display: grid;
  gap: var(--sp-5);
}

.grid-date,
.grid2 {
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.days-chip {
  display: flex;
  align-items: baseline;
  gap: var(--sp-2);
  height: 46px;
  padding-inline: var(--sp-4);
  background: var(--bg-2);
  border: 1px solid var(--line);
  border-radius: var(--r-sm);
}

.days-number {
  font-family: var(--font-mono);
  font-size: var(--fs-lg);
  font-weight: 600;
}

.days-unit {
  color: var(--text-3);
  font-size: var(--fs-sm);
}

.city-list {
  display: grid;
  gap: var(--sp-4);
}

.city-row {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 150px 40px;
  gap: var(--sp-3);
  align-items: end;
}

.city-row :deep(.ant-form-item) {
  margin-bottom: 0;
}

.city-remove-btn {
  height: 46px;
  width: 40px;
  border: 1px solid var(--line);
  border-radius: var(--r-sm);
  background: transparent;
  color: var(--text-3);
  font-size: var(--fs-lg);
  line-height: 1;
  cursor: pointer;
  transition: color var(--dur) var(--ease), border-color var(--dur) var(--ease);
}

.city-remove-btn:hover {
  color: var(--danger);
  border-color: var(--danger);
}

.city-add-btn {
  justify-self: start;
  height: 40px;
  padding-inline: var(--sp-4);
  border: 1px dashed var(--line-strong);
  border-radius: var(--r-sm);
  background: transparent;
  color: var(--text-2);
  font-size: var(--fs-sm);
  cursor: pointer;
  transition: color var(--dur) var(--ease), border-color var(--dur) var(--ease);
}

.city-add-btn:hover {
  color: var(--text-1);
  border-color: var(--accent-line);
}

.interest-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(132px, 1fr));
  gap: var(--sp-2);
}

.interest-group {
  display: contents;
}

.interest-pill {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 10px 12px;
  background: var(--bg-2);
  border: 1px solid var(--line);
  border-radius: var(--r-pill);
  color: var(--text-2);
  font-size: var(--fs-sm);
  cursor: pointer;
  transition: border-color var(--dur) var(--ease), background var(--dur) var(--ease), color var(--dur) var(--ease);
}

.interest-pill:hover {
  color: var(--text-1);
  border-color: var(--line-strong);
}

.interest-pill.active {
  background: var(--accent-soft);
  border-color: var(--accent-line);
  color: var(--text-1);
}

.submit-btn {
  width: 100%;
  max-width: 320px;
}

.loading-row {
  display: inline-flex;
  align-items: center;
  gap: var(--sp-2);
}

.spinner,
.spinner-small {
  display: inline-block;
  border-radius: 50%;
  border: 2px solid var(--line-strong);
  border-top-color: var(--accent);
  animation: spin 0.8s linear infinite;
}

.spinner {
  width: 16px;
  height: 16px;
}

.spinner-small {
  width: 14px;
  height: 14px;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

/* ---------------- 生成进度 ---------------- */

.stepper-wrapper {
  padding-block: var(--sp-3);
}

.stepper-header {
  margin-bottom: var(--sp-6);
}

.stepper-title {
  font-family: var(--font-mono);
  font-size: var(--fs-lg);
  font-weight: 600;
}

.stepper-subtitle {
  margin-top: var(--sp-2);
  color: var(--text-3);
  font-size: var(--fs-sm);
}

.stepper-container {
  display: grid;
  grid-template-columns: auto 1fr auto 1fr auto 1fr auto;
  align-items: center;
  gap: var(--sp-3);
}

.step-node {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--sp-2);
  color: var(--text-3);
  transition: color var(--dur) var(--ease);
}

.step-node.active {
  color: var(--text-1);
}

.step-node.completed {
  color: var(--ok);
}

.node-icon {
  width: 38px;
  height: 38px;
  display: grid;
  place-items: center;
  background: var(--bg-2);
  border: 1px solid var(--line);
  border-radius: var(--r-pill);
}

.step-node.active .node-icon {
  background: var(--accent-soft);
  border-color: var(--accent-line);
  color: var(--accent);
}

.step-node.completed .node-icon {
  color: var(--ok);
}

.node-text {
  font-size: var(--fs-xs);
  text-align: center;
}

.step-divider {
  height: 1px;
  background: var(--line);
}

.step-divider.completed {
  background: var(--ok);
}

.stepper-footer {
  margin-top: var(--sp-6);
}

.stepper-footer h3 {
  font-size: var(--fs-base);
  font-weight: 600;
}

.stepper-footer p {
  margin-top: var(--sp-1);
  color: var(--text-3);
  font-size: var(--fs-sm);
}

/* ---------------- 历史记录 ---------------- */

.history {
  padding: 0 24px var(--sp-9);
}

.history-panel {
  max-width: 880px;
  margin-inline: auto;
  padding: clamp(20px, 3vw, 32px);
  background: var(--bg-1);
  border: 1px solid var(--line);
  border-radius: var(--r-lg);
}

.history-head {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: var(--sp-4);
  margin-bottom: var(--sp-4);
}

.history-eyebrow {
  color: var(--text-3);
  font-size: var(--fs-xs);
  letter-spacing: var(--ls-wide);
  text-transform: uppercase;
}

.history-title {
  margin-top: var(--sp-1);
  font-size: var(--fs-lg);
  font-weight: 600;
}

.history-loading {
  padding-block: var(--sp-3);
  color: var(--text-3);
  font-size: var(--fs-sm);
}

.history-list {
  display: grid;
}

.history-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--sp-5);
  width: 100%;
  padding: var(--sp-4) 0;
  background: none;
  border: 0;
  border-top: 1px solid var(--line);
  text-align: left;
  color: inherit;
  cursor: pointer;
}

.history-item:first-child {
  border-top: 0;
}

.history-item-main {
  min-width: 0;
  flex: 1;
}

.history-route {
  display: flex;
  align-items: baseline;
  flex-wrap: wrap;
  gap: var(--sp-3);
}

.history-city {
  font-size: var(--fs-md);
  font-weight: 600;
  transition: color var(--dur) var(--ease);
}

.history-item:hover .history-city {
  color: var(--accent);
}

.history-date {
  color: var(--text-3);
  font-size: var(--fs-sm);
  font-family: var(--font-mono);
}

.history-meta {
  display: flex;
  flex-wrap: wrap;
  gap: var(--sp-4);
  margin-top: var(--sp-2);
  color: var(--text-3);
  font-size: var(--fs-xs);
  font-family: var(--font-mono);
}

.history-summary {
  margin-top: var(--sp-2);
  color: var(--text-2);
  font-size: var(--fs-sm);
  line-height: var(--lh-snug);
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.history-open {
  flex: none;
  color: var(--accent);
  font-size: var(--fs-sm);
  white-space: nowrap;
}

/* ---------------- 响应式 ---------------- */

@media (max-width: 900px) {
  .hero {
    padding-top: calc(var(--nav-h) + var(--sp-6));
  }

  .hero-inner,
  .grid-date,
  .grid2 {
    grid-template-columns: minmax(0, 1fr);
  }

  .city-row {
    grid-template-columns: minmax(0, 1fr) 104px 40px;
  }

  .stepper-container {
    grid-template-columns: minmax(0, 1fr);
    gap: var(--sp-4);
  }

  .step-node {
    flex-direction: row;
    justify-content: flex-start;
    gap: var(--sp-3);
  }

  .node-text {
    text-align: left;
  }

  .step-divider {
    display: none;
  }

  .history {
    padding-inline: 16px;
  }
}
</style>
