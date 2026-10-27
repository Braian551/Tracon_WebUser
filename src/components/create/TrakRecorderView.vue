<script setup lang="ts">
import { ref, computed, nextTick, onMounted, onUnmounted } from 'vue'
import {
  X,
  Mic,
  MicOff,
  Camera,
  CameraOff,
  Monitor,
  MonitorOff,
  Video,
  VideoOff,
  Image as ImageIcon,
  Square,
  RotateCcw,
  Send,
} from 'lucide-vue-next'
import type { Post } from '../../types'

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
  (e: 'switch-tab', tab: 'publicacion' | 'trak'): void
  (e: 'published', post: Post): void
}>()

// Settings & toggles
const captureSource = ref<'camera' | 'screen'>('camera') // 'camera' (frontal) | 'screen' (pantalla)
const isMicEnabled = ref(false) // Default muted as in screenshot (MicOff)
const isCameraEnabled = ref(true) // Camera active toggle
const trakDuration = ref<15 | 60>(15)

// Stream and recording states
const streamActive = ref(false)
const currentStream = ref<MediaStream | null>(null)
const videoElementRef = ref<HTMLVideoElement | null>(null)
const galleryFileInputRef = ref<HTMLInputElement | null>(null)

const isRecording = ref(false)
const recordedSeconds = ref(0)
let mediaRecorder: MediaRecorder | null = null
let recordedChunks: Blob[] = []
let recordInterval: ReturnType<typeof setInterval> | null = null

// Final recorded/selected media preview
interface MediaPreview {
  url: string
  type: 'video' | 'image'
  name: string
}
const recordedMedia = ref<MediaPreview | null>(null)

// Format recording countdown
const formattedSeconds = computed(() => {
  const s = recordedSeconds.value
  const mins = Math.floor(s / 60)
  const secs = s % 60
  return `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`
})

// Progress percentage
const recordingProgress = computed(() => {
  return Math.min(100, (recordedSeconds.value / trakDuration.value) * 100)
})

// Toggle Mic
const toggleMic = () => {
  isMicEnabled.value = !isMicEnabled.value
  if (currentStream.value) {
    currentStream.value.getAudioTracks().forEach((track) => {
      track.enabled = isMicEnabled.value
    })
  }
}

// Toggle Camera Active / Inactive (Activar / Desactivar cámara frontal)
const toggleCamera = async () => {
  if (isCameraEnabled.value && streamActive.value) {
    isCameraEnabled.value = false
    stopStream()
  } else {
    isCameraEnabled.value = true
    await startStream()
  }
}

// Toggle Screen Capture Active / Inactive
const toggleScreenCapture = async () => {
  if (streamActive.value) {
    stopStream()
  } else {
    await startStream()
  }
}

// Toggle Capture Source (Camera Frontal vs Screen)
const toggleCaptureSource = async () => {
  captureSource.value = captureSource.value === 'camera' ? 'screen' : 'camera'
  if (streamActive.value) {
    await startStream()
  }
}

// Stop active stream
const stopStream = () => {
  if (currentStream.value) {
    currentStream.value.getTracks().forEach((t) => t.stop())
    currentStream.value = null
  }
  streamActive.value = false
}

// Start camera or screen stream
const startStream = async () => {
  stopStream()
  try {
    if (captureSource.value === 'camera') {
      if (!isCameraEnabled.value) return
      currentStream.value = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: 'user',
          width: { ideal: 1080 },
          height: { ideal: 1920 },
        },
        audio: isMicEnabled.value,
      })
    } else {
      currentStream.value = await navigator.mediaDevices.getDisplayMedia({
        video: true,
        audio: isMicEnabled.value,
      })
    }
    streamActive.value = true
    nextTick(() => {
      if (videoElementRef.value && currentStream.value) {
        videoElementRef.value.srcObject = currentStream.value
      }
    })
  } catch {
    streamActive.value = false
  }
}

// Gallery file selection
const triggerGalleryPick = () => {
  galleryFileInputRef.value?.click()
}

