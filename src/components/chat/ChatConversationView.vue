<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { ArrowLeft, Send, Paperclip, MoreHorizontal } from 'lucide-vue-next'
import Avatar from '../common/Avatar.vue'
import type { Conversation } from '../../types'

interface Props {
  conversation: Conversation
}

defineProps<Props>()

const emit = defineEmits<{
  (e: 'back'): void
  (e: 'send-message', text: string): void
  (e: 'clear-chat'): void
  (e: 'delete-chat'): void
}>()

const newMessageText = ref('')
const isMenuOpen = ref(false)
const menuRef = ref<HTMLElement | null>(null)

const toggleMenu = () => {
  isMenuOpen.value = !isMenuOpen.value
}

const handleClearChat = () => {
  emit('clear-chat')
  isMenuOpen.value = false
}

const handleDeleteChat = () => {
  emit('delete-chat')
  isMenuOpen.value = false
}

const handleClickOutside = (e: MouseEvent) => {
  if (menuRef.value && !menuRef.value.contains(e.target as Node)) {
    isMenuOpen.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})

const handleSend = () => {
  if (!newMessageText.value.trim()) return
  emit('send-message', newMessageText.value.trim())
  newMessageText.value = ''
}
</script>

<template>
  <div class="flex-1 flex flex-col h-[calc(100vh-2rem)] lg:h-[calc(100vh-2.5rem)] sticky top-4 lg:top-5 rounded-2xl lg:rounded-3xl border border-[#1f212a] bg-[#0c0d12] overflow-hidden shadow-lg select-none">
    <!-- Top Header -->
    <header class="h-16 px-4 sm:px-6 border-b border-[#1f212a] flex items-center justify-between shrink-0 bg-[#0c0d12]/90 backdrop-blur-md z-10">
      <div class="flex items-center gap-3 min-w-0">
        <!-- Back button (mobile) -->
        <button
          type="button"
          @click="emit('back')"
          class="md:hidden p-2 rounded-full text-gray-400 hover:text-white"
        >
          <ArrowLeft class="w-5 h-5" />
        </button>

        <Avatar
          size="sm"
          :is-tracon-official="conversation.isTraconOfficial"
        />

        <div class="min-w-0">
          <div class="flex items-center gap-2">
            <h3 class="text-sm font-bold text-white truncate">
              {{ conversation.name }}
            </h3>
            <span
              v-if="conversation.isOnline"
              class="w-2 h-2 rounded-full bg-emerald-500 shrink-0"
              title="En línea"
            />
          </div>
          <p class="text-xs text-gray-400 truncate">
            {{ conversation.statusText || `@${conversation.handle}` }}
          </p>
        </div>
      </div>

      <!-- Three dots horizontal options menu with dropdown -->
      <div ref="menuRef" class="relative">
        <button
          type="button"
          @click.stop="toggleMenu"
          class="p-2 rounded-full text-gray-400 hover:text-white hover:bg-white/10 transition-colors cursor-pointer"
          :class="isMenuOpen ? 'text-white bg-white/10' : ''"
          title="Opciones de la conversación"
        >
          <MoreHorizontal class="w-5 h-5" />
        </button>

        <!-- Dropdown Menu exactly matching Image -->
        <div
          v-if="isMenuOpen"
          class="absolute right-0 top-full mt-2 w-52 rounded-2xl bg-[#161722] border border-[#262838] py-2.5 shadow-2xl shadow-black/90 z-50 overflow-hidden"
        >
          <button
            type="button"
            @click="handleClearChat"
            class="w-full text-left px-5 py-3.5 text-[17px] font-normal text-white hover:bg-white/[0.06] transition-colors cursor-pointer"
          >
            Vaciar chat
          </button>

          <button
            type="button"
            @click="handleDeleteChat"
            class="w-full text-left px-5 py-3.5 text-[17px] font-normal text-white hover:bg-white/[0.06] transition-colors cursor-pointer"
          >
            Eliminar chat
          </button>
        </div>
      </div>
    </header>

    <!-- Messages Container -->
    <div class="flex-1 overflow-y-auto p-4 sm:p-6 space-y-3.5">
      <div
        v-for="msg in conversation.messages"
        :key="msg.id"
        class="flex flex-col"
        :class="msg.isMine ? 'items-end' : 'items-start'"
      >
        <div
          class="max-w-[270px] sm:max-w-[290px] px-3.5 py-2 rounded-2xl text-sm leading-relaxed"
          :class="[
            msg.isMine
              ? 'bg-[#f0254c] text-white rounded-br-sm'
              : 'bg-[#181922] text-gray-100 border border-[#232532] rounded-bl-sm',
          ]"
        >
          {{ msg.text }}
        </div>
        <span class="text-[11px] text-gray-500 mt-1 px-1">
          {{ msg.timestamp }}
        </span>
      </div>

      <div
        v-if="conversation.messages.length === 0"
        class="flex flex-col items-center justify-center h-full text-gray-500 text-sm"
      >
        No hay mensajes aún. ¡Envía el primero para iniciar la partida!
      </div>
    </div>

    <!-- Bottom Message Input Bar -->
    <div class="p-4 border-t border-[#1f212a] bg-[#0c0d12]">
      <form
        @submit.prevent="handleSend"
        class="flex items-center gap-2 bg-[#121319] border border-[#20222e] rounded-full px-4 py-2 focus-within:border-gray-600 transition-colors"
      >
        <button
          type="button"
          class="text-gray-400 hover:text-white p-1 transition-colors"
          title="Adjuntar archivo o evidencia"
        >
          <Paperclip class="w-4 h-4" />
        </button>

        <input
          v-model="newMessageText"
          type="text"
          placeholder="Escribe un mensaje..."
          class="flex-1 bg-transparent text-sm text-gray-100 placeholder:text-gray-500 focus:outline-none"
        />

        <button
          type="submit"
          :disabled="!newMessageText.trim()"
          class="p-1.5 rounded-full bg-[#f0254c] hover:bg-[#d9193f] text-white disabled:opacity-30 disabled:cursor-not-allowed transition-all cursor-pointer"
        >
          <Send class="w-4 h-4" />
        </button>
      </form>
    </div>
  </div>
</template>
