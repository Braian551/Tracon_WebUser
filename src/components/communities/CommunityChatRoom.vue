<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import {
  ChevronLeft,
  MoreHorizontal,
  PlusCircle,
  Send,
  Hash,
  Image as ImageIcon,
  Megaphone,
} from 'lucide-vue-next'
import type { CommunityDetail } from '../../types'

interface Props {
  community: CommunityDetail
}

const props = defineProps<Props>()

const emit = defineEmits<{
  (e: 'back'): void
  (e: 'send-message', text: string): void
  (e: 'leave'): void
}>()

const activeChannel = ref(props.community.activeChannel || 'general')
const messageText = ref('')
const messagesList = ref([...props.community.messages])

// 3-dots dropdown menu state
const isMenuOpen = ref(false)
const menuRef = ref<HTMLElement | null>(null)

const toggleMenu = () => {
  isMenuOpen.value = !isMenuOpen.value
}

const handleViewProfile = () => {
  isMenuOpen.value = false
}

const handleLeave = () => {
  isMenuOpen.value = false
  emit('leave')
  emit('back')
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
  if (!messageText.value.trim()) return
  messagesList.value.push({
    id: `cm-${Date.now()}`,
    authorName: 'Jeffrey Suárez',
    text: messageText.value.trim(),
    avatarBg: '#f0254c',
  })
  emit('send-message', messageText.value.trim())
  messageText.value = ''
}
</script>

