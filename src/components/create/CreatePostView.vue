<script setup lang="ts">
import { ref, computed, nextTick } from 'vue'
import CreatePollView from './CreatePollView.vue'
import MentionPickerView from './MentionPickerView.vue'
import GameSelectorView from '../common/GameSelectorView.vue'
import TrakRecorderView from './TrakRecorderView.vue'
import {
  X,
  MapPin,
  Gamepad2,
  ImageIcon,
  Video,
  BarChart2,
  Hash,
  AtSign,
  Trophy,
  User,
  Plus,
  Trash2,
  Check,
} from 'lucide-vue-next'
import type { Post, PollData } from '../../types'

interface Props {
  userName?: string
  userHandle?: string
}

const props = withDefaults(defineProps<Props>(), {
  userName: 'Jeffrey Suárez',
  userHandle: 'SuarezCata655',
})

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'published', post: Post): void
}>()

// Active tab: 'publicacion' | 'trak'
const activeTab = ref<'publicacion' | 'trak'>('publicacion')

// Publication form state
const textContent = ref('')
const textareaRef = ref<HTMLTextAreaElement | null>(null)
const selectedGame = ref<string | null>(null)
const selectedLocation = ref<string | null>(null)

// Challenge / Reto state
const isChallengeActive = ref(false)
const challengeTitle = ref('')
const challengeTitleInputRef = ref<HTMLInputElement | null>(null)

const toggleChallenge = () => {
  isChallengeActive.value = !isChallengeActive.value
  if (isChallengeActive.value) {
    attachedPoll.value = null
    nextTick(() => {
      challengeTitleInputRef.value?.focus()
    })
  } else {
    challengeTitle.value = ''
  }
}

// Media attachments
const imageInputRef = ref<HTMLInputElement | null>(null)
const videoInputRef = ref<HTMLInputElement | null>(null)
const attachedImages = ref<string[]>([])
const attachedVideoName = ref<string | null>(null)

// Poll state
const isCreatingPoll = ref(false)
const attachedPoll = ref<PollData | null>(null)

// Mention state
const isMentioning = ref(false)

// Game selector state
const isSelectingGame = ref(false)

// Modals / Popovers
const isLocationModalOpen = ref(false)

const popularLocations = [
  'Medellín, Colombia',
  'Bogotá, Colombia',
  'Buenos Aires, Argentina',
  'Ciudad de México, México',
  'En vivo / Transmisión',
  'Servidor Oficial Tracon',
]

// Can publish computation
const canPublish = computed(() => {
  if (isChallengeActive.value) {
    return challengeTitle.value.trim().length > 0 && textContent.value.trim().length > 0
  }
  return (
    (attachedPoll.value !== null && !!attachedPoll.value.question) ||
    textContent.value.trim().length > 0 ||
    attachedImages.value.length > 0 ||
    attachedVideoName.value !== null
  )
})

// Handlers for media
const triggerImagePicker = () => {
  imageInputRef.value?.click()
}

const handleImageChange = (e: Event) => {
  const target = e.target as HTMLInputElement
  if (target.files && target.files.length > 0) {
    for (let i = 0; i < target.files.length; i++) {
      const file = target.files[i]
      const reader = new FileReader()
      reader.onload = (event) => {
        if (event.target?.result) {
          attachedImages.value.push(event.target.result as string)
        }
      }
      reader.readAsDataURL(file)
    }
  }
}

const removeImage = (index: number) => {
  attachedImages.value.splice(index, 1)
}

const triggerVideoPicker = () => {
  videoInputRef.value?.click()
}

const handleVideoChange = (e: Event) => {
  const target = e.target as HTMLInputElement
  if (target.files && target.files[0]) {
    attachedVideoName.value = target.files[0].name
  }
}

// Poll handlers
const openPollCreator = () => {
  if (isChallengeActive.value) return
  isCreatingPoll.value = true
}

const handlePollSaved = (poll: PollData) => {
  attachedPoll.value = poll
  isCreatingPoll.value = false
}

const removeAttachedPoll = () => {
  attachedPoll.value = null
}

// Quick insertion helpers
const handleHashClick = () => {
  const el = textareaRef.value
  if (!el) {
    textContent.value = textContent.value ? `${textContent.value} #` : '#'
    return
  }

  const start = el.selectionStart ?? textContent.value.length
  const end = el.selectionEnd ?? textContent.value.length
  const before = textContent.value.substring(0, start)
  const after = textContent.value.substring(end)
  const prefix = (before.length > 0 && !before.endsWith(' ') && !before.endsWith('\n')) ? ' #' : '#'

  textContent.value = before + prefix + after

  nextTick(() => {
    el.focus()
    const newPos = start + prefix.length
    el.setSelectionRange(newPos, newPos)
  })
}