const handleGalleryFile = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  const isVideo = file.type.startsWith('video')
  const url = URL.createObjectURL(file)
  recordedMedia.value = {
    url,
    type: isVideo ? 'video' : 'image',
    name: file.name,
  }
  stopStream()
  if (galleryFileInputRef.value) {
    galleryFileInputRef.value.value = ''
  }
}

// Record toggling
const toggleRecording = async () => {
  if (isRecording.value) {
    stopRecording()
    return
  }

  // If no stream is active, attempt to start one first
  if (!streamActive.value || !currentStream.value) {
    await startStream()
    if (!streamActive.value) {
      return
    }
  }

  if (!currentStream.value) return

  recordedChunks = []
  recordedSeconds.value = 0

  try {
    mediaRecorder = new MediaRecorder(currentStream.value)
    mediaRecorder.ondataavailable = (event) => {
      if (event.data.size > 0) {
        recordedChunks.push(event.data)
      }
    }

    mediaRecorder.onstop = () => {
      const blob = new Blob(recordedChunks, { type: 'video/webm' })
      const url = URL.createObjectURL(blob)
      recordedMedia.value = {
        url,
        type: 'video',
        name: `trak-${Date.now()}.webm`,
      }
      stopStream()
    }

    mediaRecorder.start()
    isRecording.value = true

    recordInterval = setInterval(() => {
      recordedSeconds.value++
      if (recordedSeconds.value >= trakDuration.value) {
        stopRecording()
      }
    }, 1000)
  } catch (err) {
    console.error('Error starting media recorder:', err)
  }
}

const stopRecording = () => {
  if (recordInterval) {
    clearInterval(recordInterval)
    recordInterval = null
  }
  if (mediaRecorder && mediaRecorder.state !== 'inactive') {
    mediaRecorder.stop()
  }
  isRecording.value = false
}

// Reset recorded media to record or pick again
const resetRecordedMedia = () => {
  recordedMedia.value = null
  startStream()
}

// Publish Trak to feed
const handlePublishTrak = () => {
  if (!recordedMedia.value) return
  const post: Post = {
    id: `post-${Date.now()}`,
    author: {
      name: props.userName,
      handle: props.userHandle,
    },
    timeAgo: 'ahora',
    content: `Nuevo Trak (${trakDuration.value}s)`,
    mediaUrl: recordedMedia.value.url,
    mediaType: recordedMedia.value.type,
    trakData: {
      title: `Trak: ${captureSource.value === 'camera' ? 'Cámara frontal' : 'Gameplay / Pantalla'}`,
      game: 'Specimen Zero',
      category: 'Récord',
      difficulty: 'Pesadilla',
      record: `${trakDuration.value}s`,
    },
    stats: {
      comments: 0,
      likes: 0,
      impulses: 0,
      isLiked: false,
      isImpulsed: false,
      isSaved: false,
    },
  }
  emit('published', post)
}

onMounted(() => {
  // Try gentle camera initialization if permitted
  if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
    navigator.mediaDevices
      .getUserMedia({ video: { facingMode: 'user' }, audio: false })
      .then((stream) => {
        currentStream.value = stream
        streamActive.value = true
        nextTick(() => {
          if (videoElementRef.value) {
            videoElementRef.value.srcObject = stream
          }
        })
      })
      .catch(() => {
        streamActive.value = false
      })
  }
})

onUnmounted(() => {
  stopRecording()
  stopStream()
})
</script>

