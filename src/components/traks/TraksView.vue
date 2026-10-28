<script setup lang="ts">
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import {
  Zap,
  MessageSquare,
  Heart,
  Share2,
  Bookmark,
  MoreHorizontal,
  Search,
  ChevronUp,
  ChevronDown,
  Gamepad2,
  Play,
  X,
  Send,
  Flag,
  Copy,
  EyeOff,
  User,
  Check,
} from 'lucide-vue-next'
import type { TrakItem, TrakComment } from '../../types'

interface Props {
  traks: TrakItem[]
  currentUserName?: string
  currentUserHandle?: string
}

const props = withDefaults(defineProps<Props>(), {
  currentUserName: 'Jeffrey Suárez',
  currentUserHandle: 'SuarezCata655',
})

const emit = defineEmits<{
  (e: 'navigateGame', gameName: string): void
}>()

// Active tab: 'para-ti' | 'siguiendo'
const activeTab = ref<'para-ti' | 'siguiendo'>('para-ti')

// Current trak index
const currentIndex = ref(0)

// Active list of traks based on tab
const currentTraksList = computed(() => {
  if (activeTab.value === 'siguiendo') {
    const followed = props.traks.filter(t => t.author.followingStatus === 'siguiendo' || t.author.isOwner)
    return followed.length > 0 ? followed : props.traks
  }
  return props.traks
})

// Current active Trak
const currentTrak = computed(() => {
  if (currentTraksList.value.length === 0) return null
  const idx = Math.min(Math.max(0, currentIndex.value), currentTraksList.value.length - 1)
  return currentTraksList.value[idx]
})

// Video playback state
const videoRef = ref<HTMLVideoElement | null>(null)
const isPlaying = ref(true)
const isMuted = ref(false)
const progressPercent = ref(0)
const duration = ref(15) // default simulated
const currentTime = ref(0)

// Comments drawer state
const isCommentsOpen = ref(false)
const newCommentText = ref('')
const currentComments = ref<TrakComment[]>([])

// More options modal
const isMoreOpen = ref(false)

// Toast notification
const toastMessage = ref('')
const showToast = ref(false)

const triggerToast = (msg: string) => {
  toastMessage.value = msg
  showToast.value = true
  setTimeout(() => {
    showToast.value = false
  }, 2200)
}

// Search overlay
const isSearching = ref(false)
const searchQuery = ref('')

// Initialize comments when current Trak changes
watch(
  currentTrak,
  (trak) => {
    if (trak) {
      currentComments.value = trak.commentsList ? [...trak.commentsList] : []
      currentTime.value = 0
      progressPercent.value = 0
      isPlaying.value = true
    }
  },
  { immediate: true }
)

// Video time update
const onTimeUpdate = () => {
  if (videoRef.value) {
    currentTime.value = videoRef.value.currentTime
    duration.value = videoRef.value.duration || 15
    progressPercent.value = (videoRef.value.currentTime / duration.value) * 100
  }
}

// Toggle play/pause
const togglePlay = () => {
  if (videoRef.value) {
    if (videoRef.value.paused) {
      videoRef.value.play()
      isPlaying.value = true
    } else {
      videoRef.value.pause()
      isPlaying.value = false
    }
  } else {
    isPlaying.value = !isPlaying.value
  }
}

// Simulated progress interval for image-based traks (like the LOL meme)
let progressInterval: number | null = null

onMounted(() => {
  progressInterval = window.setInterval(() => {
    if (!videoRef.value && isPlaying.value) {
      currentTime.value += 0.2
      if (currentTime.value >= 15) currentTime.value = 0
      progressPercent.value = (currentTime.value / 15) * 100
    }
  }, 200)

  window.addEventListener('keydown', handleKeyNavigation)
})

onUnmounted(() => {
  if (progressInterval) clearInterval(progressInterval)
  window.removeEventListener('keydown', handleKeyNavigation)
})

// Navigation between Traks
const goToPrev = () => {
  if (currentIndex.value > 0) {
    currentIndex.value--
  }
}

const goToNext = () => {
  if (currentIndex.value < currentTraksList.value.length - 1) {
    currentIndex.value++
  } else {
    // Loop back to start
    currentIndex.value = 0
  }
}

