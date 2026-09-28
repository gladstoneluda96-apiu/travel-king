<template>
  <div class="chat-dock">
    <button v-if="!chatOpen" type="button" class="chat-launcher" :disabled="!tripPlan" @click="openChatPanel">
      <PhChatCircleDots :size="20" weight="duotone" />
      <span>{{ t('result.chat.toggle') }}</span>
    </button>

    <section v-else class="chat-panel" :aria-label="t('result.chat.title')">
      <header class="chat-head">
        <h3 class="chat-title">{{ t('result.chat.title') }}</h3>
        <button type="button" class="chat-close" :aria-label="t('common.cancel')" @click="closeChatPanel">
          <PhX :size="16" weight="bold" />
        </button>
      </header>

      <div class="chat-body" ref="chatMessagesRef">
        <div v-if="chatHistory.length === 0" class="chat-empty">
          <p class="chat-welcome">{{ t('result.chat.welcome') }}</p>
          <div class="chat-suggestions">
            <button
              v-for="question in quickQuestions"
              :key="question.labelKey"
              type="button"
              class="chat-suggestion"
              :disabled="chatLoading || !tripPlan"
              @click="sendQuickQuestion(t(question.questionKey))"
            >
              {{ t(question.labelKey) }}
            </button>
          </div>
        </div>

        <div v-for="(msg, idx) in chatHistory" :key="`chat-${idx}`" class="chat-msg" :class="msg.role">
          {{ msg.content }}
        </div>

        <div v-if="chatLoading" class="chat-msg assistant typing">
          <span class="dot"></span>
          <span class="dot"></span>
          <span class="dot"></span>
        </div>
      </div>

      <form class="chat-input" @submit.prevent="sendChatMessage">
        <textarea
          v-model="chatInput"
          :placeholder="chatPlaceholder"
          name="chat_bot"
          id="chat_bot"
          rows="1"
          :disabled="chatLoading || !tripPlan"
          @keydown.enter.exact.prevent="sendChatMessage"
        ></textarea>
        <button
          type="submit"
          class="chat-send"
          :disabled="chatLoading || !chatInput.trim() || !tripPlan"
          :aria-label="t('result.chat.send')"
        >
          <PhPaperPlaneTilt :size="17" weight="fill" />
        </button>
      </form>
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed, nextTick, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import axios from 'axios'
import type { ChatMessage, TripPlan } from '@/types'
import { getRuntimeApiBaseUrl } from '@/services/api'
import { PhChatCircleDots, PhPaperPlaneTilt, PhX } from '@phosphor-icons/vue'

const props = defineProps<{
  tripPlan: TripPlan | null
}>()

const { t } = useI18n()
const chatOpen = ref(false)
const chatInput = ref('')
const chatHistory = ref<ChatMessage[]>([])
const chatLoading = ref(false)
const chatMessagesRef = ref<HTMLElement | null>(null)

const quickQuestions = [
  {
    labelKey: 'result.chat.quickPriceLabel',
    questionKey: 'result.chat.quickPriceQuestion',
  },
  {
    labelKey: 'result.chat.quickSuitabilityLabel',
    questionKey: 'result.chat.quickSuitabilityQuestion',
  },
  {
    labelKey: 'result.chat.quickMealLabel',
    questionKey: 'result.chat.quickMealQuestion',
  },
]

const chatPlaceholder = computed(() => {
  if (!props.tripPlan) return t('result.noTripPlanDesc')
  return t('result.chat.placeholder')
})

const scrollChatToBottom = () => {
  nextTick(() => {
    if (chatMessagesRef.value) {
      chatMessagesRef.value.scrollTop = chatMessagesRef.value.scrollHeight
    }
  })
}

watch(chatOpen, (open) => {
  if (open) scrollChatToBottom()
})

const openChatPanel = () => {
  if (!chatOpen.value) {
    chatOpen.value = true
  }
}

const closeChatPanel = () => {
  chatOpen.value = false
}

const sendQuickQuestion = (q: string) => {
  chatInput.value = q
  void sendChatMessage()
}

const sendChatMessage = async () => {
  const text = chatInput.value.trim()
  if (!text || chatLoading.value || !props.tripPlan) return

  chatHistory.value.push({ role: 'user', content: text })
  chatInput.value = ''
  chatLoading.value = true
  scrollChatToBottom()

  try {
    const apiBase = getRuntimeApiBaseUrl()
    const res = await axios.post(`${apiBase}/api/chat/ask`, {
      message: text,
      trip_plan: props.tripPlan,
      history: chatHistory.value.slice(0, -1),
    })

    if (res.data.success) {
      chatHistory.value.push({ role: 'assistant', content: res.data.reply })
    } else {
      chatHistory.value.push({ role: 'assistant', content: t('result.chat.replyFallback') })
    }
  } catch (err) {
    console.error('Chat error:', err)
    chatHistory.value.push({ role: 'assistant', content: t('result.chat.networkError') })
  } finally {
    chatLoading.value = false
    scrollChatToBottom()
  }
}
</script>

<style scoped>
.chat-dock {
  position: fixed;
  left: var(--sp-5);
  bottom: var(--sp-5);
  z-index: var(--z-overlay);
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}