<template>
  <div class="flex-1 flex flex-col h-full bg-black text-white overflow-hidden relative select-none">
    <!-- Hidden file input for gallery pick -->
    <input
      ref="galleryFileInputRef"
      type="file"
      accept="video/*,image/*"
      class="hidden"
      @change="handleGalleryFile"
    />

    <!-- 1. Top Controls Bar -->
    <header class="h-16 px-4 sm:px-6 flex items-center justify-between shrink-0 z-30 bg-gradient-to-b from-black/80 via-black/40 to-transparent">
      <!-- Close button (X) -->
      <button
        type="button"
        @click="emit('close')"
        class="w-10 h-10 rounded-full bg-black/40 hover:bg-white/10 flex items-center justify-center text-white transition-colors cursor-pointer"
        title="Cerrar"
      >
        <X class="w-6 h-6" />
      </button>

      <!-- Center status pill (when streaming or recording) -->
      <div v-if="isRecording" class="flex items-center gap-2 px-3.5 py-1 rounded-full bg-red-600/90 text-white font-mono text-xs font-bold shadow-lg animate-pulse">
        <span class="w-2 h-2 rounded-full bg-white" />
        <span>REC {{ formattedSeconds }} / {{ trakDuration }}s</span>
      </div>
      <div v-else-if="streamActive" class="px-3 py-1 rounded-full bg-white/10 backdrop-blur-md text-xs font-semibold text-gray-200">
        {{ captureSource === 'camera' ? 'Cámara frontal' : 'Grabación de pantalla' }}
      </div>

      <!-- Right action buttons: Mic toggle and Camera toggle (matching image) -->
      <div class="flex items-center gap-3">
        <!-- Microphone button (Habilitar / Deshabilitar micrófono - solo en cámara frontal) -->
        <button
          v-if="captureSource === 'camera'"
          type="button"
          @click="toggleMic"
          class="w-10 h-10 rounded-full bg-black/40 hover:bg-white/10 border border-white/15 flex items-center justify-center text-white transition-all cursor-pointer shadow-md"
          :class="isMicEnabled ? 'border-emerald-500/60 text-emerald-400 bg-emerald-950/30' : 'text-gray-300'"
          :title="isMicEnabled ? 'Micrófono activado' : 'Micrófono desactivado'"
        >
          <Mic v-if="isMicEnabled" class="w-5 h-5 text-emerald-400" />
          <MicOff v-else class="w-5 h-5 text-gray-300" />
        </button>

        <!-- Camera toggle button (Activar y desactivar cámara) -->
        <button
          v-if="captureSource === 'camera'"
          type="button"
          @click="toggleCamera"
          class="w-10 h-10 rounded-full bg-black/40 hover:bg-white/10 border border-white/15 flex items-center justify-center text-white transition-all cursor-pointer shadow-md"
          :class="isCameraEnabled && streamActive ? 'text-white border-white/30 bg-white/10' : 'text-gray-400 border-white/10'"
          :title="isCameraEnabled && streamActive ? 'Desactivar cámara frontal' : 'Activar cámara frontal'"
        >
          <Camera v-if="isCameraEnabled && streamActive" class="w-5 h-5 text-white" />
          <CameraOff v-else class="w-5 h-5 text-gray-400" />
        </button>

        <!-- Screen recording toggle button (when in screen mode) -->
        <button
          v-else
          type="button"
          @click="toggleScreenCapture"
          class="w-10 h-10 rounded-full bg-black/40 hover:bg-white/10 border border-white/15 flex items-center justify-center text-white transition-all cursor-pointer shadow-md"
          :class="streamActive ? 'text-white border-white/30 bg-white/10' : 'text-gray-400 border-white/10'"
          :title="streamActive ? 'Detener captura de pantalla' : 'Iniciar captura de pantalla'"
        >
          <Monitor v-if="streamActive" class="w-5 h-5 text-white" />
          <MonitorOff v-else class="w-5 h-5 text-gray-400" />
        </button>
      </div>
    </header>

    <!-- Recording Progress Bar (when recording) -->
    <div v-if="isRecording" class="h-1 w-full bg-white/20 relative z-30">
      <div
        class="h-full bg-[#f0254c] transition-all duration-300 ease-linear shadow-[0_0_8px_#f0254c]"
        :style="{ width: `${recordingProgress}%` }"
      />
    </div>

    <!-- 2. Viewfinder & Content Area -->
    <main class="flex-1 flex flex-col items-center justify-center relative overflow-hidden px-4">
      <!-- A. Active live camera/screen feed -->
      <video
        v-if="streamActive && !recordedMedia"
        ref="videoElementRef"
        autoplay
        playsinline
        muted
        class="absolute inset-0 w-full h-full object-cover"
      />

      <!-- B. Recorded or Selected Media Preview -->
      <div
        v-else-if="recordedMedia"
        class="absolute inset-0 w-full h-full flex flex-col items-center justify-center bg-black z-10"
      >
        <video
          v-if="recordedMedia.type === 'video'"
          :src="recordedMedia.url"
          controls
          autoplay
          class="max-w-full max-h-[70vh] rounded-2xl shadow-2xl bg-black"
        />
        <img
          v-else
          :src="recordedMedia.url"
          alt="Captura seleccionada"
          class="max-w-full max-h-[70vh] rounded-2xl object-contain shadow-2xl"
        />

        <!-- Actions over preview -->
        <div class="mt-4 flex items-center gap-3 z-20">
          <button
            type="button"
            @click="resetRecordedMedia"
            class="px-4 py-2.5 rounded-xl bg-white/10 hover:bg-white/20 text-white font-semibold text-xs flex items-center gap-2 transition-colors cursor-pointer border border-white/10"
          >
            <RotateCcw class="w-4 h-4" />
            <span>Repetir</span>
          </button>

          <button
            type="button"
            @click="handlePublishTrak"
            class="px-6 py-2.5 rounded-xl bg-[#f0254c] hover:bg-[#d9193f] text-white font-bold text-xs flex items-center gap-2 transition-all shadow-[0_0_15px_rgba(240,37,76,0.4)] cursor-pointer"
          >
            <Send class="w-4 h-4" />
            <span>Publicar Trak</span>
          </button>
        </div>
      </div>

      <!-- C. Fallback State (Matches Screenshot exactly when no camera permission or stream is idle) -->
      <div
        v-else
        class="flex flex-col items-center justify-center max-w-sm text-center px-4 py-8 z-10 animate-fade-in"
      >
        <!-- Icon: MonitorOff if screen recording, VideoOff if camera -->
        <div class="mb-5 flex items-center justify-center text-white/80">
          <MonitorOff v-if="captureSource === 'screen'" class="w-16 h-16 stroke-[1.25]" />
          <VideoOff v-else class="w-16 h-16 stroke-[1.25]" />
        </div>

        <!-- Description text matching image explicitly for camera vs screen recording -->
        <p class="text-white text-[15px] sm:text-base leading-relaxed font-normal mb-7 select-text">
          <template v-if="captureSource === 'screen'">
            Sin permiso de grabación de pantalla. Puedes volver y elegir videos de la galería.
          </template>
          <template v-else-if="!isCameraEnabled">
            Cámara frontal desactivada. Actívala con el botón superior o elige videos de la galería.
          </template>
          <template v-else>
            Sin permiso de cámara. Puedes volver y elegir videos de la galería.
          </template>
        </p>

        <!-- Big Red Elegir desde galería button matching image -->
        <button
          type="button"
          @click="triggerGalleryPick"
          class="w-full py-3.5 px-6 rounded-2xl bg-[#8c0d27] hover:bg-[#a11130] text-white font-bold text-sm transition-all shadow-lg shadow-black/80 cursor-pointer active:scale-98"
        >
          Elegir desde galería
        </button>

        <!-- Secondary action to re-attempt or switch capture -->
        <button
          type="button"
          @click="captureSource === 'camera' ? toggleCamera() : startStream()"
          class="mt-4 text-xs text-gray-400 hover:text-white underline cursor-pointer transition-colors"
        >
          {{
            captureSource === 'camera'
              ? (isCameraEnabled && streamActive ? 'Desactivar cámara frontal' : 'Activar cámara frontal')
              : (streamActive ? 'Detener grabación de pantalla' : 'Activar grabación de pantalla')
          }}
        </button>
      </div>
    </main>

    <!-- 3. Bottom Controls Area -->
    <footer class="shrink-0 z-30 pb-2 bg-gradient-to-t from-black via-black/90 to-transparent">
      <!-- Duration pills: 15s / 60s (matching screenshot) -->
      <div v-if="!recordedMedia" class="flex items-center justify-center mb-4">
        <div class="bg-black/60 backdrop-blur-md rounded-full p-1 border border-white/10 flex items-center gap-1 shadow-md">
          <button
            type="button"
            @click="trakDuration = 15"
            class="px-4 py-1 rounded-full text-xs font-bold transition-all cursor-pointer"
            :class="trakDuration === 15 ? 'bg-white text-black shadow' : 'text-gray-400 hover:text-white'"
          >
            15s
          </button>
          <button
            type="button"
            @click="trakDuration = 60"
            class="px-4 py-1 rounded-full text-xs font-bold transition-all cursor-pointer"
            :class="trakDuration === 60 ? 'bg-white text-black shadow' : 'text-gray-400 hover:text-white'"
          >
            60s
          </button>
        </div>
      </div>

      <!-- Shutter & Controls Row (Gallery button, Shutter, Source toggle) -->
      <div v-if="!recordedMedia" class="flex items-center justify-around px-8 mb-4 max-w-md mx-auto w-full">
        <!-- Left: Gallery icon button -->
        <button
          type="button"
          @click="triggerGalleryPick"
          class="w-12 h-12 rounded-2xl bg-white/10 hover:bg-white/20 border border-white/20 flex items-center justify-center text-white transition-all cursor-pointer shadow-md hover:scale-105 active:scale-95"
          title="Elegir foto o video de galería"
        >
          <ImageIcon class="w-6 h-6" />
        </button>

        <!-- Center: Big circular recording shutter button -->
        <div
          @click="toggleRecording"
          class="w-20 h-20 rounded-full border-4 border-white/50 p-1 flex items-center justify-center transition-transform hover:scale-105 active:scale-95 cursor-pointer shadow-[0_0_20px_rgba(0,0,0,0.6)]"
          :class="isRecording ? 'border-[#f0254c] animate-pulse' : ''"
        >
          <button
            type="button"
            class="w-full h-full rounded-full bg-[#f0254c] flex items-center justify-center text-white shadow-[0_0_20px_rgba(240,37,76,0.5)] transition-all"
          >
            <Square v-if="isRecording" class="w-7 h-7 text-white fill-white rounded-sm" />
            <Video v-else class="w-7 h-7 text-white fill-white" />
          </button>
        </div>

        <!-- Right: Screen / Camera mode toggle -->
        <button
          type="button"
          @click="toggleCaptureSource"
          class="w-12 h-12 rounded-2xl bg-white/10 hover:bg-white/20 border border-white/20 flex items-center justify-center text-white transition-all cursor-pointer shadow-md hover:scale-105 active:scale-95"
          :title="captureSource === 'camera' ? 'Grabar pantalla' : 'Cámara frontal'"
        >
          <Monitor v-if="captureSource === 'camera'" class="w-5 h-5 text-sky-300" />
          <Camera v-else class="w-5 h-5 text-[#f0254c]" />
        </button>
      </div>

      <!-- Bottom Navigation: PUBLICACIÓN | TRAK (matching screenshot) -->
      <nav class="relative flex items-center justify-around border-t border-white/10 py-3.5 select-none bg-black">
        <button
          type="button"
          @click="emit('switch-tab', 'publicacion')"
          class="relative text-xs sm:text-sm font-bold tracking-wider uppercase text-gray-400 hover:text-white transition-colors cursor-pointer"
        >
          Publicación
        </button>

        <button
          type="button"
          class="relative text-xs sm:text-sm font-bold tracking-wider uppercase text-white transition-colors cursor-pointer"
        >
          <span>Trak</span>
          <!-- Red Active Underline Indicator matching screenshot -->
          <span class="absolute -bottom-3.5 left-1/2 -translate-x-1/2 w-12 h-[3px] rounded-full bg-[#f0254c] shadow-[0_0_10px_rgba(240,37,76,0.8)]" />
        </button>
      </nav>
    </footer>
  </div>
</template>

<style scoped>
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: scale(0.98);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.animate-fade-in {
  animation: fadeIn 220ms cubic-bezier(0.23, 1, 0.32, 1) forwards;
}
</style>