const handleAtClick = () => {
  isMentioning.value = true
}

const handleMentionSelected = (handle: string) => {
  const mentionText = `@${handle} `

  // If poll is attached, append mention into poll question
  if (attachedPoll.value) {
    attachedPoll.value.question = attachedPoll.value.question
      ? `${attachedPoll.value.question} ${mentionText}`
      : mentionText
    isMentioning.value = false
    return
  }

  const el = textareaRef.value
  if (!el) {
    textContent.value = textContent.value ? `${textContent.value} ${mentionText}` : mentionText
    isMentioning.value = false
    return
  }

  const start = el.selectionStart ?? textContent.value.length
  const end = el.selectionEnd ?? textContent.value.length
  const before = textContent.value.substring(0, start)
  const after = textContent.value.substring(end)
  const prefix = (before.length > 0 && !before.endsWith(' ') && !before.endsWith('\n')) ? ' ' : ''

  textContent.value = before + prefix + mentionText + after
  isMentioning.value = false

  nextTick(() => {
    el.focus()
    const newPos = start + prefix.length + mentionText.length
    el.setSelectionRange(newPos, newPos)
  })
}

const handleGameSelected = (gameName: string | null) => {
  selectedGame.value = gameName
  isSelectingGame.value = false
}

const selectLocation = (loc: string) => {
  selectedLocation.value = loc
  isLocationModalOpen.value = false
}

// Publish action
const handlePublish = () => {
  if (!canPublish.value) return

  const publishedContent = attachedPoll.value?.question
    ? attachedPoll.value.question
    : textContent.value.trim()

  const newPost: Post = {
    id: `post-${Date.now()}`,
    author: {
      name: props.userName,
      handle: props.userHandle,
    },
    timeAgo: 'ahora',
    content: publishedContent,
    gameTag: selectedGame.value || undefined,
    locationTag: selectedLocation.value || undefined,
    challengeTag: isChallengeActive.value && challengeTitle.value.trim() ? challengeTitle.value.trim() : undefined,
    challengeData: isChallengeActive.value && challengeTitle.value.trim() ? {
      title: challengeTitle.value.trim(),
      rules: textContent.value.trim(),
    } : undefined,
    mediaUrl: attachedImages.value[0] || undefined,
    poll: attachedPoll.value || undefined,
    stats: {
      comments: 0,
      likes: 0,
      impulses: 0,
      isLiked: false,
      isImpulsed: false,
      isSaved: false,
    },
  }
  emit('published', newPost)
}

const handleTrakPublished = (post: Post) => {
  emit('published', post)
}
</script>

