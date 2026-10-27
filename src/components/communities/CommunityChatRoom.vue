<script setup lang="ts">
import { ref, computed, nextTick, onMounted, onUnmounted } from 'vue'
import {
  ChevronLeft,
  MoreHorizontal,
  PlusCircle,
  Send,
  Hash,
  Image as ImageIcon,
  Megaphone,
  Video,
  X,
} from 'lucide-vue-next'
import CommunityMultimediaView from './CommunityMultimediaView.vue'
import CommunityAnnouncementsView from './CommunityAnnouncementsView.vue'
import CommunityProfileView from './CommunityProfileView.vue'
import type { CommunityDetail, CommunityChannelMessage } from '../../types'

interface Props {
  community: CommunityDetail
}

const props = defineProps<Props>()

const emit = defineEmits<{
  (e: 'back'): void
  (e: 'send-message', text: string): void
  (e: 'leave'): void
}>()

interface AttachedMedia {
  type: 'image' | 'video'
  url: string
  name: string
  file?: File
}

const activeChannel = ref(props.community.activeChannel || 'general')
const messageText = ref('')
const messagesList = ref<CommunityChannelMessage[]>([...props.community.messages])
const messagesContainer = ref<HTMLElement | null>(null)
const showCommunityProfile = ref(false)

// Media attachments state
const isAttachMenuOpen = ref(false)
const attachMenuRef = ref<HTMLElement | null>(null)
const imageFileInputRef = ref<HTMLInputElement | null>(null)
const videoFileInputRef = ref<HTMLInputElement | null>(null)
const attachedMedia = ref<AttachedMedia | null>(null)

// Lightbox media preview
const previewMedia = ref<{ url: string; type: 'image' | 'video' } | null>(null)

const scrollToBottom = () => {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
    }
  })
}

// 3-dots dropdown menu state
const isMenuOpen = ref(false)
const menuRef = ref<HTMLElement | null>(null)

const toggleMenu = () => {
  isMenuOpen.value = !isMenuOpen.value
}

const handleViewProfile = () => {
  isMenuOpen.value = false
  showCommunityProfile.value = true
}

const handleOpenChatFromProfile = (channelId?: string) => {
  if (channelId) {
    activeChannel.value = channelId
  }
  showCommunityProfile.value = false
}

const handleLeave = () => {
  isMenuOpen.value = false
  emit('leave')
  emit('back')
}

// Attach menu actions
const toggleAttachMenu = () => {
  isAttachMenuOpen.value = !isAttachMenuOpen.value
}

const triggerSelectImage = () => {
  isAttachMenuOpen.value = false
  imageFileInputRef.value?.click()
}

const triggerSelectVideo = () => {
  isAttachMenuOpen.value = false
  videoFileInputRef.value?.click()
}

const handleImageFileSelected = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (file) {
    const reader = new FileReader()
    reader.onload = (ev) => {
      attachedMedia.value = {
        type: 'image',
        url: ev.target?.result as string,
        name: file.name,
        file,
      }
    }
    reader.readAsDataURL(file)
  }
  if (imageFileInputRef.value) {
    imageFileInputRef.value.value = ''
  }
}

const handleVideoFileSelected = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (file) {
    const url = URL.createObjectURL(file)
    attachedMedia.value = {
      type: 'video',
      url,
      name: file.name,
      file,
    }
  }
  if (videoFileInputRef.value) {
    videoFileInputRef.value.value = ''
  }
}

const removeAttachedMedia = () => {
  attachedMedia.value = null
}

const handleClickOutside = (e: MouseEvent) => {
  if (menuRef.value && !menuRef.value.contains(e.target as Node)) {
    isMenuOpen.value = false
  }
  if (attachMenuRef.value && !attachMenuRef.value.contains(e.target as Node)) {
    isAttachMenuOpen.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
  scrollToBottom()
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})

const canSend = computed(() => {
  return messageText.value.trim().length > 0 || attachedMedia.value !== null
})