// Keyboard arrow navigation
const handleKeyNavigation = (e: KeyboardEvent) => {
  if (isCommentsOpen.value || isSearching.value) return
  if (e.key === 'ArrowUp') {
    e.preventDefault()
    goToPrev()
  } else if (e.key === 'ArrowDown') {
    e.preventDefault()
    goToNext()
  } else if (e.key === ' ') {
    e.preventDefault()
    togglePlay()
  }
}

// Interactions
const toggleLike = () => {
  if (!currentTrak.value) return
  currentTrak.value.stats.isLiked = !currentTrak.value.stats.isLiked
  currentTrak.value.stats.likes += currentTrak.value.stats.isLiked ? 1 : -1
}

const toggleImpulse = () => {
  if (!currentTrak.value) return
  currentTrak.value.stats.isImpulsed = !currentTrak.value.stats.isImpulsed
  currentTrak.value.stats.impulses += currentTrak.value.stats.isImpulsed ? 1 : -1
}

const toggleSave = () => {
  if (!currentTrak.value) return
  currentTrak.value.stats.isSaved = !currentTrak.value.stats.isSaved
  currentTrak.value.stats.saves += currentTrak.value.stats.isSaved ? 1 : -1
  triggerToast(currentTrak.value.stats.isSaved ? 'Guardado en tu colección' : 'Eliminado de tus guardados')
}

const handleShare = () => {
  triggerToast('¡Enlace copiado al portapapeles!')
}

const addComment = () => {
  if (!newCommentText.value.trim() || !currentTrak.value) return
  const newC: TrakComment = {
    id: `c-${Date.now()}`,
    author: {
      name: props.currentUserName,
      handle: props.currentUserHandle,
      avatarType: 'red_user',
    },
    content: newCommentText.value.trim(),
    timeAgo: 'ahora',
    likes: 0,
    isLiked: false,
  }
  currentComments.value.unshift(newC)
  currentTrak.value.stats.comments++
  newCommentText.value = ''
}

const toggleCommentLike = (comment: TrakComment) => {
  comment.isLiked = !comment.isLiked
  comment.likes += comment.isLiked ? 1 : -1
}
</script>

