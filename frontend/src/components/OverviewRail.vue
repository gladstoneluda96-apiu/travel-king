<template>
  <div class="rail">
    <div
      ref="viewportRef"
      class="rail-viewport"
      @pointerdown="onPointerDown"
      @pointermove="onPointerMove"
      @pointerup="onPointerUp"
      @pointercancel="onPointerUp"
      @pointerleave="onPointerUp"
    >
      <div class="rail-track" :class="{ 'is-dragging': dragging }" :style="trackStyle">
        <div
          v-for="(item, index) in items"
          :key="`${item.dayArrayIndex}-${item.order}-${item.name}`"
          class="rail-item"
          :style="itemStyle(index)"
          @click="selectItem(index)"
        >
          <OverviewAttractionCard
            :item="item"
            :image-src="getImage(item.name, index)"
            :active="index === activeIndex"
            @image-error="emit('image-error', $event)"
            @select-day="(day: number) => emit('select-day', day)"
          />
        </div>
      </div>
    </div>

    <div class="rail-controls">
      <button
        type="button"
        class="rail-step"
        :disabled="activeIndex === 0"
        :aria-label="t('common.prev')"
        @click="step(-1)"
      >
        <PhCaretLeft :size="16" weight="bold" />
      </button>

      <input
        class="rail-progress"
        type="range"
        min="0"
        :max="Math.max(items.length - 1, 0)"
        step="1"
        :value="activeIndex"
        :aria-label="t('result.side.overview')"
        :style="{ '--progress-percent': progressPercent }"
        @input="onRangeInput"
      />

      <button
        type="button"
        class="rail-step"
        :disabled="activeIndex >= items.length - 1"
        :aria-label="t('common.next')"
        @click="step(1)"
      >
        <PhCaretRight :size="16" weight="bold" />
      </button>

      <span class="rail-counter mono" aria-live="polite">{{ activeIndex + 1 }} / {{ items.length }}</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { PhCaretLeft, PhCaretRight } from '@phosphor-icons/vue'
import OverviewAttractionCard from '@/components/OverviewAttractionCard.vue'

type RailItem = {
  name: string
  address: string
  visit_duration: number
  description: string
  dayArrayIndex: number
  order: number
}

const props = defineProps<{
  items: RailItem[]
  getImage: (name: string, index: number) => string
}>()

const emit = defineEmits<{
  (e: 'image-error', event: Event): void
  (e: 'select-day', dayArrayIndex: number): void
}>()

const { t } = useI18n()

const viewportRef = ref<HTMLElement | null>(null)
const progress = ref(0) // 分数索引：拖动时连续变化，用于驱动位移与放大
const dragging = ref(false)
// 测量值必须响应式：否则位移/拖动计算在首次渲染后会一直用 0
const stepPx = ref(0)
const cardWidthPx = ref(0)
const viewportWidthPx = ref(0)
let resizeObserver: ResizeObserver | null = null

// 拖拽过程中的临时状态
let pointerStartX = 0
let pointerStartProgress = 0
let movedDistance = 0
let suppressClick = false

const activeIndex = computed(() => {
  const max = Math.max(props.items.length - 1, 0)
  return Math.min(Math.max(Math.round(progress.value), 0), max)
})

const progressPercent = computed(() => {
  const max = Math.max(props.items.length - 1, 1)
  return `${((activeIndex.value / max) * 100).toFixed(2)}%`
})

const clampProgress = (value: number) => {
  const max = Math.max(props.items.length - 1, 0)
  return Math.min(Math.max(value, 0), max)
}

const measure = () => {
  const viewport = viewportRef.value
  const first = viewport?.querySelector<HTMLElement>('.rail-item')
  if (!viewport || !first) return

  const styles = getComputedStyle(viewport.querySelector<HTMLElement>('.rail-track')!)
  const gap = parseFloat(styles.columnGap || '0') || 0
  cardWidthPx.value = first.offsetWidth
  stepPx.value = cardWidthPx.value + gap
  viewportWidthPx.value = viewport.clientWidth
}

// 位移：让当前卡片始终居中
const trackStyle = computed(() => {
  if (!stepPx.value || !viewportWidthPx.value) return { transform: 'translate3d(0, 0, 0)' }
  const offset = viewportWidthPx.value / 2 - (progress.value * stepPx.value + cardWidthPx.value / 2)
  return { transform: `translate3d(${offset.toFixed(1)}px, 0, 0)` }
})

// 主体放大突出：离当前卡片越近越大越亮
const itemStyle = (index: number) => {
  const distance = Math.abs(index - progress.value)
  const emphasis = Math.max(0, 1 - Math.min(distance, 2) / 2)
  // 主体卡片放大更明显：1.00 / 0.93 / 0.88
  const scale = (0.88 + 0.12 * emphasis).toFixed(3)
  const lift = (-8 * emphasis).toFixed(1)
  const opacity = (0.38 + 0.62 * emphasis).toFixed(3)
  return {
    transform: `translate3d(0, ${lift}px, 0) scale(${scale})`,
    opacity,
    zIndex: index === activeIndex.value ? 3 : 1,
  }
}