.chat-launcher {
  display: inline-flex;
  align-items: center;
  gap: var(--sp-2);
  height: 46px;
  padding-inline: var(--sp-5);
  border: 1px solid var(--accent-line);
  border-radius: var(--r-pill);
  background: var(--bg-1);
  color: var(--text-1);
  font-size: var(--fs-sm);
  font-weight: 600;
  cursor: pointer;
  box-shadow: var(--shadow-2);
  transition: border-color var(--dur) var(--ease), background var(--dur) var(--ease),
    transform var(--dur-fast) var(--ease);
}

.chat-launcher:hover {
  background: var(--bg-2);
  border-color: var(--accent);
}

.chat-launcher:active {
  transform: translateY(1px);
}

.chat-launcher:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.chat-panel {
  display: flex;
  flex-direction: column;
  width: min(380px, calc(100vw - 32px));
  max-height: min(560px, calc(100dvh - 96px));
  overflow: hidden;
  background: var(--bg-1);
  border: 1px solid var(--line-strong);
  border-radius: var(--r-lg);
  box-shadow: var(--shadow-2);
}

.chat-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--sp-3);
  padding: var(--sp-4) var(--sp-5);
  border-bottom: 1px solid var(--line);
}

.chat-title {
  font-size: var(--fs-base);
  font-weight: 600;
}

.chat-close {
  width: 32px;
  height: 32px;
  display: grid;
  place-items: center;
  border: 1px solid transparent;
  border-radius: var(--r-sm);
  background: transparent;
  color: var(--text-3);
  cursor: pointer;
  transition: color var(--dur) var(--ease), background var(--dur) var(--ease), border-color var(--dur) var(--ease);
}

.chat-close:hover {
  color: var(--text-1);
  background: var(--bg-2);
  border-color: var(--line);
}

.chat-body {
  display: flex;
  flex: 1;
  flex-direction: column;
  gap: var(--sp-3);
  padding: var(--sp-4) var(--sp-5);
  overflow-y: auto;
}

.chat-empty {
  display: flex;
  flex-direction: column;
  gap: var(--sp-4);
}

.chat-welcome {
  color: var(--text-2);
  font-size: var(--fs-sm);
  line-height: var(--lh-body);
}

.chat-suggestions {
  display: flex;
  flex-wrap: wrap;
  gap: var(--sp-2);
}

.chat-suggestion {
  padding: 7px 12px;
  border: 1px solid var(--line);
  border-radius: var(--r-pill);
  background: var(--bg-2);
  color: var(--text-2);
  font-size: var(--fs-xs);
  cursor: pointer;
  transition: color var(--dur) var(--ease), border-color var(--dur) var(--ease);
}

.chat-suggestion:hover {
  color: var(--text-1);
  border-color: var(--accent-line);
}

.chat-msg {
  max-width: 88%;
  padding: 10px 14px;
  border-radius: var(--r-sm);
  font-size: var(--fs-sm);
  line-height: var(--lh-snug);
  white-space: pre-wrap;
}

.chat-msg.user {
  align-self: flex-end;
  background: var(--accent);
  color: var(--accent-ink);
  border-bottom-right-radius: var(--r-xs);
}

.chat-msg.assistant {
  align-self: flex-start;
  background: var(--bg-2);
  border: 1px solid var(--line);
  color: var(--text-1);
  border-bottom-left-radius: var(--r-xs);
}

.chat-msg.typing {
  display: inline-flex;
  align-items: center;
  gap: 5px;
}

.chat-msg.typing .dot {
  width: 6px;
  height: 6px;
  border-radius: var(--r-pill);
  background: var(--text-3);
  animation: chatBlink 1.1s var(--ease) infinite;
}

.chat-msg.typing .dot:nth-child(2) {
  animation-delay: 0.15s;
}

.chat-msg.typing .dot:nth-child(3) {
  animation-delay: 0.3s;
}

@keyframes chatBlink {
  0%,
  80%,
  100% {
    opacity: 0.3;
    transform: translateY(0);
  }
  40% {
    opacity: 1;
    transform: translateY(-2px);
  }
}

.chat-input {
  display: flex;
  align-items: flex-end;
  gap: var(--sp-2);
  padding: var(--sp-3) var(--sp-4);
  border-top: 1px solid var(--line);
}

.chat-input textarea {
  flex: 1;
  min-height: 42px;
  max-height: 120px;
  padding: 10px 12px;
  resize: none;
  background: var(--bg-2);
  border: 1px solid var(--line);
  border-radius: var(--r-sm);
  color: var(--text-1);
  font-family: var(--font-sans);
  font-size: var(--fs-sm);
  line-height: 1.5;
}

.chat-input textarea::placeholder {
  color: var(--text-3);
}

.chat-input textarea:focus {
  outline: none;
  border-color: var(--accent-line);
}

.chat-send {
  flex: none;
  width: 42px;
  height: 42px;
  display: grid;
  place-items: center;
  border: 0;
  border-radius: var(--r-sm);
  background: var(--accent);
  color: var(--accent-ink);
  cursor: pointer;
  transition: background var(--dur) var(--ease), transform var(--dur-fast) var(--ease);
}

.chat-send:hover:not(:disabled) {
  background: var(--accent-strong);
}

.chat-send:active:not(:disabled) {
  transform: translateY(1px);
}

.chat-send:disabled {
  background: var(--bg-3);
  color: var(--text-3);
  cursor: not-allowed;
}

@media (max-width: 520px) {
  .chat-dock {
    left: 16px;
    right: 16px;
    bottom: 16px;
  }

  .chat-panel {
    width: 100%;
  }
}
</style>