<template>
  <main
    class="flex-1 min-w-0 rounded-2xl lg:rounded-3xl border border-[#1f212a] bg-black overflow-hidden flex flex-col h-[calc(100vh-2rem)] lg:h-[calc(100vh-2.5rem)] sticky top-4 lg:top-5 shadow-2xl relative select-none"
  >
    <!-- Centered Stage Container: 9:16 Phone/Reels Viewport -->
    <div class="relative w-full h-full flex items-center justify-center bg-black/95 overflow-hidden">
      <!-- Ambient Backdrop Blur -->
      <div class="absolute inset-0 bg-gradient-to-t from-red-950/20 via-black to-black opacity-60 pointer-events-none" />

      <!-- Main Phone/Trak Frame -->
      <div
        class="relative w-full max-w-[430px] h-full sm:h-[97%] rounded-none sm:rounded-3xl overflow-hidden bg-[#0d0e12] border-0 sm:border sm:border-white/10 shadow-2xl flex flex-col justify-between"
      >
        <!-- ======================================================== -->
        <!-- 1. TOP HEADER OVERLAY (Tabs: Para ti / Siguiendo + Search) -->
        <!-- ======================================================== -->
        <header
          class="absolute top-0 left-0 right-0 z-30 px-5 pt-4 pb-8 bg-gradient-to-b from-black/85 via-black/40 to-transparent flex items-center justify-between pointer-events-auto"
        >
          <!-- Left spacer to center tabs -->
          <div class="w-7" />

          <!-- Center Tabs: Para ti vs Siguiendo -->
          <div class="flex items-center gap-5">
            <!-- Para ti Tab -->
            <button
              type="button"
              @click="activeTab = 'para-ti'; currentIndex = 0"
              class="relative py-1 text-sm sm:text-base font-bold transition-all cursor-pointer"
              :class="activeTab === 'para-ti' ? 'text-white' : 'text-white/60 hover:text-white'"
            >
              <span>Para ti</span>
              <!-- Red Active Underline Pill -->
              <span
                v-if="activeTab === 'para-ti'"
                class="absolute -bottom-1 left-1/2 -translate-x-1/2 w-7 h-1 rounded-full bg-[#f0254c] shadow-[0_0_8px_rgba(240,37,76,0.8)]"
              />
            </button>

            <!-- Siguiendo Tab -->
            <button
              type="button"
              @click="activeTab = 'siguiendo'; currentIndex = 0"
              class="relative py-1 text-sm sm:text-base font-bold transition-all cursor-pointer"
              :class="activeTab === 'siguiendo' ? 'text-white' : 'text-white/60 hover:text-white'"
            >
              <span>Siguiendo</span>
              <!-- Red Active Underline Pill -->
              <span
                v-if="activeTab === 'siguiendo'"
                class="absolute -bottom-1 left-1/2 -translate-x-1/2 w-7 h-1 rounded-full bg-[#f0254c] shadow-[0_0_8px_rgba(240,37,76,0.8)]"
              />
            </button>
          </div>

          <!-- Right: Search Icon -->
          <button
            type="button"
            @click="isSearching = !isSearching"
            class="p-1 rounded-full text-white/90 hover:text-white transition-colors cursor-pointer"
            title="Buscar Traks"
          >
            <Search class="w-5 h-5 stroke-[2.5]" />
          </button>
        </header>

        <!-- Search Bar Popup Overlay -->
        <Transition name="fade">
          <div
            v-if="isSearching"
            class="absolute top-16 left-4 right-4 z-40 p-2 rounded-2xl bg-black/90 backdrop-blur-xl border border-white/20 shadow-2xl flex items-center gap-2"
          >
            <Search class="w-4 h-4 text-gray-400 ml-2" />
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Buscar por juego, hashtag o creador..."
              class="flex-1 bg-transparent text-sm text-white placeholder-gray-500 focus:outline-none"
              autofocus
            />
            <button
              type="button"
              @click="isSearching = false"
              class="p-1 text-gray-400 hover:text-white"
            >
              <X class="w-4 h-4" />
            </button>
          </div>
        </Transition>

        <!-- ======================================================== -->
        <!-- 2. MAIN MEDIA DISPLAY (Video / Graphic Meme Canvas)      -->
        <!-- ======================================================== -->
        <div
          class="relative w-full h-full flex items-center justify-center bg-black cursor-pointer overflow-hidden"
          @click="togglePlay"
        >
          <!-- SPECIAL RECREATION: Trak LOL Meme matching screenshot 1:1 -->
          <template v-if="currentTrak && currentTrak.id === 'trak-lordderiam-lol'">
            <div class="relative w-full h-full bg-[#f0f0f2] flex flex-col justify-start items-center text-black px-4 pt-16 pb-24 overflow-hidden select-none">
              <!-- Meme Title: ETAPAS DE JUGAR LOL -->
              <h1 class="text-2xl sm:text-3xl font-black tracking-tight text-center text-black uppercase mb-4 leading-none font-sans">
                ETAPAS DE<br />JUGAR LOL
              </h1>

              <!-- 3 Bracket stages container -->
              <div class="w-full flex-1 flex flex-col justify-between py-2 relative max-w-[280px]">
                <!-- Bracket 1: Gamer Laughing / Streaming Clip -->
                <div class="flex items-center gap-3 relative">
                  <!-- Large bracket symbol [ -->
                  <span class="text-6xl sm:text-7xl font-black text-black leading-none shrink-0">[</span>
                  <!-- Streamer webcam box -->
                  <div class="w-44 h-28 rounded-lg overflow-hidden border border-black/20 bg-gray-900 shadow-md relative">
                    <img
                      src="https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop"
                      alt="Streamer"
                      class="w-full h-full object-cover"
                    />
                    <!-- Watermark -->
                    <span class="absolute top-1 right-2 text-[10px] font-mono text-white/70">117</span>
                  </div>
                </div>

                <!-- Bracket 2: League of Legends Emblem -->
                <div class="flex items-center gap-3 relative">
                  <!-- LOL Metallic Emblem -->
                  <div class="w-14 h-14 rounded-full bg-gradient-to-br from-[#0c1c24] to-[#04080b] border border-[#c89b3c] flex items-center justify-center shadow-lg -ml-1">
                    <span class="font-serif font-black text-2xl text-transparent bg-clip-text bg-gradient-to-b from-[#f0e6d2] via-[#c8aa6e] to-[#785a28]">
                      L
                    </span>
                  </div>
                  <!-- Large bracket symbol [ -->
                  <span class="text-6xl sm:text-7xl font-black text-black leading-none shrink-0">[</span>
                </div>

                <!-- Bracket 3: Stage 3 -->
                <div class="flex items-center gap-3 relative">
                  <div class="w-14" />
                  <!-- Large bracket symbol [ -->
                  <span class="text-6xl sm:text-7xl font-black text-black leading-none shrink-0">[</span>
                </div>
              </div>

              <!-- Vignette & shadow overlay for bottom readability -->
              <div class="absolute inset-x-0 bottom-0 h-44 bg-gradient-to-t from-black/90 via-black/40 to-transparent pointer-events-none" />
            </div>
          </template>

          <!-- STANDARD VIDEO / IMAGE TRAK (Gameplay, Camera, or user uploaded Trak) -->
          <template v-else-if="currentTrak">
            <video
              v-if="currentTrak.mediaType !== 'image' && currentTrak.mediaUrl"
              ref="videoRef"
              :src="currentTrak.mediaUrl"
              autoplay
              loop
              playsinline
              :muted="isMuted"
              class="w-full h-full object-cover"
              @timeupdate="onTimeUpdate"
              @play="isPlaying = true"
              @pause="isPlaying = false"
            />
            <img
              v-else-if="currentTrak.mediaUrl"
              :src="currentTrak.mediaUrl"
              :alt="currentTrak.title"
              class="w-full h-full object-cover"
            />
            <!-- Fallback atmospheric graphic if no video provided -->
            <div
              v-else
              class="w-full h-full bg-gradient-to-b from-red-950/40 via-[#120a10] to-black flex items-center justify-center p-6 text-center"
            >
              <div class="space-y-3">
                <Gamepad2 class="w-16 h-16 text-[#f0254c] mx-auto animate-pulse" />
                <h3 class="text-lg font-bold text-white">{{ currentTrak.title }}</h3>
                <p class="text-xs text-gray-400">{{ currentTrak.game }}</p>
              </div>
            </div>

            <!-- Bottom Gradient for Readability -->
            <div class="absolute inset-x-0 bottom-0 h-48 bg-gradient-to-t from-black/95 via-black/50 to-transparent pointer-events-none" />
          </template>

          <!-- Play / Pause indicator icon overlay when paused -->
          <Transition name="fade">
            <div
              v-if="!isPlaying"
              class="absolute inset-0 z-20 flex items-center justify-center pointer-events-none bg-black/30 backdrop-blur-[1px]"
            >
              <div class="w-16 h-16 rounded-full bg-black/75 border border-white/20 flex items-center justify-center shadow-2xl backdrop-blur-md">
                <Play class="w-7 h-7 text-white fill-white ml-1" />
              </div>
            </div>
          </Transition>
        </div>

        <!-- ======================================================== -->
        <!-- 3. RIGHT SIDEBAR ACTION BUTTONS (Stack: Zap, Chat, etc.) -->
        <!-- ======================================================== -->
        <div
          v-if="currentTrak"
          class="absolute right-3 bottom-14 z-30 flex flex-col items-center gap-3.5 select-none"
        >
          <!-- 1. Impulso (⚡ Zap) -->
          <button
            type="button"
            @click.stop="toggleImpulse"
            class="group flex flex-col items-center cursor-pointer transition-transform active:scale-90"
            title="Impulsar Trak"
          >
            <div
              class="w-11 h-11 sm:w-12 sm:h-12 rounded-full flex items-center justify-center backdrop-blur-md border border-white/10 transition-colors shadow-lg"
              :class="currentTrak.stats.isImpulsed ? 'bg-[#f0254c] text-white shadow-[#f0254c]/40' : 'bg-black/55 text-white hover:bg-black/80'"
            >
              <Zap class="w-5 h-5 sm:w-6 sm:h-6" :class="{ 'fill-current': currentTrak.stats.isImpulsed }" />
            </div>
            <span class="text-[11px] sm:text-xs font-semibold text-white mt-1 drop-shadow-[0_1px_3px_rgba(0,0,0,0.8)]">
              {{ currentTrak.stats.impulses }}
            </span>
          </button>

          <!-- 2. Comentarios (💬 MessageSquare) -->
          <button
            type="button"
            @click.stop="isCommentsOpen = true"
            class="group flex flex-col items-center cursor-pointer transition-transform active:scale-90"
            title="Ver comentarios"
          >
            <div class="w-11 h-11 sm:w-12 sm:h-12 rounded-full bg-black/55 hover:bg-black/80 flex items-center justify-center backdrop-blur-md border border-white/10 text-white transition-colors shadow-lg">
              <MessageSquare class="w-5 h-5 sm:w-6 sm:h-6" />
            </div>
            <span class="text-[11px] sm:text-xs font-semibold text-white mt-1 drop-shadow-[0_1px_3px_rgba(0,0,0,0.8)]">
              {{ currentTrak.stats.comments }}
            </span>
          </button>

          <!-- 3. Me gusta (❤️ Heart - Red Glowing Pill in screenshot) -->
          <button
            type="button"
            @click.stop="toggleLike"
            class="group flex flex-col items-center cursor-pointer transition-transform active:scale-90"
            title="Me gusta"
          >
            <div
              class="w-11 h-11 sm:w-12 sm:h-12 rounded-full flex items-center justify-center backdrop-blur-md border transition-all shadow-xl"
              :class="currentTrak.stats.isLiked ? 'bg-[#f0254c] border-[#f0254c] text-white shadow-[0_0_15px_rgba(240,37,76,0.6)]' : 'bg-black/55 border-white/10 text-white hover:bg-black/80'"
            >
              <Heart class="w-5 h-5 sm:w-6 sm:h-6" :class="{ 'fill-current text-white': currentTrak.stats.isLiked }" />
            </div>
            <span class="text-[11px] sm:text-xs font-semibold text-white mt-1 drop-shadow-[0_1px_3px_rgba(0,0,0,0.8)]">
              {{ currentTrak.stats.likes }}
            </span>
          </button>

          <!-- 4. Compartir (📤 Share2) -->
          <button
            type="button"
            @click.stop="handleShare"
            class="group flex flex-col items-center cursor-pointer transition-transform active:scale-90"
            title="Compartir Trak"
          >
            <div class="w-11 h-11 sm:w-12 sm:h-12 rounded-full bg-black/55 hover:bg-black/80 flex items-center justify-center backdrop-blur-md border border-white/10 text-white transition-colors shadow-lg">
              <Share2 class="w-5 h-5 sm:w-6 sm:h-6" />
            </div>
            <span class="text-[11px] sm:text-xs font-semibold text-white mt-1 drop-shadow-[0_1px_3px_rgba(0,0,0,0.8)]">
              {{ currentTrak.stats.shares }}
            </span>
          </button>

          <!-- 5. Guardar (🔖 Bookmark) -->
          <button
            type="button"
            @click.stop="toggleSave"
            class="group flex flex-col items-center cursor-pointer transition-transform active:scale-90"
            title="Guardar Trak"
          >
            <div
              class="w-11 h-11 sm:w-12 sm:h-12 rounded-full flex items-center justify-center backdrop-blur-md border transition-colors shadow-lg"
              :class="currentTrak.stats.isSaved ? 'bg-amber-500/90 text-white border-amber-400' : 'bg-black/55 text-white border-white/10 hover:bg-black/80'"
            >
              <Bookmark class="w-5 h-5 sm:w-6 sm:h-6" :class="{ 'fill-current': currentTrak.stats.isSaved }" />
            </div>
            <span class="text-[11px] sm:text-xs font-semibold text-white mt-1 drop-shadow-[0_1px_3px_rgba(0,0,0,0.8)]">
              {{ currentTrak.stats.saves }}
            </span>
          </button>

          <!-- 6. Más (⋯ MoreHorizontal) -->
          <button
            type="button"
            @click.stop="isMoreOpen = true"
            class="group flex flex-col items-center cursor-pointer transition-transform active:scale-90"
            title="Más opciones"
          >
            <div class="w-11 h-11 sm:w-12 sm:h-12 rounded-full bg-black/55 hover:bg-black/80 flex items-center justify-center backdrop-blur-md border border-white/10 text-white transition-colors shadow-lg">
              <MoreHorizontal class="w-5 h-5 sm:w-6 sm:h-6" />
            </div>
            <span class="text-[10px] sm:text-[11px] font-semibold text-white mt-1 drop-shadow-[0_1px_3px_rgba(0,0,0,0.8)]">
              Más
            </span>
          </button>

          <!-- 7. Rotating Audio Vinyl Disc (Spinning when playing) -->
          <div
            class="relative w-11 h-11 rounded-full bg-[#121214] border-2 border-[#f0254c] shadow-[0_0_14px_rgba(240,37,76,0.6)] flex items-center justify-center cursor-pointer mt-1"
            :class="{ 'animate-spin': isPlaying }"
            style="animation-duration: 4s;"
            title="Audio original"
            @click.stop="isMuted = !isMuted"
          >
            <!-- Vinyl Grooves -->
            <div class="w-8 h-8 rounded-full border border-white/20 flex items-center justify-center">
              <div class="w-4 h-4 rounded-full border border-white/30 flex items-center justify-center bg-black">
                <div class="w-1.5 h-1.5 rounded-full bg-[#f0254c]" />
              </div>
            </div>
          </div>
        </div>

        <!-- ======================================================== -->
        <!-- 4. BOTTOM-LEFT OVERLAY (User, Handle, Caption, Game)    -->
        <!-- ======================================================== -->
        <div
          v-if="currentTrak"
          class="absolute left-4 right-16 bottom-5 z-20 flex flex-col items-start gap-2 pointer-events-auto"
        >
          <!-- Author Row: Avatar + "Tuyo" Badge / Follow Button -->
          <div class="flex items-center gap-2.5">
            <!-- Avatar with Red Glowing Ring -->
            <div class="w-10 h-10 rounded-full border-2 border-[#f0254c] overflow-hidden bg-black flex items-center justify-center shadow-lg shrink-0">
              <img
                v-if="currentTrak.author.avatarUrl"
                :src="currentTrak.author.avatarUrl"
                :alt="currentTrak.author.name"
                class="w-full h-full object-cover"
              />
              <User v-else class="w-5 h-5 text-gray-200" />
            </div>

            <!-- "Tuyo" Badge (as in screenshot) or Follow Button -->
            <span
              v-if="currentTrak.author.isOwner"
              class="px-2.5 py-0.5 rounded-full bg-white/20 backdrop-blur-md text-white text-[11px] font-bold border border-white/20 shadow-sm select-none"
            >
              Tuyo
            </span>
            <button
              v-else-if="currentTrak.author.followingStatus !== 'siguiendo'"
              type="button"
              class="px-3 py-1 rounded-full bg-[#f0254c] hover:bg-[#d9193f] text-white text-xs font-bold shadow-md cursor-pointer active:scale-95 transition-all"
            >
              Seguir
            </button>
          </div>

          <!-- Handle -->
          <p class="text-sm font-bold text-white tracking-wide drop-shadow-[0_2px_4px_rgba(0,0,0,0.9)]">
            @{{ currentTrak.author.handle }}
          </p>

          <!-- Caption -->
          <p class="text-xs sm:text-sm text-white/95 leading-snug drop-shadow-[0_2px_4px_rgba(0,0,0,0.9)] font-normal line-clamp-2">
            {{ currentTrak.caption }}
          </p>

          <!-- Game Badge Capsule (🎮 League Of Legends) -->
          <div
            v-if="currentTrak.game"
            @click.stop="emit('navigateGame', currentTrak.game)"
            class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-black/60 hover:bg-black/80 backdrop-blur-md border border-white/15 text-xs text-white/90 font-medium transition-colors cursor-pointer shadow-md group"
          >
            <Gamepad2 class="w-3.5 h-3.5 text-white/80 group-hover:text-[#f0254c] transition-colors" />
            <span>{{ currentTrak.game }}</span>
          </div>
        </div>

        <!-- ======================================================== -->
        <!-- 5. RED PROGRESS BAR (Thin bottom track line)            -->
        <!-- ======================================================== -->
        <div class="absolute bottom-0 left-0 right-0 h-1 bg-white/20 z-30 overflow-hidden">
          <div
            class="h-full bg-[#f0254c] shadow-[0_0_8px_rgba(240,37,76,0.8)] transition-all duration-150"
            :style="{ width: `${progressPercent}%` }"
          />
        </div>
      </div>

      <!-- ======================================================== -->
      <!-- 6. DESKTOP NAVIGATION CONTROLS (Prev / Next Stepper)     -->
      <!-- ======================================================== -->
      <div class="hidden lg:flex flex-col items-center gap-3 ml-6 z-20">
        <!-- Up: Previous Trak -->
        <button
          type="button"
          @click="goToPrev"
          :disabled="currentIndex === 0"
          class="w-11 h-11 rounded-full bg-[#181923] hover:bg-[#222433] border border-white/10 text-white flex items-center justify-center transition-all cursor-pointer disabled:opacity-30 disabled:cursor-not-allowed active:scale-95 shadow-xl"
          title="Trak anterior (Flecha Arriba)"
        >
          <ChevronUp class="w-6 h-6 stroke-[2.5]" />
        </button>

        <!-- Index counter -->
        <span class="text-xs font-mono font-bold text-gray-400 select-none">
          {{ currentIndex + 1 }} / {{ currentTraksList.length }}
        </span>

        <!-- Down: Next Trak -->
        <button
          type="button"
          @click="goToNext"
          class="w-11 h-11 rounded-full bg-[#181923] hover:bg-[#222433] border border-white/10 text-white flex items-center justify-center transition-all cursor-pointer active:scale-95 shadow-xl"
          title="Siguiente Trak (Flecha Abajo)"
        >
          <ChevronDown class="w-6 h-6 stroke-[2.5]" />
        </button>
      </div>
    </div>

    <!-- ======================================================== -->
    <!-- 7. COMMENTS SLIDE-OVER DRAWER                            -->
    <!-- ======================================================== -->
    <Transition name="fade">
      <div
        v-if="isCommentsOpen"
        class="absolute inset-0 z-50 bg-black/70 backdrop-blur-sm flex justify-end"
        @click.self="isCommentsOpen = false"
      >
        <div
          class="w-full sm:w-[380px] h-full bg-[#121319] border-l border-white/10 flex flex-col justify-between shadow-2xl animate-fade-in"
        >
          <!-- Drawer Header -->
          <div class="px-5 py-4 border-b border-white/10 flex items-center justify-between">
            <h3 class="text-base font-bold text-white">
              Comentarios ({{ currentComments.length }})
            </h3>
            <button
              type="button"
              @click="isCommentsOpen = false"
              class="p-1 rounded-full text-gray-400 hover:text-white"
            >
              <X class="w-5 h-5" />
            </button>
          </div>

          <!-- Comments List -->
          <div class="flex-1 overflow-y-auto p-4 space-y-4 no-scrollbar">
            <div
              v-if="currentComments.length === 0"
              class="text-center py-16 text-gray-500 text-xs"
            >
              No hay comentarios todavía. ¡Sé el primero en comentar!
            </div>

            <div
              v-for="c in currentComments"
              :key="c.id"
              class="flex items-start gap-3"
            >
              <div class="w-8 h-8 rounded-full border border-red-500/40 bg-black flex items-center justify-center shrink-0 overflow-hidden">
                <img
                  v-if="c.author.avatarUrl"
                  :src="c.author.avatarUrl"
                  :alt="c.author.name"
                  class="w-full h-full object-cover"
                />
                <User v-else class="w-4 h-4 text-gray-300" />
              </div>

              <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between">
                  <p class="text-xs font-bold text-white">
                    @{{ c.author.handle }}
                    <span class="text-[10px] text-gray-500 font-normal ml-1">{{ c.timeAgo }}</span>
                  </p>
                  <button
                    type="button"
                    @click="toggleCommentLike(c)"
                    class="flex items-center gap-1 text-[11px] text-gray-400 hover:text-[#f0254c] cursor-pointer"
                  >
                    <Heart class="w-3.5 h-3.5" :class="{ 'fill-[#f0254c] text-[#f0254c]': c.isLiked }" />
                    <span v-if="c.likes > 0">{{ c.likes }}</span>
                  </button>
                </div>
                <p class="text-xs text-gray-200 mt-1 leading-relaxed">
                  {{ c.content }}
                </p>
              </div>
            </div>
          </div>

          <!-- Comment Input -->
          <div class="p-3 border-t border-white/10 bg-black/40">
            <div class="flex items-center gap-2 bg-[#1a1b24] rounded-2xl px-3 py-2 border border-white/10 focus-within:border-[#f0254c]">
              <input
                v-model="newCommentText"
                type="text"
                placeholder="Añadir un comentario..."
                class="flex-1 bg-transparent text-xs text-white placeholder-gray-500 focus:outline-none"
                @keydown.enter="addComment"
              />
              <button
                type="button"
                @click="addComment"
                :disabled="!newCommentText.trim()"
                class="p-1 rounded-full text-[#f0254c] hover:text-[#ff3860] disabled:text-gray-600 disabled:cursor-not-allowed transition-colors"
              >
                <Send class="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </Transition>

    <!-- ======================================================== -->
    <!-- 8. MORE OPTIONS MODAL ("Más")                           -->
    <!-- ======================================================== -->
    <Transition name="fade">
      <div
        v-if="isMoreOpen"
        class="absolute inset-0 z-50 bg-black/70 backdrop-blur-sm flex items-center justify-center p-4"
        @click.self="isMoreOpen = false"
      >
        <div class="w-full max-w-xs rounded-2xl bg-[#161720] border border-white/10 p-2 shadow-2xl space-y-1">
          <button
            type="button"
            @click="handleShare(); isMoreOpen = false"
            class="w-full px-4 py-3 rounded-xl hover:bg-white/5 text-sm font-semibold text-white flex items-center gap-3 transition-colors cursor-pointer"
          >
            <Copy class="w-4 h-4 text-gray-400" />
            <span>Copiar enlace</span>
          </button>

          <button
            type="button"
            @click="triggerToast('Marcado como no me interesa'); isMoreOpen = false; goToNext()"
            class="w-full px-4 py-3 rounded-xl hover:bg-white/5 text-sm font-semibold text-white flex items-center gap-3 transition-colors cursor-pointer"
          >
            <EyeOff class="w-4 h-4 text-gray-400" />
            <span>No me interesa</span>
          </button>

          <button
            type="button"
            @click="triggerToast('Reporte enviado a moderación'); isMoreOpen = false"
            class="w-full px-4 py-3 rounded-xl hover:bg-white/5 text-sm font-semibold text-[#f0254c] flex items-center gap-3 transition-colors cursor-pointer"
          >
            <Flag class="w-4 h-4 text-[#f0254c]" />
            <span>Reportar Trak</span>
          </button>

          <div class="border-t border-white/10 my-1" />

          <button
            type="button"
            @click="isMoreOpen = false"
            class="w-full py-2.5 text-center text-xs text-gray-400 hover:text-white font-medium cursor-pointer"
          >
            Cancelar
          </button>
        </div>
      </div>
    </Transition>

    <!-- Toast Notification -->
    <Transition name="fade">
      <div
        v-if="showToast"
        class="fixed bottom-20 left-1/2 -translate-x-1/2 z-50 px-4 py-2 rounded-xl bg-[#1f212a] text-white text-xs font-semibold shadow-2xl border border-white/10 flex items-center gap-2"
      >
        <Check class="w-4 h-4 text-emerald-400" />
        <span>{{ toastMessage }}</span>
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

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>