const onPointerDown = (event: PointerEvent) => {
  if (props.items.length <= 1) return
  dragging.value = true
  movedDistance = 0
  pointerStartX = event.clientX
  pointerStartProgress = progress.value
  ;(event.currentTarget as HTMLElement).setPointerCapture?.(event.pointerId)
}

const onPointerMove = (event: PointerEvent) => {
  if (!dragging.value || !stepPx.value) return
  const delta = event.clientX - pointerStartX
  movedDistance = Math.max(movedDistance, Math.abs(delta))
  progress.value = clampProgress(pointerStartProgress - delta / stepPx.value)
}

const onPointerUp = () => {
  if (!dragging.value) return
  dragging.value = false
  // 吸附到最近一张
  progress.value = activeIndex.value
  if (movedDistance > 6) {
    suppressClick = true
    window.setTimeout(() => {
      suppressClick = false
    }, 120)
  }
}

const selectItem = (index: number) => {
  if (suppressClick) return
  progress.value = index
}

const step = (delta: number) => {
  progress.value = clampProgress(activeIndex.value + delta)
}

const onRangeInput = (event: Event) => {
  progress.value = clampProgress(Number((event.target as HTMLInputElement).value))
}

const refresh = async () => {
  await nextTick()
  measure()
  // 数据变化后把进度限制在有效范围内
  progress.value = clampProgress(progress.value)
}

onMounted(() => {
  void refresh()
  if (typeof ResizeObserver !== 'undefined' && viewportRef.value) {
    // 板块切换会先 display:none，尺寸变化后重新测量即可保持居中
    resizeObserver = new ResizeObserver(() => {
      measure()
    })
    resizeObserver.observe(viewportRef.value)
  }
})

watch(() => props.items, () => void refresh(), { deep: false })

onBeforeUnmount(() => {
  resizeObserver?.disconnect()
  resizeObserver = null
})
</script>

<style scoped>
.rail {
  --card-w: 208px;
  --card-gap: 18px;
}

.rail-viewport {
  overflow: hidden;
  padding: var(--sp-5) 0 var(--sp-4);
  cursor: grab;
  touch-action: pan-y;
}

.rail-viewport:active {
  cursor: grabbing;
}

.rail-track {
  display: flex;
  align-items: flex-end;
  gap: var(--card-gap);
  transition: transform var(--dur-slow) var(--ease);
  will-change: transform;
}

.rail-track.is-dragging {
  transition: none;
}

.rail-item {
  flex: none;
  width: var(--card-w);
  transition: transform var(--dur) var(--ease), opacity var(--dur) var(--ease);
  will-change: transform, opacity;
}

.rail-track.is-dragging .rail-item {
  transition: none;
}

/* 浏览控制条 */
.rail-controls {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  margin-top: var(--sp-3);
}

.rail-step {
  flex: none;
  width: 32px;
  height: 32px;
  display: grid;
  place-items: center;
  border: 1px solid var(--line);
  border-radius: var(--r-sm);
  background: var(--bg-2);
  color: var(--text-2);
  cursor: pointer;
  transition: color var(--dur) var(--ease), border-color var(--dur) var(--ease), background var(--dur) var(--ease);
}

.rail-step:hover:not(:disabled) {
  color: var(--text-1);
  border-color: var(--accent-line);
}

.rail-step:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.rail-progress {
  flex: 1;
  appearance: none;
  height: 4px;
  margin: 0;
  border-radius: var(--r-pill);
  background: linear-gradient(
    to right,
    var(--accent) 0%,
    var(--accent) var(--progress-percent, 0%),
    var(--line-strong) var(--progress-percent, 0%),
    var(--line-strong) 100%
  );
  cursor: pointer;
}

.rail-progress::-webkit-slider-thumb {
  appearance: none;
  width: 16px;
  height: 16px;
  border-radius: var(--r-pill);
  background: var(--accent);
  border: 2px solid var(--bg-1);
  box-shadow: var(--shadow-1);
  cursor: grab;
}

.rail-progress::-webkit-slider-thumb:active {
  cursor: grabbing;
}

.rail-progress::-moz-range-thumb {
  width: 16px;
  height: 16px;
  border: 2px solid var(--bg-1);
  border-radius: var(--r-pill);
  background: var(--accent);
}

.rail-progress:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 4px;
}

.rail-counter {
  flex: none;
  min-width: 56px;
  text-align: right;
  color: var(--text-3);
  font-size: var(--fs-sm);
}

@media (max-width: 768px) {
  .rail {
    --card-w: 172px;
    --card-gap: 14px;
  }

  .rail-counter {
    min-width: 48px;
  }
}
</style>