<template>
  <main
    class="flex-1 min-w-0 rounded-2xl lg:rounded-3xl border border-[#1f212a] bg-black overflow-hidden flex flex-col h-[calc(100vh-2rem)] lg:h-[calc(100vh-2.5rem)] sticky top-4 lg:top-5 shadow-2xl relative select-none"
  >
    <!-- Screen: Crear Encuesta / Mención (replaces current view with smooth transition) -->
    <Transition name="view-slide" mode="out-in">
      <CreatePollView
        v-if="isCreatingPoll"
        key="create-poll-view"
        :initial-poll="attachedPoll"
        @cancel="isCreatingPoll = false"
        @save="handlePollSaved"
      />

      <MentionPickerView
        v-else-if="isMentioning"
        key="mention-picker-view"
        @cancel="isMentioning = false"
        @select="handleMentionSelected"
      />

      <GameSelectorView
        v-else-if="isSelectingGame"
        key="game-selector-view"
        :initial-selected-game="selectedGame"
        @cancel="isSelectingGame = false"
        @select="handleGameSelected"
      />

      <TrakRecorderView
        v-else-if="activeTab === 'trak'"
        key="trak-recorder-view"
        :user-name="props.userName"
        :user-handle="props.userHandle"
        @close="emit('close')"
        @switch-tab="activeTab = $event"
        @published="handleTrakPublished"
      />

      <div
        v-else
        key="create-post-main-view"
        class="flex-1 flex flex-col h-full overflow-hidden"
      >
        <!-- Hidden file inputs -->
        <input
          ref="imageInputRef"
      type="file"
      accept="image/*"
      multiple
      class="hidden"
      @change="handleImageChange"
    />
    <input
      ref="videoInputRef"
      type="file"
      accept="video/*"
      class="hidden"
      @change="handleVideoChange"
    />

    <!-- Header Section -->
    <header class="border-b border-[#1f212a] bg-black/90 backdrop-blur-md z-20">
      <!-- Top Bar: "Crear contenido" (styled exactly like Chats header in ChatList) -->
      <div class="flex items-center justify-between px-4 sm:px-5 pt-4 pb-3">
        <h2 class="text-xl font-bold text-white tracking-tight">
          Crear contenido
        </h2>
      </div>

      <!-- Tabs Bar (Publicación vs Trak) minimalist like FeedTabs in inicio -->
      <nav class="relative flex items-center justify-around border-t border-[#15161e] select-none">
        <button
          type="button"
          @click="activeTab = 'publicacion'"
          class="relative flex-1 py-3.5 text-center text-sm font-semibold transition-colors duration-200 cursor-pointer text-white"
        >
          <span>Publicación</span>
        </button>

        <button
          type="button"
          @click="activeTab = 'trak'"
          class="relative flex-1 py-3.5 text-center text-sm font-semibold transition-colors duration-200 cursor-pointer text-gray-400 hover:text-gray-200"
        >
          <span>Trak</span>
        </button>

        <!-- Smooth sliding active underline indicator -->
        <span
          class="absolute bottom-0 h-[3px] w-14 rounded-full bg-[#f0254c] shadow-[0_0_10px_rgba(240,37,76,0.6)] transition-all duration-300 ease-[cubic-bezier(0.23,1,0.32,1)] -translate-x-1/2 pointer-events-none left-1/4"
        />
      </nav>
    </header>

    <!-- Content Area: Publicación -->
    <div class="flex-1 flex flex-col min-h-0 overflow-hidden relative">
      <div class="flex-1 flex flex-col min-h-0 overflow-hidden">
          <!-- Upper Author & Features Bar -->
          <div class="flex items-center justify-between px-5 pt-4 pb-2">
        <!-- Left: User Avatar + Crear reto pill -->
        <div class="flex items-center gap-3">
          <div class="relative">
            <div
              class="w-10 h-10 rounded-full bg-[#1e141a] border-2 border-[#79141b] flex items-center justify-center text-white font-bold text-sm shadow-[0_0_10px_rgba(121,20,27,0.4)]"
            >
              <User class="w-5 h-5 text-gray-300" />
            </div>
          </div>

          <!-- Crear reto button -->
          <button
            type="button"
            @click="toggleChallenge"
            :disabled="!!attachedPoll"
            class="flex items-center gap-1.5 text-xs font-semibold px-2.5 py-1 rounded-full border transition-all duration-200 select-none"
            :class="[
              attachedPoll
                ? 'opacity-40 cursor-not-allowed border-transparent text-gray-500'
                : isChallengeActive
                  ? 'bg-[#f0254c] text-white border-[#f0254c] shadow-[0_0_12px_rgba(240,37,76,0.35)] cursor-pointer'
                  : 'text-[#f0254c] hover:bg-[#f0254c]/10 border-transparent cursor-pointer'
            ]"
            :title="attachedPoll ? 'No disponible con encuesta adjunta' : (isChallengeActive ? 'Desactivar reto' : 'Crear reto')"
          >
            <Trophy class="w-3.5 h-3.5" :class="isChallengeActive ? 'text-white' : 'text-[#f0254c]'" />
            <span>{{ isChallengeActive ? 'Reto activo' : 'Crear reto' }}</span>
          </button>
        </div>

        <!-- Right: Location Pin & Game Controller Pill -->
        <div class="flex items-center gap-2">
          <!-- Location button -->
          <button
            type="button"
            @click="isLocationModalOpen = true"
            class="p-2 rounded-xl text-gray-400 hover:text-white hover:bg-white/5 transition-colors cursor-pointer"
            :class="selectedLocation ? 'text-cyan-400 bg-cyan-950/30' : ''"
            title="Añadir ubicación"
          >
            <MapPin class="w-5 h-5" />
          </button>

          <!-- Game Selector Pill -->
          <button
            type="button"
            @click="isSelectingGame = true"
            class="p-2.5 rounded-xl border transition-all duration-200 cursor-pointer flex items-center justify-center shadow-sm"
            :class="
              selectedGame
                ? 'bg-[#f0254c]/20 border-[#f0254c] text-white shadow-[0_0_10px_rgba(240,37,76,0.3)]'
                : 'bg-[#18131d] border-[#2b192c] text-gray-400 hover:text-white hover:border-[#f0254c]/60'
            "
            title="Seleccionar juego"
          >
            <Gamepad2 class="w-5 h-5" />
          </button>
        </div>
      </div>

      <!-- Active Tags / Badges Row -->
      <div
        v-if="selectedGame || selectedLocation || isChallengeActive"
        class="flex items-center gap-2 px-5 py-1.5 flex-wrap"
      >
        <!-- Game Chip -->
        <div
          v-if="selectedGame"
          class="flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#1a1420] border border-[#f0254c]/40 text-xs text-white"
        >
          <Gamepad2 class="w-3.5 h-3.5 text-[#f0254c]" />
          <span>{{ selectedGame }}</span>
          <button
            type="button"
            @click="selectedGame = null"
            class="text-gray-400 hover:text-white ml-1 text-sm font-bold"
          >
            ×
          </button>
        </div>

        <!-- Location Chip -->
        <div
          v-if="selectedLocation"
          class="flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#151922] border border-cyan-500/30 text-xs text-cyan-300"
        >
          <MapPin class="w-3.5 h-3.5 text-cyan-400" />
          <span>{{ selectedLocation }}</span>
          <button
            type="button"
            @click="selectedLocation = null"
            class="text-gray-400 hover:text-white ml-1 text-sm font-bold"
          >
            ×
          </button>
        </div>

        <!-- Challenge Chip -->
        <div
          v-if="isChallengeActive"
          class="flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#201416] border border-[#f0254c]/50 text-xs text-[#f0254c]"
        >
          <Trophy class="w-3.5 h-3.5 text-[#f0254c]" />
          <span>Reto: {{ challengeTitle }}</span>
          <button
            type="button"
            @click="isChallengeActive = false"
            class="text-gray-400 hover:text-white ml-1 text-sm font-bold"
          >
            ×
          </button>
        </div>
      </div>

      <!-- Main Input Content Area -->
      <div class="flex-1 px-5 py-2 overflow-y-auto no-scrollbar flex flex-col justify-between">
        <div class="space-y-4">
          <!-- When poll is attached: hide "¿Qué estás jugando?" and display poll card directly -->
          <div
            v-if="attachedPoll"
            class="p-4 sm:p-5 rounded-2xl bg-[#141018] border border-[#2d1b2e] space-y-3.5"
          >
            <div class="flex items-center justify-between pb-2.5 border-b border-[#231726]">
              <div class="flex items-center gap-2">
                <span class="p-1.5 rounded-lg bg-[#f0254c]/15 text-[#f0254c]">
                  <BarChart2 class="w-4 h-4" />
                </span>
                <span class="text-xs font-bold uppercase tracking-wider text-[#f0254c]">
                  Encuesta de la publicación
                </span>
              </div>
              <div class="flex items-center gap-3">
                <button
                  type="button"
                  @click="openPollCreator"
                  class="text-xs font-semibold text-gray-300 hover:text-white transition-colors cursor-pointer"
                >
                  Editar
                </button>
                <button
                  type="button"
                  @click="removeAttachedPoll"
                  class="text-xs font-semibold text-red-400 hover:text-red-300 transition-colors cursor-pointer flex items-center gap-1"
                  title="Eliminar encuesta"
                >
                  <Trash2 class="w-3.5 h-3.5" />
                  <span>Eliminar</span>
                </button>
              </div>
            </div>

            <p class="text-base sm:text-lg font-bold text-white tracking-wide leading-relaxed">
              {{ attachedPoll.question }}
            </p>

            <div class="space-y-2">
              <div
                v-for="(opt, idx) in attachedPoll.options"
                :key="opt.id"
                class="flex items-center gap-3 px-3.5 py-2.5 rounded-xl bg-black/60 border border-[#231726] text-sm text-gray-200"
              >
                <div
                  v-if="opt.imageUrl"
                  class="w-9 h-9 rounded-lg overflow-hidden shrink-0 border border-[#3b2440] bg-[#221627]"
                >
                  <img :src="opt.imageUrl" alt="Opción" class="w-full h-full object-cover" />
                </div>
                <span
                  v-else
                  class="w-6 h-6 rounded-full bg-[#79141b] text-white font-bold flex items-center justify-center text-xs shadow-sm shrink-0"
                >
                  {{ idx + 1 }}
                </span>
                <span class="font-medium truncate">{{ opt.text || `Opción ${idx + 1}` }}</span>
              </div>
            </div>
          </div>

          <!-- Main Text / Reto input area (only when poll is NOT attached) -->
          <div v-else class="space-y-3">
            <!-- Título del reto (only when isChallengeActive is true) -->
            <div v-if="isChallengeActive" class="pb-1">
              <input
                ref="challengeTitleInputRef"
                v-model="challengeTitle"
                type="text"
                maxlength="120"
                placeholder="Título del reto"
                class="w-full bg-transparent text-lg sm:text-xl font-bold text-white placeholder:text-gray-500 focus:outline-none pb-2 border-b border-[#2d1b2e] focus:border-[#f0254c]/70 transition-colors select-text"
              />
            </div>

            <!-- Textarea: Explica las reglas del reto when challenge is active, or ¿Qué estás jugando? -->
            <textarea
              ref="textareaRef"
              v-model="textContent"
              :placeholder="isChallengeActive ? 'Explica las reglas del reto' : '¿Qué estás jugando?'"
              maxlength="5000"
              rows="6"
              class="w-full bg-transparent text-white placeholder:text-gray-500 focus:outline-none resize-none text-[17px] leading-relaxed select-text"
            />
          </div>

          <!-- Attached Images Preview -->
          <div v-if="attachedImages.length > 0" class="grid grid-cols-2 sm:grid-cols-3 gap-2.5 pt-2">
            <div
              v-for="(img, idx) in attachedImages"
              :key="idx"
              class="relative rounded-xl overflow-hidden border border-[#2b2d38] aspect-video group bg-black"
            >
              <img :src="img" alt="Vista previa" class="w-full h-full object-cover" />
              <button
                type="button"
                @click="removeImage(idx)"
                class="absolute top-2 right-2 w-7 h-7 rounded-full bg-black/70 hover:bg-red-600 text-white flex items-center justify-center transition-colors"
              >
                <X class="w-4 h-4" />
              </button>
            </div>
          </div>

          <!-- Attached Video Preview -->
          <div
            v-if="attachedVideoName"
            class="p-3 rounded-xl bg-[#14151c] border border-[#232532] flex items-center justify-between"
          >
            <div class="flex items-center gap-3">
              <div class="p-2 rounded-lg bg-[#f0254c]/10 text-[#f0254c]">
                <Video class="w-5 h-5" />
              </div>
              <div>
                <p class="text-sm font-medium text-white truncate max-w-xs">{{ attachedVideoName }}</p>
                <p class="text-xs text-gray-400">Video listo para publicar</p>
              </div>
            </div>
            <button
              type="button"
              @click="attachedVideoName = null"
              class="text-gray-400 hover:text-red-400 p-1"
            >
              <Trash2 class="w-4 h-4" />
            </button>
          </div>
        </div>

        <!-- Character Counter -->
        <div class="flex justify-end py-2 text-xs text-gray-500 font-mono">
          {{ attachedPoll ? `${attachedPoll.question?.length || 0}/280` : `${textContent.length}/5000` }}
        </div>
      </div>
    </div>
  </div>

    <!-- Bottom Action Bar (Docked at bottom) -->
    <footer class="flex items-center justify-between px-5 sm:px-6 py-3 border-t border-[#181922] bg-black/80 backdrop-blur-md z-20">
      <!-- Left: Media Tool Icons + Hashtag & Mention -->
      <div class="flex items-center gap-5">
        <!-- Multimedia icons -->
        <div class="flex items-center gap-5">
          <button
            type="button"
            @click="triggerImagePicker"
            class="text-gray-400 hover:text-[#f0254c] transition-colors cursor-pointer"
            title="Añadir imágenes"
          >
            <ImageIcon class="w-5 h-5" />
          </button>

          <button
            type="button"
            @click="triggerVideoPicker"
            class="text-gray-400 hover:text-[#f0254c] transition-colors cursor-pointer"
            title="Añadir video"
          >
            <Video class="w-5 h-5" />
          </button>

          <button
            type="button"
            @click="openPollCreator"
            :disabled="isChallengeActive"
            class="transition-colors"
            :class="[
              isChallengeActive
                ? 'opacity-30 cursor-not-allowed text-gray-500 hover:text-gray-500'
                : attachedPoll
                  ? 'text-[#f0254c] cursor-pointer'
                  : 'text-gray-400 hover:text-[#f0254c] cursor-pointer'
            ]"
            :title="isChallengeActive ? 'No disponible al crear un reto' : 'Crear encuesta'"
          >
            <BarChart2 class="w-5 h-5" />
          </button>
        </div>

        <div class="h-5 w-px bg-[#232532]" />

        <!-- Hashtag & Mention -->
        <div class="flex items-center gap-5">
          <button
            type="button"
            @click="handleHashClick"
            class="text-gray-400 hover:text-[#f0254c] transition-colors cursor-pointer"
            title="Añadir hashtag (#)"
          >
            <Hash class="w-5 h-5" />
          </button>

          <button
            type="button"
            @click="handleAtClick"
            class="text-gray-400 hover:text-[#f0254c] transition-colors cursor-pointer"
            title="Mencionar jugador (@)"
          >
            <AtSign class="w-5 h-5" />
          </button>
        </div>
      </div>

      <!-- Right: Publicar Button (same styling as Crear in comunidades) -->
      <div class="flex items-center">
        <button
          type="button"
          @click="handlePublish"
          :disabled="!canPublish"
          class="px-5 py-2.5 rounded-full bg-[#f0254c] hover:bg-[#d9193f] text-white text-sm font-bold shadow-[0_4px_20px_rgba(240,37,76,0.4)] flex items-center gap-1.5 transition-all duration-200 active:scale-95 cursor-pointer disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:bg-[#f0254c]"
        >
          <Plus class="w-4 h-4" />
          <span>Publicar</span>
        </button>
      </div>
    </footer>

    <!-- MODAL 2: Location Picker -->
    <div
      v-if="isLocationModalOpen"
      class="absolute inset-0 bg-black/85 backdrop-blur-md z-30 flex items-center justify-center p-4"
    >
      <div class="w-full max-w-sm bg-[#111218] border border-[#232532] rounded-2xl overflow-hidden shadow-2xl">
        <div class="flex items-center justify-between p-4 border-b border-[#1f212a]">
          <h3 class="text-sm font-bold text-white flex items-center gap-2">
            <MapPin class="w-4 h-4 text-cyan-400" />
            Añadir Ubicación
          </h3>
          <button
            type="button"
            @click="isLocationModalOpen = false"
            class="text-gray-400 hover:text-white p-1"
          >
            <X class="w-5 h-5" />
          </button>
        </div>

        <div class="p-2 space-y-1">
          <button
            v-for="loc in popularLocations"
            :key="loc"
            type="button"
            @click="selectLocation(loc)"
            class="w-full flex items-center justify-between p-3 rounded-xl hover:bg-white/5 transition-colors text-left cursor-pointer group"
          >
            <span class="text-sm text-gray-300 group-hover:text-white">{{ loc }}</span>
            <Check v-if="selectedLocation === loc" class="w-4 h-4 text-cyan-400" />
          </button>
        </div>
      </div>
    </div>
    </div>
  </Transition>
  </main>