const handleSend = () => {
  if (!canSend.value) return
  const now = new Date()
  const timeStr = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`

  const newMsg: CommunityChannelMessage = {
    id: `cm-${Date.now()}`,
    authorName: 'Jeffrey Suárez',
    avatarBg: '#f0254c',
    timestamp: timeStr,
    isMine: true,
  }

  if (messageText.value.trim()) {
    newMsg.text = messageText.value.trim()
  }

  if (attachedMedia.value) {
    newMsg.mediaUrl = attachedMedia.value.url
    newMsg.mediaType = attachedMedia.value.type
    newMsg.mediaName = attachedMedia.value.name
  }

  messagesList.value.push(newMsg)
  emit('send-message', newMsg.text || (newMsg.mediaType === 'image' ? '[Imagen]' : '[Video]'))

  messageText.value = ''
  attachedMedia.value = null
  isAttachMenuOpen.value = false
  scrollToBottom()
}
</script>

<template>
  <main
    class="flex-1 min-w-0 rounded-2xl lg:rounded-3xl border border-[#1f212a] bg-black overflow-hidden flex flex-col h-[calc(100vh-2rem)] lg:h-[calc(100vh-2.5rem)] sticky top-4 lg:top-5 shadow-lg relative"
  >
    <Transition name="profile-fade" mode="out-in">
      <!-- 1. PERFIL DE COMUNIDAD (cuando se hace clic en nombre o 'ver perfil') -->
      <CommunityProfileView
        v-if="showCommunityProfile"
        key="community-profile-view"
        :community="community"
        @back="showCommunityProfile = false"
        @open-chat="handleOpenChatFromProfile"
        @leave="handleLeave"
      />

      <!-- 2. SALA DE CHAT Y CANALES DE COMUNIDAD -->
      <div
        v-else
        key="community-chat-room-view"
        class="flex-1 flex flex-col h-full overflow-hidden"
      >
        <!-- Top Header -->
        <header class="h-16 px-4 sm:px-5 border-b border-[#1f212a] flex items-center justify-between shrink-0 bg-black/90 backdrop-blur-md z-30 select-none relative">
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

            <!-- Clickable Community Avatar + Name leading to Community Profile -->
            <div
              @click="showCommunityProfile = true"
              class="flex items-center gap-3 min-w-0 cursor-pointer group hover:opacity-90 transition-opacity"
              title="Ver perfil de la comunidad"
            >
              <!-- Community Avatar in header matching Image -->
              <div class="w-9 h-9 sm:w-10 sm:h-10 rounded-full border border-[#262835] bg-[#220d12] shrink-0 flex items-center justify-center overflow-hidden group-hover:border-red-500/50 transition-colors">
                <div class="w-full h-full bg-gradient-to-br from-[#591421] to-[#1a0509] flex items-center justify-center">
                  <span class="text-xs font-bold text-red-300">SZ</span>
                </div>
              </div>

              <div class="min-w-0">
                <h2 class="text-base sm:text-lg font-bold text-white tracking-tight truncate leading-tight group-hover:text-red-200 transition-colors">
                  {{ community.name }}
                </h2>
                <p class="text-xs text-gray-400 truncate mt-0.5">
                  {{ activeChannel === 'general' ? '#General' : activeChannel === 'multimedia' ? 'Multimedia' : 'Anuncios' }} · {{ community.membersCount }}
                </p>
              </div>
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
    <div class="relative flex border-b border-[#15161e] px-2 bg-black/85 backdrop-blur-md shrink-0 select-none z-10">
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

    <!-- Active Channel Body with Smooth Transition -->
    <div class="flex-1 overflow-hidden relative flex flex-col">
      <Transition name="channel-fade" mode="out-in">
        <!-- 1. GENERAL CHAT -->
        <div
          v-if="activeChannel === 'general'"
          key="channel-general"
          class="flex-1 flex flex-col h-full overflow-hidden"
        >
          <!-- Messages Feed -->
          <div
            ref="messagesContainer"
            class="flex-1 overflow-y-auto no-scrollbar p-4 sm:p-6 space-y-3.5 select-text"
          >
            <template v-for="msg in messagesList" :key="msg.id">
              <!-- Date Header Separator -->
              <div
                v-if="msg.dateHeader"
                class="text-center text-xs text-gray-500 font-medium my-3 select-none tracking-wide"
              >
                {{ msg.dateHeader }}
              </div>

              <!-- My Message Bubble (Right aligned with #79141B, exactly like Chats) -->
              <div
                v-if="msg.isMine"
                class="flex flex-col items-end select-text"
              >
                <div
                  class="max-w-[280px] sm:max-w-[340px] rounded-2xl rounded-br-sm text-sm leading-relaxed bg-[#79141B] text-white select-text cursor-text break-words shadow-sm overflow-hidden"
                  :class="msg.mediaUrl ? 'p-1.5' : 'px-3.5 py-2'"
                >
                  <!-- Attached media if present -->
                  <div v-if="msg.mediaUrl" class="rounded-xl overflow-hidden bg-black/40 mb-1">
                    <img
                      v-if="msg.mediaType === 'image'"
                      :src="msg.mediaUrl"
                      alt="Imagen compartida"
                      class="w-full max-h-72 object-cover rounded-xl cursor-pointer hover:opacity-95 transition-opacity"
                      @click="previewMedia = { url: msg.mediaUrl, type: 'image' }"
                    />
                    <video
                      v-else-if="msg.mediaType === 'video'"
                      :src="msg.mediaUrl"
                      controls
                      class="w-full max-h-72 rounded-xl bg-black"
                    />
                  </div>

                  <!-- Text if present -->
                  <p v-if="msg.text" :class="msg.mediaUrl ? 'px-2 py-1' : ''">
                    {{ msg.text }}
                  </p>
                </div>
                <span
                  v-if="msg.timestamp"
                  class="text-[11px] text-gray-500 mt-1 px-1"
                >
                  {{ msg.timestamp }}
                </span>
              </div>

              <!-- Others' Message Row (Community channel layout on the left) -->
              <div
                v-else
                class="flex items-start gap-3 group hover:bg-white/[0.015] -mx-2 px-2 py-1.5 rounded-xl transition-colors select-text"
              >
                <div
                  class="w-10 h-10 rounded-full border border-[#262835] shrink-0 mt-0.5 flex items-center justify-center select-none"
                  :style="{ backgroundColor: msg.avatarBg || '#1a1b24' }"
                >
                  <div class="w-3.5 h-3.5 rounded-full bg-white/10" />
                </div>

                <div class="flex-1 min-w-0 select-text">
                  <span class="font-bold text-[15px] text-white tracking-wide block select-text">
                    {{ msg.authorName }}
                  </span>

                  <!-- Attached media if present -->
                  <div v-if="msg.mediaUrl" class="mt-2 max-w-[280px] sm:max-w-[340px] rounded-xl overflow-hidden bg-black/40 border border-[#262835]">
                    <img
                      v-if="msg.mediaType === 'image'"
                      :src="msg.mediaUrl"
                      alt="Imagen compartida"
                      class="w-full max-h-72 object-cover rounded-xl cursor-pointer hover:opacity-95 transition-opacity"
                      @click="previewMedia = { url: msg.mediaUrl, type: 'image' }"
                    />
                    <video
                      v-else-if="msg.mediaType === 'video'"
                      :src="msg.mediaUrl"
                      controls
                      class="w-full max-h-72 rounded-xl bg-black"
                    />
                  </div>

                  <p v-if="msg.text" class="text-[14px] text-gray-200 mt-0.5 leading-relaxed break-words select-text cursor-text">
                    {{ msg.text }}
                  </p>
                </div>
              </div>
            </template>
          </div>

          <!-- Bottom Input Bar -->
          <div class="p-4 border-t border-[#1f212a] bg-black shrink-0 relative">
            <!-- Hidden file inputs -->
            <input
              ref="imageFileInputRef"
              type="file"
              accept="image/*"
              class="hidden"
              @change="handleImageFileSelected"
            />
            <input
              ref="videoFileInputRef"
              type="file"
              accept="video/*"
              class="hidden"
              @change="handleVideoFileSelected"
            />

            <!-- Selected Media Preview -->
            <div
              v-if="attachedMedia"
              class="mb-3 p-2.5 rounded-2xl bg-[#16121a] border border-[#2d1b28] flex items-center justify-between gap-3 shadow-md"
            >
              <div class="flex items-center gap-3 min-w-0">
                <div class="relative w-14 h-14 rounded-xl overflow-hidden bg-black shrink-0 border border-white/10 flex items-center justify-center">
                  <img
                    v-if="attachedMedia.type === 'image'"
                    :src="attachedMedia.url"
                    alt="Vista previa"
                    class="w-full h-full object-cover"
                  />
                  <div
                    v-else
                    class="w-full h-full flex flex-col items-center justify-center bg-gradient-to-br from-[#1d1222] to-black text-sky-400"
                  >
                    <Video class="w-6 h-6" />
                  </div>
                </div>
                <div class="min-w-0">
                  <div class="flex items-center gap-1.5">
                    <span
                      class="text-[10px] uppercase font-bold tracking-wider px-2 py-0.5 rounded-md"
                      :class="attachedMedia.type === 'image' ? 'bg-[#f0254c]/20 text-[#f0254c]' : 'bg-sky-500/20 text-sky-400'"
                    >
                      {{ attachedMedia.type === 'image' ? 'Imagen' : 'Video' }}
                    </span>
                  </div>
                  <p class="text-xs text-gray-200 font-medium truncate mt-1">
                    {{ attachedMedia.name }}
                  </p>
                </div>
              </div>
              <button
                type="button"
                @click="removeAttachedMedia"
                class="p-1.5 rounded-full text-gray-400 hover:text-white hover:bg-white/10 transition-colors cursor-pointer shrink-0"
                title="Quitar archivo"
              >
                <X class="w-4 h-4" />
              </button>
            </div>

            <!-- Input Form -->
            <form
              @submit.prevent="handleSend"
              class="flex items-center gap-3 relative"
            >
              <!-- Attachment Button with Dropdown (+) -->
              <div ref="attachMenuRef" class="relative">
                <button
                  type="button"
                  @click.stop="toggleAttachMenu"
                  class="text-gray-400 hover:text-white transition-colors cursor-pointer shrink-0 flex items-center justify-center"
                  :class="isAttachMenuOpen ? 'text-[#f0254c]' : ''"
                  title="Adjuntar imagen o video"
                >
                  <PlusCircle class="w-6 h-6" />
                </button>

                <!-- Popover Menu with Options -->
                <Transition name="popover-fade">
                  <div
                    v-if="isAttachMenuOpen"
                    class="absolute bottom-full left-0 mb-3 w-48 rounded-2xl bg-[#161219] border border-[#2d1b28] p-1.5 shadow-2xl shadow-black/95 z-50 flex flex-col gap-1 backdrop-blur-md"
                  >
                    <button
                      type="button"
                      @click="triggerSelectImage"
                      class="w-full flex items-center gap-3 px-3 py-2.5 text-xs sm:text-sm font-semibold text-gray-200 hover:text-white hover:bg-white/10 rounded-xl transition-colors cursor-pointer text-left"
                    >
                      <div class="w-8 h-8 rounded-lg bg-[#28131e] text-[#f0254c] flex items-center justify-center shrink-0 border border-[#f0254c]/20">
                        <ImageIcon class="w-4 h-4" />
                      </div>
                      <span>Foto o imagen</span>
                    </button>

                    <button
                      type="button"
                      @click="triggerSelectVideo"
                      class="w-full flex items-center gap-3 px-3 py-2.5 text-xs sm:text-sm font-semibold text-gray-200 hover:text-white hover:bg-white/10 rounded-xl transition-colors cursor-pointer text-left"
                    >
                      <div class="w-8 h-8 rounded-lg bg-[#141b2b] text-sky-400 flex items-center justify-center shrink-0 border border-sky-500/20">
                        <Video class="w-4 h-4" />
                      </div>
                      <span>Video</span>
                    </button>
                  </div>
                </Transition>
              </div>

              <!-- Text Input -->
              <div class="flex-1 bg-[#121319] border border-[#20222e] rounded-full pl-4 pr-1.5 py-1.5 flex items-center gap-2 focus-within:border-gray-600 transition-colors">
                <input
                  v-model="messageText"
                  type="text"
                  placeholder="Escribe un mensaje..."
                  class="flex-1 bg-transparent text-sm text-gray-100 placeholder:text-gray-500 focus:outline-none py-1"
                />

                <button
                  type="submit"
                  :disabled="!canSend"
                  class="w-8 h-8 rounded-full bg-[#f0254c] hover:bg-[#d9193f] text-white disabled:opacity-30 disabled:cursor-not-allowed transition-all cursor-pointer shrink-0 flex items-center justify-center shadow-sm"
                  title="Enviar mensaje"
                >
                  <Send class="w-4 h-4 text-white -translate-x-px translate-y-px" />
                </button>
              </div>
            </form>
          </div>
        </div>

        <!-- 2. MULTIMEDIA VIEW -->
        <CommunityMultimediaView
          v-else-if="activeChannel === 'multimedia'"
          key="channel-multimedia"
          :community-name="community.name"
        />

        <!-- 3. ANUNCIOS VIEW -->
        <CommunityAnnouncementsView
          v-else-if="activeChannel === 'anuncios'"
          key="channel-anuncios"
          :community-name="community.name"
        />
      </Transition>
    </div>
  </div>
</Transition>

<!-- Media Lightbox Modal -->
<Transition name="fade-modal">
  <div
    v-if="previewMedia"
    class="fixed inset-0 z-50 bg-black/90 backdrop-blur-sm flex items-center justify-center p-4"
    @click="previewMedia = null"
  >
    <button
      type="button"
      class="absolute top-4 right-4 p-2.5 rounded-full bg-white/10 text-white hover:bg-white/20 transition-colors cursor-pointer z-10"
      @click="previewMedia = null"
      title="Cerrar"
    >
      <X class="w-6 h-6" />
    </button>

    <div class="max-w-4xl max-h-[85vh] overflow-hidden rounded-2xl flex items-center justify-center" @click.stop>
      <img
        v-if="previewMedia.type === 'image'"
        :src="previewMedia.url"
        alt="Vista previa ampliada"
        class="max-w-full max-h-[85vh] object-contain rounded-2xl shadow-2xl"
      />
      <video
        v-else
        :src="previewMedia.url"
        controls
        autoplay
        class="max-w-full max-h-[85vh] object-contain rounded-2xl shadow-2xl bg-black"
      />
    </div>
  </div>
</Transition>
</main>
</template>

<style scoped>
.channel-fade-enter-active,
.channel-fade-leave-active,
.profile-fade-enter-active,
.profile-fade-leave-active {
  transition: opacity 240ms cubic-bezier(0.23, 1, 0.32, 1), transform 240ms cubic-bezier(0.23, 1, 0.32, 1);
  will-change: opacity, transform;
}

.channel-fade-leave-active,
.profile-fade-leave-active {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 0;
}

.channel-fade-enter-active,
.profile-fade-enter-active {
  z-index: 10;
}

.channel-fade-enter-from,
.profile-fade-enter-from {
  opacity: 0;
  transform: translateY(8px) scale(0.995);
}

.channel-fade-leave-to,
.profile-fade-leave-to {
  opacity: 0;
  transform: translateY(-8px) scale(0.995);
}

.popover-fade-enter-active,
.popover-fade-leave-active,
.fade-modal-enter-active,
.fade-modal-leave-active {
  transition: opacity 180ms cubic-bezier(0.23, 1, 0.32, 1), transform 180ms cubic-bezier(0.23, 1, 0.32, 1);
}

.popover-fade-enter-from,
.popover-fade-leave-to {
  opacity: 0;
  transform: translateY(6px) scale(0.96);
}

.fade-modal-enter-from,
.fade-modal-leave-to {
  opacity: 0;
  transform: scale(0.97);
}

@media (prefers-reduced-motion: reduce) {
  .channel-fade-enter-active,
  .channel-fade-leave-active,
  .profile-fade-enter-active,
  .profile-fade-leave-active,
  .popover-fade-enter-active,
  .popover-fade-leave-active,
  .fade-modal-enter-active,
  .fade-modal-leave-active {
    transition: opacity 150ms ease;
    transform: none;
  }
}
</style>
