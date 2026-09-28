<template>
  <div
    class="swiper-slide"
    :class="{ 'swiper-slide-active': active }"
    @mouseenter="emit('hover')"
    @focusin="emit('hover')"
  >
    <div class="slide-media">
      <img :src="imageSrc" :alt="item.name" loading="lazy" @error="emit('image-error', $event)" />
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
        <PhArrowRight :size="17" weight="bold" />
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { PhArrowRight } from '@phosphor-icons/vue'

type OverviewAttractionItem = {
  name: string
  address: string
  visit_duration: number
  description: string
  dayArrayIndex: number
}

defineProps<{
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
</script>

<style scoped>
.swiper-slide {
  display: flex;
  flex-direction: column;
  width: 172px;
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
  height: 288px;
  overflow: hidden;
  line-height: 0;
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
  transform: scale(1.06);
}

.slide-body {
  display: flex;
  flex: 1;
  flex-direction: column;
  gap: var(--sp-2);
  padding: var(--sp-4);
}

.slide-name {
  font-size: var(--fs-md);
  font-weight: 600;
  color: var(--text-1);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.slide-desc {
  color: var(--text-2);
  font-size: var(--fs-sm);
  line-height: var(--lh-snug);
  display: -webkit-box;
  -webkit-line-clamp: 3;
  line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.slide-more {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
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
    width: 148px;
    height: 360px;
  }

  .slide-media {
    height: 248px;
  }
}
</style>