<template>
  <main
    class="flex-1 min-w-0 rounded-2xl lg:rounded-3xl border border-[#1f212a] bg-black overflow-hidden flex flex-col h-[calc(100vh-2rem)] lg:h-[calc(100vh-2.5rem)] sticky top-4 lg:top-5 shadow-lg select-none"
  >
    <!-- Top Header -->
    <header class="h-16 px-4 sm:px-5 border-b border-[#1f212a] flex items-center justify-between shrink-0 bg-black/90 backdrop-blur-md z-10">
      <div class="flex items-center gap-3 min-w-0">
        <!-- Back button to return to communities list -->
        <button
          type="button"
          @click="emit('back')"
          class="p-1.5 -ml-1 rounded-full text-gray-400 hover:text-white hover:bg-white/10 transition-all cursor-pointer"
          title="Volver a Comunidades"
        >
          <ChevronLeft class="w-6 h-6" />
        </button>

        <!-- Community Avatar in header matching Image -->
        <div class="w-9 h-9 sm:w-10 sm:h-10 rounded-full border border-[#262835] bg-[#220d12] shrink-0 flex items-center justify-center overflow-hidden">
          <div class="w-full h-full bg-gradient-to-br from-[#591421] to-[#1a0509] flex items-center justify-center">
            <span class="text-xs font-bold text-red-300">SZ</span>
          </div>
        </div>

        <div class="min-w-0">
          <h2 class="text-base sm:text-lg font-bold text-white tracking-tight truncate leading-tight">
            {{ community.name }}
          </h2>
          <p class="text-xs text-gray-400 truncate mt-0.5">
            #General · {{ community.membersCount }}
          </p>
        </div>
      </div>

      <!-- Right Options Button with Dropdown -->
      <div ref="menuRef" class="relative">
        <button
          type="button"
          @click.stop="toggleMenu"
          class="p-2 rounded-full text-gray-400 hover:text-white hover:bg-white/10 transition-colors cursor-pointer"
          :class="isMenuOpen ? 'text-white bg-white/10' : ''"
          title="Opciones de la comunidad"
        >
          <MoreHorizontal class="w-5 h-5" />
        </button>

        <!-- Dropdown Menu exactly matching Image -->
        <div
          v-if="isMenuOpen"
          class="absolute right-0 top-full mt-2 w-48 rounded-2xl bg-[#161722] border border-[#262838] py-2 shadow-2xl shadow-black/95 z-50 overflow-hidden"
        >
          <button
            type="button"
            @click="handleViewProfile"
            class="w-full text-left px-5 py-3 text-[16px] font-normal text-white hover:bg-white/[0.06] transition-colors cursor-pointer"
          >
            Ver perfil
          </button>

          <button
            type="button"
            @click="handleLeave"
            class="w-full text-left px-5 py-3 text-[16px] font-normal text-white hover:bg-white/[0.06] transition-colors cursor-pointer"
          >
            Salir
          </button>
        </div>
      </div>
    </header>

    <!-- Channels Sub-tabs Header with Icons (# General / Multimedia / Anuncios) -->
    <div class="relative flex border-b border-[#15161e] px-2 bg-black/85 backdrop-blur-md shrink-0">
      <!-- 1. # General with Hash symbol -->
      <button
        type="button"
        @click="activeChannel = 'general'"
        class="relative flex-1 py-3 text-sm font-semibold text-center transition-colors duration-200 cursor-pointer flex items-center justify-center gap-1.5"
        :class="activeChannel === 'general' ? 'text-[#f0254c]' : 'text-gray-400 hover:text-gray-200'"
      >
        <Hash class="w-4 h-4" />
        <span>General</span>
      </button>

      <!-- 2. Multimedia with Image Icon -->
      <button
        type="button"
        @click="activeChannel = 'multimedia'"
        class="relative flex-1 py-3 text-sm font-semibold text-center transition-colors duration-200 cursor-pointer flex items-center justify-center gap-1.5"
        :class="activeChannel === 'multimedia' ? 'text-[#f0254c]' : 'text-gray-400 hover:text-gray-200'"
      >
        <ImageIcon class="w-4 h-4" />
        <span>Multimedia</span>
      </button>

      <!-- 3. Anuncios with Megaphone Icon -->
      <button
        type="button"
        @click="activeChannel = 'anuncios'"
        class="relative flex-1 py-3 text-sm font-semibold text-center transition-colors duration-200 cursor-pointer flex items-center justify-center gap-1.5"
        :class="activeChannel === 'anuncios' ? 'text-[#f0254c]' : 'text-gray-400 hover:text-gray-200'"
      >
        <Megaphone class="w-4 h-4" />
        <span>Anuncios</span>
      </button>

      <!-- Smooth sliding indicator -->
      <span
        class="absolute bottom-0 h-[3px] w-20 rounded-full bg-[#f0254c] shadow-[0_0_8px_rgba(240,37,76,0.6)] transition-all duration-300 ease-[cubic-bezier(0.23,1,0.32,1)] -translate-x-1/2 pointer-events-none"
        :style="{
          left: activeChannel === 'general' ? '16.666%' : activeChannel === 'multimedia' ? '50%' : '83.333%'
        }"
      />
    </div>

    <!-- Messages Feed -->
    <div class="flex-1 overflow-y-auto no-scrollbar p-4 sm:p-6 space-y-4">
      <template v-for="msg in messagesList" :key="msg.id">
        <!-- Date Header Separator -->
        <div
          v-if="msg.dateHeader"
          class="text-center text-xs text-gray-500 font-medium my-3 select-none tracking-wide"
        >
          {{ msg.dateHeader }}
        </div>

        <!-- Group Message Row (Discord-like channel layout) -->
        <div class="flex items-start gap-3 group hover:bg-white/[0.015] -mx-2 px-2 py-1.5 rounded-xl transition-colors">
          <!-- User Avatar -->
          <div
            class="w-10 h-10 rounded-full border border-[#262835] shrink-0 mt-0.5 flex items-center justify-center"
            :style="{ backgroundColor: msg.avatarBg || '#1a1b24' }"
          >
            <div class="w-3.5 h-3.5 rounded-full bg-white/10" />
          </div>

          <!-- Message Content -->
          <div class="flex-1 min-w-0">
            <span class="font-bold text-[15px] text-white tracking-wide block">
              {{ msg.authorName }}
            </span>
            <p class="text-[14px] text-gray-200 mt-0.5 leading-relaxed break-words">
              {{ msg.text }}
            </p>
          </div>
        </div>
      </template>
    </div>

    <!-- Bottom Input Bar -->
    <div class="p-4 border-t border-[#1f212a] bg-black shrink-0">
      <form
        @submit.prevent="handleSend"
        class="flex items-center gap-3"
      >
        <!-- Plus Action Button -->
        <button
          type="button"
          class="text-gray-400 hover:text-white transition-colors cursor-pointer shrink-0"
          title="Adjuntar multimedia"
        >
          <PlusCircle class="w-6 h-6" />
        </button>

        <!-- Text Input Pill -->
        <div class="flex-1 bg-transparent border border-[#232532] rounded-full px-4 py-2.5 flex items-center focus-within:border-gray-500 transition-colors">
          <input
            v-model="messageText"
            type="text"
            placeholder="Escribe un mensaje"
            class="w-full bg-transparent text-sm text-gray-100 placeholder:text-gray-500 focus:outline-none"
          />
        </div>

        <!-- Send Button Circle -->
        <button
          type="submit"
          :disabled="!messageText.trim()"
          class="w-10 h-10 rounded-full bg-[#161822] hover:bg-[#202230] disabled:opacity-40 disabled:cursor-not-allowed flex items-center justify-center text-[#f0254c] transition-all active:scale-95 cursor-pointer shrink-0 border border-[#262838]"
          title="Enviar mensaje"
        >
          <Send class="w-4 h-4 ml-0.5 text-[#f0254c]" />
        </button>
      </form>
    </div>
  </main>
</template>
