<template>
  <div
    class="swiper-slide"
    :class="{ 'swiper-slide-active': active }"
    @mouseenter="emit('hover')"
    @focusin="emit('hover')"
  >
    <div class="slide-media">
      <img
        v-if="imageSrc && !imageFailed"
        :src="imageSrc"
        :alt="item.name"
        loading="lazy"
        @error="handleImageError"
      />
      <div v-else class="slide-placeholder">
        <PhMountains :size="28" weight="duotone" />
        <span class="slide-placeholder-name">{{ item.name }}</span>
      </div>
    </div>

    <div class="slide-body">
      <h3 class="slide-name">{{ item.name }}</h3>
      <p class="slide-desc">{{ item.description || item.address || t('common.noData') }}</p>
      <button
        type="button"
        class="slide-more"
        :aria-label="t('common.dayNumber', { day: item.dayArrayIndex + 1 })"
        @click="emit('select-day', item.dayArrayIndex)"
      >
        <PhArrowRight :size="16" weight="bold" />
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { PhArrowRight, PhMountains } from '@phosphor-icons/vue'

type OverviewAttractionItem = {
  name: string
  address: string
  visit_duration: number
  description: string
  dayArrayIndex: number
}

const props = defineProps<{
  item: OverviewAttractionItem
  imageSrc: string
  active: boolean
}>()

const emit = defineEmits<{
  (e: 'hover'): void
  (e: 'select-day', dayArrayIndex: number): void
  (e: 'image-error', event: Event): void
}>()

const { t } = useI18n()
const imageFailed = ref(false)

// 图片地址变化时重置失败状态，便于拿到新图后自动恢复
watch(
  () => props.imageSrc,
  () => {
    imageFailed.value = false
  }
)

const handleImageError = (event: Event) => {
  imageFailed.value = true
  emit('image-error', event)
}
</script>

<style scoped>
.swiper-slide {
  display: flex;
  flex-direction: column;
  width: 100%;
  height: 400px;
  overflow: hidden;
  background: var(--bg-1);
  border: 1px solid var(--line);
  border-radius: var(--r-md);
  box-shadow: var(--shadow-1);
}

.slide-media {
  position: relative;
  flex: none;
  height: 250px;
  overflow: hidden;
  background: var(--bg-2);
}

.slide-media img {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform var(--dur-slow) var(--ease);
}

.swiper-slide-active:hover .slide-media img {
  transform: scale(1.04);
}

/* 没有配图时的占位：图标 + 可换行的景点名 */
.slide-placeholder {
  height: 100%;
  display: grid;
  place-content: center;
  justify-items: center;
  gap: var(--sp-2);
  padding: var(--sp-4);
  color: var(--text-3);
  text-align: center;
}

.slide-placeholder-name {
  font-size: var(--fs-sm);
  line-height: var(--lh-snug);
  word-break: break-word;
}

.slide-body {
  display: flex;
  flex: 1;
  flex-direction: column;
  gap: 6px;
  min-height: 0;
  padding: 14px 16px 16px;
}

.slide-name {
  font-size: var(--fs-base);
  font-weight: 600;
  line-height: 1.32;
  color: var(--text-1);
  word-break: break-word;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.slide-desc {
  margin: 0;
  color: var(--text-2);
  font-size: var(--fs-xs);
  line-height: var(--lh-snug);
  word-break: break-word;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.slide-more {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  margin-top: auto;
  border: 0;
  border-radius: var(--r-pill);
  background: var(--accent);
  color: var(--accent-ink);
  cursor: pointer;
  transition: background var(--dur) var(--ease), transform var(--dur-fast) var(--ease);
}

.slide-more:hover {
  background: var(--accent-strong);
}

.slide-more:active {
  transform: translateY(1px);
}

.swiper-3d .swiper-slide-shadow-left,
.swiper-3d .swiper-slide-shadow-right {
  background-image: none;
}

@media (max-width: 768px) {
  .swiper-slide {
    height: 380px;
  }

  .slide-media {
    height: 228px;
  }
}
</style>