</template>

<style scoped>
.no-scrollbar::-webkit-scrollbar {
  display: none;
}
.no-scrollbar {
  -ms-overflow-style: none;
  scrollbar-width: none;
}

/* Canonical Tracon View & Subview Transitions */
.view-slide-enter-active,
.view-slide-leave-active {
  transition: opacity 240ms cubic-bezier(0.23, 1, 0.32, 1), transform 240ms cubic-bezier(0.23, 1, 0.32, 1);
  will-change: opacity, transform;
}

.view-slide-enter-from {
  opacity: 0;
  transform: translateY(10px) scale(0.995);
}

.view-slide-leave-to {
  opacity: 0;
  transform: translateY(-8px) scale(0.995);
}

.tab-fade-enter-active,
.tab-fade-leave-active {
  transition: opacity 180ms cubic-bezier(0.23, 1, 0.32, 1), transform 180ms cubic-bezier(0.23, 1, 0.32, 1);
}

.tab-fade-enter-from {
  opacity: 0;
  transform: translateY(4px);
}

.tab-fade-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}

@media (prefers-reduced-motion: reduce) {
  .view-slide-enter-active,
  .view-slide-leave-active,
  .tab-fade-enter-active,
  .tab-fade-leave-active {
    transition: opacity 120ms ease;
    transform: none;
  }
}
</style>

