<script setup lang="ts">
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { ArrowLeft, Send, MoreHorizontal, Users } from 'lucide-vue-next'
import Avatar from '../common/Avatar.vue'
import GroupInfoView from './GroupInfoView.vue'
import type { Conversation } from '../../types'

interface Props {
  conversation: Conversation
}

const props = defineProps<Props>()

const emit = defineEmits<{
  (e: 'back'): void
  (e: 'send-message', text: string): void
  (e: 'clear-chat'): void
  (e: 'delete-chat'): void
  (e: 'leave-group'): void
}>()

const isGroup = computed(() => {
  return !!(
    props.conversation.isGroup ||
    props.conversation.id === 'equipo-encontrado' ||
    props.conversation.id.startsWith('group-')
  )
})

const showGroupInfo = ref(false)

watch(() => props.conversation.id, () => {
  showGroupInfo.value = false
})

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

const handleLeaveGroup = () => {
  emit('leave-group')
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
  <div class="flex-1 flex flex-col h-[calc(100vh-2rem)] lg:h-[calc(100vh-2.5rem)] sticky top-4 lg:top-5 rounded-2xl lg:rounded-3xl border border-[#1f212a] bg-black overflow-hidden shadow-lg relative">
    <Transition name="conversation-slide" mode="out-in">
      <!-- Group Info View when header is clicked -->
      <GroupInfoView
        v-if="showGroupInfo"
        key="group-info-view"
        :conversation="conversation"
        @back="showGroupInfo = false"
      />

      <!-- Main Conversation Chat Room -->
      <div
        v-else
        key="conversation-main-view"
        class="flex-1 flex flex-col h-full overflow-hidden"
      >
        <!-- Top Header -->
        <header class="h-16 px-4 sm:px-6 border-b border-[#1f212a] flex items-center justify-between shrink-0 bg-black/90 backdrop-blur-md z-10 select-none">
          <div class="flex items-center gap-3 min-w-0">
            <!-- Back button (mobile) -->
            <button
              type="button"
              @click="emit('back')"
              class="md:hidden p-2 rounded-full text-gray-400 hover:text-white"
            >
              <ArrowLeft class="w-5 h-5" />
            </button>

            <!-- Group or Individual Profile Clickable Header Area -->
            <div
              class="flex items-center gap-3 min-w-0"
              :class="isGroup ? 'cursor-pointer group' : ''"
              @click="isGroup ? showGroupInfo = true : null"
              :title="isGroup ? 'Ver información del grupo' : ''"
            >
              <!-- Group Avatar or Single Avatar -->
              <div
                v-if="isGroup"
                class="w-9 h-9 rounded-full bg-[#5a0f14] border border-[#79141b] flex items-center justify-center shrink-0 text-white group-hover:brightness-110 transition-all"
              >
                <Users class="w-4.5 h-4.5 text-white/90" />
              </div>
              <Avatar
                v-else
                size="sm"
                :is-tracon-official="conversation.isTraconOfficial"
              />

              <div class="min-w-0">
                <div class="flex items-center gap-2">
                  <h3 class="text-sm font-bold text-white truncate group-hover:text-gray-200 transition-colors">
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
              <!-- For Groups: Only show 'Salir del grupo' -->
              <template v-if="isGroup">
                <button
                  type="button"
                  @click="handleLeaveGroup"
                  class="w-full text-left px-5 py-3.5 text-[17px] font-normal text-white hover:bg-white/[0.06] transition-colors cursor-pointer"
                >
                  Salir del grupo
                </button>
              </template>

              <!-- For 1-on-1 Direct Chats: show 'Vaciar chat' and 'Eliminar chat' -->
              <template v-else>
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
              </template>
            </div>
          </div>
        </header>

        <!-- Messages Container -->
        <div class="flex-1 overflow-y-auto p-4 sm:p-6 space-y-3.5 select-text">
          <div
            v-for="msg in conversation.messages"
            :key="msg.id"
            class="flex flex-col select-text"
            :class="msg.isMine ? 'items-end' : 'items-start'"
          >
            <div
              class="max-w-[270px] sm:max-w-[290px] px-3.5 py-2 rounded-2xl text-sm leading-relaxed select-text cursor-text"
              :class="[
                msg.isMine
                  ? 'bg-[#79141B] text-white rounded-br-sm'
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
        <div class="p-4 border-t border-[#1f212a] bg-black">
          <form
            @submit.prevent="handleSend"
            class="flex items-center gap-2 bg-[#121319] border border-[#20222e] rounded-full pl-5 pr-1.5 py-1.5 focus-within:border-gray-600 transition-colors"
          >
            <input
              v-model="newMessageText"
              type="text"
              placeholder="Escribe un mensaje..."
              class="flex-1 bg-transparent text-sm text-gray-100 placeholder:text-gray-500 focus:outline-none py-1"
            />

            <button
              type="submit"
              :disabled="!newMessageText.trim()"
              class="w-8 h-8 rounded-full bg-[#f0254c] hover:bg-[#d9193f] text-white disabled:opacity-30 disabled:cursor-not-allowed transition-all cursor-pointer shrink-0 flex items-center justify-center shadow-sm"
              title="Enviar mensaje"
            >
              <Send class="w-4 h-4 text-white -translate-x-px translate-y-px" />
            </button>
          </form>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.conversation-slide-enter-active,
.conversation-slide-leave-active {
  transition: opacity 240ms cubic-bezier(0.23, 1, 0.32, 1), transform 240ms cubic-bezier(0.23, 1, 0.32, 1);
  will-change: opacity, transform;
}

.conversation-slide-leave-active {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 0;
}

.conversation-slide-enter-active {
  z-index: 10;
}

.conversation-slide-enter-from {
  opacity: 0;
  transform: translateY(8px) scale(0.995);
}

.conversation-slide-leave-to {
  opacity: 0;
  transform: translateY(-8px) scale(0.995);
}

@media (prefers-reduced-motion: reduce) {
  .conversation-slide-enter-active,
  .conversation-slide-leave-active {
    transition: opacity 150ms ease;
    transform: none;
  }
}
</style>
