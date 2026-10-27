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
  ArrowLeft,
  ArrowRight,
  SlidersHorizontal,
  Music,
  Type,
  Send,
  Gamepad2,
  VolumeX,
  Maximize2,
  Minimize2,
  Move,
  Trash2,
  Check,
  Play,
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

// Editor phase state (matching media_1793134078724_174a141b.png)
const showMetadataView = ref(false)
const editorVideoRef = ref<HTMLVideoElement | null>(null)
const isVideoPaused = ref(false)
const currentTime = ref(0)
const videoDuration = ref(3) // Default to 3s as seen in screenshot
const isSoundMuted = ref(false)
const playbackSpeed = ref<1 | 1.5 | 2>(1)
const showSpeedToast = ref(false)

// Portada / Cover Frame Picker state (matching media_1793135252722_a0ff5ac1.png)
const showCoverSelector = ref(false)
const selectedCoverTime = ref(0)
const tempCoverTime = ref(0)
const coverPreviewVideoRef = ref<HTMLVideoElement | null>(null)
const coverTimelineRef = ref<HTMLElement | null>(null)
let isScrubbingCover = false

// Text Editor & Draggable Overlay state
const isEditingTextModal = ref(false)
const videoTextOverlay = ref('')
const textColor = ref('#ffffff')
const textBgStyle = ref<'badge' | 'solid' | 'shadow'>('badge')
const textSize = ref<'sm' | 'base' | 'lg' | 'xl'>('base')
const videoContainerRef = ref<HTMLElement | null>(null)
const textPosition = ref({ x: 50, y: 75 })
let isDraggingText = false
let dragStartCoords = { x: 0, y: 0 }
let initialPercent = { x: 50, y: 75 }

const availableColors = [
  '#ffffff', // Blanco
  '#f0254c', // Carmesí Tracon
  '#facc15', // Amarillo Neón
  '#00f0ff', // Cyan Cyber
  '#22c55e', // Verde Toxic
  '#ec4899', // Rosa
  '#a855f7', // Púrpura Eléctrico
  '#000000', // Negro
]

// Thumbnail in View B metadata form
const metadataThumbnailVideoRef = ref<HTMLVideoElement | null>(null)

// Fit mode: 'contain' (sin cortes, video completo) | 'cover' (rellenar marco)
const fitMode = ref<'contain' | 'cover'>('contain')
const toggleFitMode = () => {
  fitMode.value = fitMode.value === 'contain' ? 'cover' : 'contain'
}

const videoAspectRatio = ref<number | null>(null)
const isLandscape = computed(() => (videoAspectRatio.value ?? 0.6) > 1.05)

// Metadata form state
const trakTitle = ref('')
const trakGame = ref('Specimen Zero')
const trakCategory = ref<'Récord' | 'Speedrun' | 'Supervivencia' | 'Sin daño'>('Récord')
const trakDifficulty = ref<'Pesadilla' | 'Difícil' | 'Normal' | 'Fácil'>('Pesadilla')

// Format helper
const formatTime = (seconds: number) => {
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins}:${String(secs).padStart(2, '0')}`
}

const formattedCurrentTime = computed(() => formatTime(currentTime.value))
const formattedVideoDuration = computed(() => formatTime(videoDuration.value))

const formattedSeconds = computed(() => {
  const s = recordedSeconds.value
  const mins = Math.floor(s / 60)
  const secs = s % 60
  return `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`
})

const recordingProgress = computed(() => {
  return Math.min(100, (recordedSeconds.value / trakDuration.value) * 100)
})

const playheadPositionPercent = computed(() => {
  if (videoDuration.value <= 0) return 0
  return Math.min(100, (currentTime.value / videoDuration.value) * 100)
})

const timeMarkers = computed(() => {
  const d = Math.max(1, Math.round(videoDuration.value || 3))
  return [
    formatTime(0),
    formatTime(Math.max(1, Math.round(d * 0.33))),
    formatTime(Math.max(2, Math.round(d * 0.66))),
    formatTime(d),
  ]
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

  // Trak is strictly for videos only
  if (!file.type.startsWith('video/')) {
    if (galleryFileInputRef.value) {
      galleryFileInputRef.value.value = ''
    }
    return
  }

  const url = URL.createObjectURL(file)
  recordedMedia.value = {
    url,
    type: 'video',
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
  showMetadataView.value = false
  showCoverSelector.value = false
  isEditingTextModal.value = false
  videoTextOverlay.value = ''
  selectedCoverTime.value = 0
  tempCoverTime.value = 0
  currentTime.value = 0
  isVideoPaused.value = false
  startStream()
}

// Editor Video playback hooks
const togglePlayPause = () => {
  if (isDraggingText) return
  if (!editorVideoRef.value) return
  if (editorVideoRef.value.paused) {
    editorVideoRef.value.play()
    isVideoPaused.value = false
  } else {
    editorVideoRef.value.pause()
    isVideoPaused.value = true
  }
}

const handleTimeUpdate = () => {
  if (editorVideoRef.value) {
    currentTime.value = editorVideoRef.value.currentTime
  }
}

const handleLoadedMetadata = () => {
  if (editorVideoRef.value) {
    if (editorVideoRef.value.duration && isFinite(editorVideoRef.value.duration)) {
      videoDuration.value = Math.max(1, Math.round(editorVideoRef.value.duration))
    }
    if (editorVideoRef.value.videoWidth && editorVideoRef.value.videoHeight) {
      videoAspectRatio.value = editorVideoRef.value.videoWidth / editorVideoRef.value.videoHeight
    }
  }
}

// Editor tools actions
const handleToggleSpeed = () => {
  if (playbackSpeed.value === 1) playbackSpeed.value = 1.5
  else if (playbackSpeed.value === 1.5) playbackSpeed.value = 2
  else playbackSpeed.value = 1

  if (editorVideoRef.value) {
    editorVideoRef.value.playbackRate = playbackSpeed.value
  }
  showSpeedToast.value = true
  setTimeout(() => {
    showSpeedToast.value = false
  }, 1400)
}

const handleToggleSound = () => {
  isSoundMuted.value = !isSoundMuted.value
  if (editorVideoRef.value) {
    editorVideoRef.value.muted = isSoundMuted.value
  }
}

const handleToggleText = () => {
  isEditingTextModal.value = true
}

const handleSetCover = () => {
  openCoverSelector()
}

const formatPrecisionTime = (s: number) => {
  const mins = Math.floor(s / 60)
  const secs = Math.floor(s % 60)
  const ms = Math.floor((s % 1) * 1000)
  return `${mins}:${String(secs).padStart(2, '0')}.${String(ms).padStart(3, '0')}`
}

const coverPositionPercent = computed(() => {
  if (videoDuration.value <= 0) return 0
  return Math.min(100, Math.max(0, (tempCoverTime.value / videoDuration.value) * 100))
})

const coverTimeMarkers = computed(() => {
  const d = Math.max(1, Math.round(videoDuration.value || 3))
  return [
    formatTime(0),
    formatTime(Math.max(1, Math.round(d * 0.5))),
    formatTime(d),
  ]
})

const openCoverSelector = () => {
  tempCoverTime.value = selectedCoverTime.value
  showCoverSelector.value = true
  nextTick(() => {
    if (coverPreviewVideoRef.value) {
      coverPreviewVideoRef.value.currentTime = tempCoverTime.value
    }
  })
}

const saveCoverSelection = () => {
  selectedCoverTime.value = tempCoverTime.value
  showCoverSelector.value = false
}

const cancelCoverSelection = () => {
  tempCoverTime.value = selectedCoverTime.value
  showCoverSelector.value = false
}

const onCoverVideoLoaded = () => {
  if (coverPreviewVideoRef.value && tempCoverTime.value > 0) {
    coverPreviewVideoRef.value.currentTime = tempCoverTime.value
  }
}

const onMetadataThumbnailLoaded = () => {
  if (metadataThumbnailVideoRef.value && selectedCoverTime.value > 0) {
    metadataThumbnailVideoRef.value.currentTime = selectedCoverTime.value
  }
}

const updateCoverTimeFromEvent = (e: PointerEvent) => {
  if (!coverTimelineRef.value) return
  const rect = coverTimelineRef.value.getBoundingClientRect()
  if (rect.width <= 0) return
  const x = Math.max(0, Math.min(rect.width, e.clientX - rect.left))
  const percent = x / rect.width
  const newTime = percent * (videoDuration.value || 3)
  tempCoverTime.value = newTime

  if (coverPreviewVideoRef.value) {
    coverPreviewVideoRef.value.currentTime = newTime
  }
}

const startCoverScrub = (e: PointerEvent) => {
  isScrubbingCover = true
  try {
    ;(e.currentTarget as HTMLElement).setPointerCapture(e.pointerId)
  } catch {}
  updateCoverTimeFromEvent(e)
}

const onCoverScrub = (e: PointerEvent) => {
  if (isScrubbingCover) {
    updateCoverTimeFromEvent(e)
  }
}

const stopCoverScrub = (e: PointerEvent) => {
  if (isScrubbingCover) {
    isScrubbingCover = false
    try {
      ;(e.currentTarget as HTMLElement).releasePointerCapture(e.pointerId)
    } catch {}
  }
}

// Editor timeline scrubbing handlers
const editorTimelineRef = ref<HTMLElement | null>(null)
let isScrubbingEditor = false

const updateEditorTimeFromEvent = (e: PointerEvent) => {
  if (!editorTimelineRef.value) return
  const rect = editorTimelineRef.value.getBoundingClientRect()
  if (rect.width <= 0) return
  const x = Math.max(0, Math.min(rect.width, e.clientX - rect.left))
  const percent = x / rect.width
  const newTime = percent * (videoDuration.value || 3)
  currentTime.value = newTime

  if (editorVideoRef.value) {
    editorVideoRef.value.currentTime = newTime
  }
}

const startEditorScrub = (e: PointerEvent) => {
  isScrubbingEditor = true
  try {
    ;(e.currentTarget as HTMLElement).setPointerCapture(e.pointerId)
  } catch {}
  updateEditorTimeFromEvent(e)
}

const onEditorScrub = (e: PointerEvent) => {
  if (isScrubbingEditor) {
    updateEditorTimeFromEvent(e)
  }
}

const stopEditorScrub = (e: PointerEvent) => {
  if (isScrubbingEditor) {
    isScrubbingEditor = false
    try {
      ;(e.currentTarget as HTMLElement).releasePointerCapture(e.pointerId)
    } catch {}
  }
}

// Text dragging pointer handlers
const onPointerDownText = (e: PointerEvent) => {
  e.stopPropagation()
  isDraggingText = true
  dragStartCoords = { x: e.clientX, y: e.clientY }
  initialPercent = { ...textPosition.value }
  try {
    ;(e.currentTarget as HTMLElement).setPointerCapture(e.pointerId)
  } catch {}
}

const onPointerMoveText = (e: PointerEvent) => {
  if (!isDraggingText || !videoContainerRef.value) return
  const rect = videoContainerRef.value.getBoundingClientRect()
  if (rect.width <= 0 || rect.height <= 0) return

  const deltaX = e.clientX - dragStartCoords.x
  const deltaY = e.clientY - dragStartCoords.y

  const percentDeltaX = (deltaX / rect.width) * 100
  const percentDeltaY = (deltaY / rect.height) * 100

  textPosition.value = {
    x: Math.min(90, Math.max(10, initialPercent.x + percentDeltaX)),
    y: Math.min(90, Math.max(10, initialPercent.y + percentDeltaY)),
  }
}

const onPointerUpText = (e: PointerEvent) => {
  if (isDraggingText) {
    isDraggingText = false
    try {
      ;(e.currentTarget as HTMLElement).releasePointerCapture(e.pointerId)
    } catch {}
  }
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
    content: trakTitle.value.trim() || (videoTextOverlay.value ? videoTextOverlay.value : `Nuevo Trak (${videoDuration.value}s)`),
    mediaUrl: recordedMedia.value.url,
    mediaType: recordedMedia.value.type,
    trakData: {
      title: trakTitle.value.trim() || `Trak: ${captureSource.value === 'camera' ? 'Cámara frontal' : 'Gameplay / Pantalla'}`,
      game: trakGame.value,
      category: trakCategory.value,
      difficulty: trakDifficulty.value,
      record: `${videoDuration.value}s`,
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
    <!-- Hidden file input for gallery pick (strictly videos for Trak) -->
    <input
      ref="galleryFileInputRef"
      type="file"
      accept="video/*,video/mp4,video/webm,video/quicktime,video/x-matroska,video/x-msvideo"
      class="hidden"
      @change="handleGalleryFile"
    />

    <!-- ======================================================== -->
    <!-- VIEW D: PORTADA SELECTOR (matches media_1793135252722_a0ff5ac1.png) -->
    <!-- ======================================================== -->
    <template v-if="recordedMedia && showCoverSelector">
      <!-- 1. Top Bar: Cancelar | Portada | Guardar -->
      <header class="h-14 px-4 sm:px-6 flex items-center justify-between shrink-0 z-30 bg-black/90 border-b border-[#1f212a]">
        <button
          type="button"
          @click="cancelCoverSelection"
          class="text-[#f0254c] hover:text-[#d9193f] font-semibold text-sm cursor-pointer transition-colors"
        >
          Cancelar
        </button>

        <h3 class="text-base sm:text-lg font-bold text-white tracking-tight">
          Portada
        </h3>

        <button
          type="button"
          @click="saveCoverSelection"
          class="px-4 py-1.5 rounded-full bg-[#f0254c] hover:bg-[#d9193f] text-white text-sm font-bold shadow-md cursor-pointer active:scale-95 transition-all"
        >
          Guardar
        </button>
      </header>

      <!-- 2. Main Frame Preview at tempCoverTime -->
      <main class="flex-1 flex flex-col items-center justify-between px-4 py-3 min-h-0 overflow-y-auto no-scrollbar">
        <!-- Frame Preview Container -->
        <div
          class="relative w-full mx-auto rounded-3xl overflow-hidden shadow-2xl bg-[#090a10] border border-white/10 flex items-center justify-center shrink-0"
          :class="[
            isLandscape
              ? 'max-w-[420px] aspect-video max-h-[300px]'
              : 'max-w-[340px] sm:max-w-[380px] h-[340px] sm:h-[400px]'
          ]"
        >
          <!-- Ambient blurred background -->
          <div class="absolute inset-0 overflow-hidden pointer-events-none opacity-30 filter blur-2xl scale-110">
            <video
              v-if="recordedMedia.type === 'video'"
              :src="recordedMedia.url"
              class="w-full h-full object-cover"
              muted
            />
            <img
              v-else
              :src="recordedMedia.url"
              alt="Ambience"
              class="w-full h-full object-cover"
            />
          </div>

          <!-- Video paused at chosen frame timestamp -->
          <video
            v-if="recordedMedia.type === 'video'"
            ref="coverPreviewVideoRef"
            :src="recordedMedia.url"
            playsinline
            muted
            disablepictureinpicture
            disableremoteplayback
            controlsList="nodownload nofullscreen noremoteplayback noplaybackrate"
            preload="auto"
            class="relative z-10 max-w-full max-h-full object-contain pointer-events-none"
            @loadedmetadata="onCoverVideoLoaded"
          />
          <img
            v-else
            :src="recordedMedia.url"
            alt="Cover"
            class="relative z-10 max-w-full max-h-full object-contain"
          />

          <!-- Text overlay preview (if exists) -->
          <div
            v-if="videoTextOverlay"
            class="absolute z-20 pointer-events-none"
            :style="{
              left: `${textPosition.x}%`,
              top: `${textPosition.y}%`,
              transform: 'translate(-50%, -50%)',
            }"
          >
            <div
              class="px-3.5 py-1.5 rounded-xl font-bold tracking-wide shadow-lg border border-white/10"
              :class="[
                textBgStyle === 'badge' ? 'bg-black/75 backdrop-blur-md' : '',
                textBgStyle === 'solid' ? 'bg-white shadow-xl' : '',
                textBgStyle === 'shadow' ? 'bg-transparent drop-shadow-[0_2px_8px_rgba(0,0,0,0.95)]' : '',
                textSize === 'sm' ? 'text-xs' : '',
                textSize === 'base' ? 'text-sm' : '',
                textSize === 'lg' ? 'text-base' : '',
                textSize === 'xl' ? 'text-lg' : '',
              ]"
              :style="{
                color: textBgStyle === 'solid' ? (textColor === '#ffffff' ? '#000000' : textColor) : textColor,
              }"
            >
              {{ videoTextOverlay }}
            </div>
          </div>
        </div>

        <!-- 3. Bottom Scrubber Section matching media_1793135252722_a0ff5ac1.png -->
        <div class="w-full max-w-[420px] pt-4 pb-2">
          <!-- Header: Elige el frame de portada + 0:00.000 counter -->
          <div class="flex items-center justify-between px-1 mb-2">
            <div class="flex items-center gap-2">
              <ImageIcon class="w-4 h-4 text-[#f0254c]" />
              <span class="text-sm font-bold text-white tracking-wide">
                Elige el frame de portada
              </span>
            </div>
            <span class="text-sm font-mono font-bold text-[#f0254c] tracking-wider">
              {{ formatPrecisionTime(tempCoverTime) }}
            </span>
          </div>

          <!-- Timeline scrubber box -->
          <div
            ref="coverTimelineRef"
            class="relative p-2.5 rounded-2xl border border-white/15 bg-[#121319] select-none cursor-pointer touch-none"
            @pointerdown="startCoverScrub"
            @pointermove="onCoverScrub"
            @pointerup="stopCoverScrub"
            @pointercancel="stopCoverScrub"
          >
            <!-- Time numbers row: 0:00 0:01 0:02 -->
            <div class="flex items-center justify-between px-2 mb-1.5 text-[11px] font-mono text-gray-400">
              <span v-for="marker in coverTimeMarkers" :key="marker">{{ marker }}</span>
            </div>

            <!-- Filmstrip frames track (taller, full-length frame tiles) -->
            <div class="relative h-16 sm:h-20 rounded-xl overflow-hidden bg-black/90 border border-white/10 flex items-center">
              <div class="flex-1 h-full flex items-center justify-between overflow-hidden opacity-85 gap-1.5 px-1">
                <div
                  v-for="idx in (isLandscape ? 5 : 7)"
                  :key="idx"
                  class="h-full rounded-md bg-[#16121c] border border-white/10 relative overflow-hidden flex items-center justify-center shrink-0"
                  :class="isLandscape ? 'flex-1' : 'aspect-[9/16]'"
                >
                  <video
                    v-if="recordedMedia && recordedMedia.type === 'video'"
                    :src="recordedMedia.url"
                    class="w-full h-full object-cover opacity-85 pointer-events-none"
                    muted
                    playsinline
                  />
                  <img
                    v-else-if="recordedMedia"
                    :src="recordedMedia.url"
                    class="w-full h-full object-cover opacity-85 pointer-events-none"
                  />
                </div>
              </div>

              <!-- Red vertical needle playhead with top handle -->
              <div
                class="absolute top-0 bottom-0 pointer-events-none -translate-x-1/2 z-20"
                :style="{ left: `${coverPositionPercent}%` }"
              >
                <div class="w-0 h-0 border-l-[5px] border-l-transparent border-r-[5px] border-r-transparent border-t-[7px] border-t-[#f0254c] -translate-x-[4px]" />
                <div class="w-[2px] h-full bg-[#f0254c] shadow-[0_0_8px_#f0254c]" />
              </div>
            </div>
          </div>
        </div>
      </main>
    </template>

    <!-- ======================================================== -->
    <!-- VIEW A: EDITAR TRAK (exact match to media_1793134078724_174a141b.png) -->
    <!-- ======================================================== -->
    <template v-else-if="recordedMedia && !showMetadataView">
      <!-- 1. Top Bar: Back Arrow + Centered "Editar Trak" -->
      <header class="h-14 px-4 sm:px-6 flex items-center justify-between shrink-0 z-30 bg-black/90">
        <button
          type="button"
          @click="resetRecordedMedia"
          class="p-2 -ml-2 rounded-full text-white hover:bg-white/10 transition-colors cursor-pointer"
          title="Volver a grabar"
        >
          <ArrowLeft class="w-6 h-6" />
        </button>

        <h2 class="text-base sm:text-lg font-bold text-white tracking-wide">
          Editar Trak
        </h2>

        <div class="w-8" />
      </header>

      <!-- 2. Main Content: Video Preview + Timeline + Tools -->
      <main class="flex-1 flex flex-col items-center justify-between px-4 py-2 min-h-0 overflow-y-auto no-scrollbar">
        <!-- Video Preview Container (Wider, adaptive to landscape / portrait, no cropping) -->
        <div
          ref="videoContainerRef"
          class="relative w-full mx-auto rounded-3xl overflow-hidden shadow-2xl bg-[#090a10] border border-white/10 flex items-center justify-center shrink-0 transition-all duration-300 touch-none select-none"
          :class="[
            isLandscape
              ? 'max-w-[420px] aspect-video max-h-[290px]'
              : 'max-w-[340px] sm:max-w-[380px] h-[340px] sm:h-[390px]'
          ]"
        >
          <!-- Ambient blurred background for smooth edges and letterbox fill -->
          <div class="absolute inset-0 overflow-hidden pointer-events-none opacity-30 filter blur-2xl scale-110">
            <video
              v-if="recordedMedia.type === 'video'"
              :src="recordedMedia.url"
              autoplay
              loop
              playsinline
              muted
              class="w-full h-full object-cover"
            />
            <img
              v-else
              :src="recordedMedia.url"
              alt="Ambience"
              class="w-full h-full object-cover"
            />
          </div>

          <!-- Clickable surface to toggle play / pause -->
          <div
            class="absolute inset-0 z-10 cursor-pointer"
            @click="togglePlayPause"
          />

          <!-- Foreground Main Video / Image -->
          <video
            v-if="recordedMedia.type === 'video'"
            ref="editorVideoRef"
            :src="recordedMedia.url"
            autoplay
            loop
            playsinline
            disablepictureinpicture
            disableremoteplayback
            controlsList="nodownload nofullscreen noremoteplayback noplaybackrate"
            :muted="isSoundMuted"
            class="relative z-10 transition-all duration-200 pointer-events-none"
            :class="fitMode === 'contain' ? 'max-w-full max-h-full object-contain' : 'w-full h-full object-cover'"
            @timeupdate="handleTimeUpdate"
            @loadedmetadata="handleLoadedMetadata"
            @play="isVideoPaused = false"
            @pause="isVideoPaused = true"
          />
          <img
            v-else
            :src="recordedMedia.url"
            alt="Preview Trak"
            class="relative z-10 transition-all duration-200 pointer-events-none"
            :class="fitMode === 'contain' ? 'max-w-full max-h-full object-contain' : 'w-full h-full object-cover'"
          />

          <!-- Play indicator when paused -->
          <Transition name="fade">
            <div
              v-if="isVideoPaused"
              class="absolute inset-0 z-15 flex items-center justify-center pointer-events-none bg-black/30 backdrop-blur-[1px]"
            >
              <div class="w-14 h-14 rounded-full bg-black/70 border border-white/20 flex items-center justify-center shadow-2xl backdrop-blur-md">
                <Play class="w-6 h-6 text-white fill-white ml-0.5" />
              </div>
            </div>
          </Transition>

          <!-- Fit / Fill mode toggle button: Ajustar (contain, sin cortes) vs Rellenar (cover) -->
          <button
            type="button"
            @click="toggleFitMode"
            class="absolute top-3 right-3 z-30 px-2.5 py-1 rounded-xl bg-black/75 hover:bg-black/90 border border-white/20 text-[11px] font-semibold text-white/90 hover:text-white flex items-center gap-1.5 backdrop-blur-md transition-all cursor-pointer shadow-lg active:scale-95"
            :title="fitMode === 'contain' ? 'Modo actual: Completo (sin cortes). Toca para rellenar.' : 'Modo actual: Rellenar. Toca para ver completo sin cortes.'"
          >
            <Maximize2 v-if="fitMode === 'contain'" class="w-3.5 h-3.5 text-[#f0254c]" />
            <Minimize2 v-else class="w-3.5 h-3.5 text-sky-400" />
            <span>{{ fitMode === 'contain' ? 'Ajustar' : 'Rellenar' }}</span>
          </button>

          <!-- Draggable Text overlay on video -->
          <div
            v-if="videoTextOverlay"
            class="absolute z-20 select-none cursor-grab active:cursor-grabbing transition-transform touch-none group"
            :style="{
              left: `${textPosition.x}%`,
              top: `${textPosition.y}%`,
              transform: 'translate(-50%, -50%)',
            }"
            @pointerdown="onPointerDownText"
            @pointermove="onPointerMoveText"
            @pointerup="onPointerUpText"
            @pointercancel="onPointerUpText"
            @dblclick="isEditingTextModal = true"
          >
            <!-- Styled Text pill -->
            <div
              class="px-3.5 py-1.5 rounded-xl font-bold tracking-wide transition-all shadow-xl flex items-center gap-1.5 border border-white/10 group-hover:border-[#f0254c]/60"
              :class="[
                textBgStyle === 'badge' ? 'bg-black/75 backdrop-blur-md' : '',
                textBgStyle === 'solid' ? 'bg-white shadow-2xl' : '',
                textBgStyle === 'shadow' ? 'bg-transparent drop-shadow-[0_2px_8px_rgba(0,0,0,0.95)]' : '',
                textSize === 'sm' ? 'text-xs sm:text-sm' : '',
                textSize === 'base' ? 'text-sm sm:text-base' : '',
                textSize === 'lg' ? 'text-base sm:text-lg' : '',
                textSize === 'xl' ? 'text-lg sm:text-xl' : '',
              ]"
              :style="{
                color: textBgStyle === 'solid' ? (textColor === '#ffffff' ? '#000000' : textColor) : textColor,
              }"
            >
              <span>{{ videoTextOverlay }}</span>
            </div>

            <!-- Drag indicator tooltip -->
            <div class="opacity-0 group-hover:opacity-100 transition-opacity absolute -top-6 left-1/2 -translate-x-1/2 px-2 py-0.5 rounded bg-black/85 text-[10px] text-gray-300 font-normal pointer-events-none whitespace-nowrap shadow-md">
              Arrastra para mover • Doble clic para editar
            </div>
          </div>

          <!-- Speed Toast Badge -->
          <Transition name="fade">
            <div
              v-if="showSpeedToast"
              class="absolute top-3 left-3 z-30 px-3 py-1 rounded-full bg-black/85 backdrop-blur-md border border-white/20 text-xs font-bold text-white"
            >
              Velocidad: {{ playbackSpeed }}x
            </div>
          </Transition>
        </div>

        <!-- Video Time Counter (Left aligned) -->
        <div class="w-full max-w-[420px] px-1 mt-2 text-left">
          <span class="text-xs sm:text-sm font-mono text-gray-300 font-semibold">
            {{ formattedCurrentTime }} / {{ formattedVideoDuration }}
          </span>
        </div>

        <!-- Filmstrip & Timeline Box matching screenshot (taller, full-length frame tiles, interactive scrubbing) -->
        <div
          ref="editorTimelineRef"
          class="w-full max-w-[420px] mt-2 p-2.5 rounded-2xl border border-white/15 bg-[#121319] select-none cursor-pointer touch-none"
          @pointerdown="startEditorScrub"
          @pointermove="onEditorScrub"
          @pointerup="stopEditorScrub"
          @pointercancel="stopEditorScrub"
        >
          <!-- Time numbers row: 0:00 0:01 0:02 0:03 -->
          <div class="flex items-center justify-between px-2 mb-1.5 text-[11px] font-mono text-gray-400">
            <span v-for="marker in timeMarkers" :key="marker">{{ marker }}</span>
          </div>

          <!-- Filmstrip frames track (taller, full-length frame tiles) -->
          <div class="relative h-16 sm:h-20 rounded-xl overflow-hidden bg-black/90 border border-white/10 flex items-center">
            <!-- Simulated clip thumbnails frames -->
            <div class="flex-1 h-full flex items-center justify-between overflow-hidden opacity-85 gap-1.5 px-1">
              <div
                v-for="idx in (isLandscape ? 5 : 7)"
                :key="idx"
                class="h-full rounded-md bg-[#16121c] border border-white/10 relative overflow-hidden flex items-center justify-center shrink-0"
                :class="isLandscape ? 'flex-1' : 'aspect-[9/16]'"
              >
                <video
                  v-if="recordedMedia && recordedMedia.type === 'video'"
                  :src="recordedMedia.url"
                  class="w-full h-full object-cover opacity-85 pointer-events-none"
                  muted
                  playsinline
                  preload="auto"
                />
                <img
                  v-else-if="recordedMedia"
                  :src="recordedMedia.url"
                  class="w-full h-full object-cover opacity-85 pointer-events-none"
                />
              </div>
            </div>

            <!-- Red playhead indicator with top triangle and vertical needle -->
            <div
              class="absolute top-0 bottom-0 pointer-events-none -translate-x-1/2 z-20"
              :style="{ left: `${playheadPositionPercent}%` }"
            >
              <div class="w-0 h-0 border-l-[5px] border-l-transparent border-r-[5px] border-r-transparent border-t-[7px] border-t-[#f0254c] -translate-x-[4px]" />
              <div class="w-[2px] h-full bg-[#f0254c] shadow-[0_0_8px_#f0254c]" />
            </div>
          </div>
        </div>

        <!-- Text Customizer Modal (Color picker, styles, input) -->
        <Transition name="fade">
          <div
            v-if="isEditingTextModal"
            class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md"
            @click.self="isEditingTextModal = false"
          >
            <div class="w-full max-w-sm rounded-2xl bg-[#131118] border border-[#2d1b2e] p-5 shadow-2xl space-y-4">
              <div class="flex items-center justify-between">
                <div class="flex items-center gap-2 text-white font-bold text-sm">
                  <Type class="w-4 h-4 text-[#f0254c]" />
                  <span>Texto en el video</span>
                </div>
                <button
                  type="button"
                  @click="isEditingTextModal = false"
                  class="p-1 rounded-full text-gray-400 hover:text-white transition-colors cursor-pointer"
                >
                  <X class="w-4 h-4" />
                </button>
              </div>

              <!-- Input text -->
              <div>
                <input
                  v-model="videoTextOverlay"
                  type="text"
                  placeholder="Escribe tu texto..."
                  maxlength="60"
                  class="w-full px-3.5 py-2.5 rounded-xl bg-black/60 border border-white/15 text-sm text-white placeholder:text-gray-500 focus:outline-none focus:border-[#f0254c] transition-colors"
                  autofocus
                  @keydown.enter="isEditingTextModal = false"
                />
              </div>

              <!-- Color Palette -->
              <div>
                <label class="block text-[11px] font-bold uppercase tracking-wider text-gray-400 mb-2">
                  Color del texto
                </label>
                <div class="flex items-center gap-2.5 flex-wrap">
                  <button
                    v-for="color in availableColors"
                    :key="color"
                    type="button"
                    @click="textColor = color"
                    class="w-7 h-7 rounded-full border-2 transition-transform cursor-pointer relative"
                    :class="textColor === color ? 'scale-110 border-white ring-2 ring-[#f0254c]' : 'border-white/20 hover:scale-105'"
                    :style="{ backgroundColor: color }"
                  />
                </div>
              </div>

              <!-- Style options -->
              <div>
                <label class="block text-[11px] font-bold uppercase tracking-wider text-gray-400 mb-2">
                  Estilo de fondo
                </label>
                <div class="grid grid-cols-3 gap-2">
                  <button
                    type="button"
                    @click="textBgStyle = 'badge'"
                    class="py-1.5 px-2 rounded-lg text-xs font-semibold border transition-all cursor-pointer text-center"
                    :class="textBgStyle === 'badge' ? 'bg-[#f0254c]/20 border-[#f0254c] text-white' : 'bg-black/40 border-white/10 text-gray-400 hover:text-white'"
                  >
                    Oscuro
                  </button>
                  <button
                    type="button"
                    @click="textBgStyle = 'solid'"
                    class="py-1.5 px-2 rounded-lg text-xs font-semibold border transition-all cursor-pointer text-center"
                    :class="textBgStyle === 'solid' ? 'bg-[#f0254c]/20 border-[#f0254c] text-white' : 'bg-black/40 border-white/10 text-gray-400 hover:text-white'"
                  >
                    Sólido
                  </button>
                  <button
                    type="button"
                    @click="textBgStyle = 'shadow'"
                    class="py-1.5 px-2 rounded-lg text-xs font-semibold border transition-all cursor-pointer text-center"
                    :class="textBgStyle === 'shadow' ? 'bg-[#f0254c]/20 border-[#f0254c] text-white' : 'bg-black/40 border-white/10 text-gray-400 hover:text-white'"
                  >
                    Solo texto
                  </button>
                </div>
              </div>

              <!-- Hint about dragging -->
              <div class="p-2.5 rounded-xl bg-white/5 border border-white/10 text-[11px] text-gray-400 flex items-center gap-2">
                <Move class="w-4 h-4 text-[#f0254c] shrink-0" />
                <span>Puedes arrastrar el texto directamente sobre el video para ubicarlo donde quieras.</span>
              </div>

              <!-- Actions -->
              <div class="flex items-center justify-between pt-2">
                <button
                  v-if="videoTextOverlay"
                  type="button"
                  @click="videoTextOverlay = ''; isEditingTextModal = false"
                  class="text-xs text-red-400 hover:text-red-300 font-semibold cursor-pointer flex items-center gap-1"
                >
                  <Trash2 class="w-3.5 h-3.5" />
                  <span>Eliminar</span>
                </button>
                <div v-else />

                <button
                  type="button"
                  @click="isEditingTextModal = false"
                  class="px-5 py-2 rounded-xl bg-[#f0254c] hover:bg-[#d9193f] text-white font-bold text-xs cursor-pointer shadow-md active:scale-95 transition-all flex items-center gap-1.5"
                >
                  <Check class="w-3.5 h-3.5" />
                  <span>Listo</span>
                </button>
              </div>
            </div>
          </div>
        </Transition>

        <!-- 4 Editing Tool Pills Row (matching screenshot) -->
        <div class="w-full max-w-[420px] grid grid-cols-4 gap-2 mt-3 mb-3">
          <!-- 1. Editar -->
          <button
            type="button"
            @click="handleToggleSpeed"
            class="py-2 px-1 rounded-xl bg-[#15121a] border border-white/10 hover:border-[#f0254c]/50 text-white font-semibold text-xs flex items-center justify-center gap-1.5 transition-all cursor-pointer active:scale-95 shadow-sm"
            title="Cambiar velocidad"
          >
            <SlidersHorizontal class="w-3.5 h-3.5 text-[#f0254c]" />
            <span>Editar</span>
          </button>

          <!-- 2. Sonido -->
          <button
            type="button"
            @click="handleToggleSound"
            class="py-2 px-1 rounded-xl bg-[#15121a] border border-white/10 hover:border-[#f0254c]/50 text-white font-semibold text-xs flex items-center justify-center gap-1.5 transition-all cursor-pointer active:scale-95 shadow-sm"
            :title="isSoundMuted ? 'Activar sonido' : 'Silenciar sonido'"
          >
            <VolumeX v-if="isSoundMuted" class="w-3.5 h-3.5 text-gray-400" />
            <Music v-else class="w-3.5 h-3.5 text-[#f0254c]" />
            <span>Sonido</span>
          </button>

          <!-- 3. Texto -->
          <button
            type="button"
            @click="handleToggleText"
            class="py-2 px-1 rounded-xl bg-[#15121a] border border-white/10 hover:border-[#f0254c]/50 text-white font-semibold text-xs flex items-center justify-center gap-1.5 transition-all cursor-pointer active:scale-95 shadow-sm"
            :class="videoTextOverlay ? 'border-[#f0254c] bg-[#f0254c]/15 text-white' : ''"
            title="Añadir o editar texto"
          >
            <Type class="w-3.5 h-3.5 text-[#f0254c]" />
            <span>Texto</span>
          </button>

          <!-- 4. Portada -->
          <button
            type="button"
            @click="handleSetCover"
            class="py-2 px-1 rounded-xl bg-[#15121a] border border-white/10 hover:border-[#f0254c]/50 text-white font-semibold text-xs flex items-center justify-center gap-1.5 transition-all cursor-pointer active:scale-95 shadow-sm"
            :class="selectedCoverTime > 0 ? 'border-[#f0254c] bg-[#f0254c]/15 text-white' : ''"
            title="Elegir frame de portada"
          >
            <ImageIcon class="w-3.5 h-3.5 text-[#f0254c]" />
            <span>Portada</span>
          </button>
        </div>

        <!-- 5. Minimalist CTA Button: Portada y datos -->
        <div class="w-full max-w-[420px] pt-1 pb-1">
          <button
            type="button"
            @click="showMetadataView = true"
            class="w-full py-2.5 sm:py-3 rounded-xl bg-[#f0254c] hover:bg-[#d9193f] text-white font-semibold text-sm flex items-center justify-center gap-2 shadow-sm hover:shadow-[0_2px_14px_rgba(240,37,76,0.3)] transition-all duration-200 cursor-pointer active:scale-98"
          >
            <span>Portada y datos</span>
            <ArrowRight class="w-4 h-4 text-white" />
          </button>
        </div>
      </main>
    </template>

    <!-- ======================================================== -->
    <!-- VIEW B: PORTADA Y DATOS (Final step before publishing) -->
    <!-- ======================================================== -->
    <template v-else-if="recordedMedia && showMetadataView">
      <header class="h-14 px-4 sm:px-6 flex items-center justify-between shrink-0 z-30 bg-black/90 border-b border-[#1f212a]">
        <button
          type="button"
          @click="showMetadataView = false"
          class="p-2 -ml-2 rounded-full text-white hover:bg-white/10 transition-colors cursor-pointer"
          title="Volver a edición"
        >
          <ArrowLeft class="w-6 h-6" />
        </button>

        <h2 class="text-base sm:text-lg font-bold text-white tracking-wide">
          Portada y datos
        </h2>

        <div class="w-8" />
      </header>

      <main class="flex-1 px-5 py-4 min-h-0 overflow-y-auto no-scrollbar space-y-4 max-w-lg mx-auto w-full">
        <!-- Media thumbnail + Title card -->
        <div class="flex gap-4 p-3.5 rounded-2xl bg-[#141018] border border-[#2d1b2e]">
          <div class="w-20 h-28 rounded-xl overflow-hidden bg-black shrink-0 border border-white/10 relative flex items-center justify-center">
            <video
              v-if="recordedMedia.type === 'video'"
              ref="metadataThumbnailVideoRef"
              :src="recordedMedia.url"
              class="w-full h-full object-cover"
              muted
              playsinline
              preload="auto"
              @loadedmetadata="onMetadataThumbnailLoaded"
            />
            <img
              v-else
              :src="recordedMedia.url"
              alt="Cover"
              class="w-full h-full object-cover"
            />
            <span class="absolute bottom-1 right-1 px-1.5 py-0.5 rounded bg-black/70 text-[9px] font-mono text-white">
              {{ formattedVideoDuration }}
            </span>
          </div>

          <div class="flex-1 min-w-0 flex flex-col justify-between">
            <div>
              <label class="block text-[11px] font-bold uppercase tracking-wider text-gray-400 mb-1">
                Título o descripción
              </label>
              <textarea
                v-model="trakTitle"
                rows="3"
                placeholder="Escribe de qué trata tu Trak..."
                class="w-full p-2.5 rounded-xl bg-black/60 border border-[#232532] text-xs sm:text-sm text-white placeholder:text-gray-500 focus:outline-none focus:border-[#f0254c] resize-none"
              />
            </div>
          </div>
        </div>

        <!-- Videojuego -->
        <div>
          <label class="block text-xs font-bold uppercase tracking-wider text-gray-400 mb-2">
            Videojuego
          </label>
          <div class="flex items-center gap-2.5 p-3 rounded-xl bg-[#141018] border border-[#2d1b2e]">
            <Gamepad2 class="w-4 h-4 text-[#f0254c]" />
            <input
              v-model="trakGame"
              type="text"
              class="flex-1 bg-transparent text-sm text-white font-semibold focus:outline-none"
            />
          </div>
        </div>

        <!-- Categoría -->
        <div>
          <label class="block text-xs font-bold uppercase tracking-wider text-gray-400 mb-2">
            Modalidad
          </label>
          <div class="grid grid-cols-2 sm:grid-cols-4 gap-2">
            <button
              v-for="cat in (['Récord', 'Speedrun', 'Supervivencia', 'Sin daño'] as const)"
              :key="cat"
              type="button"
              @click="trakCategory = cat"
              class="py-2 px-2.5 rounded-xl text-xs font-semibold border transition-all cursor-pointer text-center"
              :class="trakCategory === cat ? 'bg-[#f0254c]/20 border-[#f0254c] text-white shadow-sm' : 'bg-[#141018] border-[#241a27] text-gray-400 hover:text-white'"
            >
              {{ cat }}
            </button>
          </div>
        </div>

        <!-- Dificultad -->
        <div>
          <label class="block text-xs font-bold uppercase tracking-wider text-gray-400 mb-2">
            Dificultad
          </label>
          <div class="grid grid-cols-2 sm:grid-cols-4 gap-2">
            <button
              v-for="diff in (['Fácil', 'Normal', 'Difícil', 'Pesadilla'] as const)"
              :key="diff"
              type="button"
              @click="trakDifficulty = diff"
              class="py-2 px-2.5 rounded-xl text-xs font-semibold border transition-all cursor-pointer text-center"
              :class="trakDifficulty === diff ? 'bg-[#79141b]/40 border-[#f0254c] text-white' : 'bg-[#141018] border-[#241a27] text-gray-400 hover:text-white'"
            >
              {{ diff }}
            </button>
          </div>
        </div>

        <!-- Publicar Button -->
        <button
          type="button"
          @click="handlePublishTrak"
          class="w-full py-2.5 sm:py-3 mt-2 mb-2 rounded-xl bg-[#f0254c] hover:bg-[#d9193f] text-white font-semibold text-sm flex items-center justify-center gap-2 shadow-sm hover:shadow-[0_2px_14px_rgba(240,37,76,0.3)] transition-all duration-200 cursor-pointer active:scale-98"
        >
          <Send class="w-4 h-4 text-white" />
          <span>Publicar Trak</span>
        </button>
      </main>
    </template>

    <!-- ======================================================== -->
    <!-- VIEW C: CAPTURE / RECORDING VIEWFINDER (initial camera / screen state) -->
    <!-- ======================================================== -->
    <template v-else>
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

      <!-- Viewfinder & Content Area -->
      <main class="flex-1 flex flex-col items-center justify-center relative overflow-hidden px-4">
        <!-- Live camera / screen stream -->
        <video
          v-if="streamActive"
          ref="videoElementRef"
          autoplay
          playsinline
          muted
          class="absolute inset-0 w-full h-full object-cover"
        />

        <!-- Fallback State (when idle or without stream) -->
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
                : (streamActive ? 'Detener grabación de pantalla' : 'Intentar activar grabación de pantalla')
            }}
          </button>
        </div>
      </main>

      <!-- Bottom Controls Area -->
      <footer class="shrink-0 z-30 pb-2 bg-gradient-to-t from-black via-black/90 to-transparent">
        <!-- Duration pills: 15s / 60s (matching screenshot) -->
        <div class="flex items-center justify-center mb-4">
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
        <div class="flex items-center justify-around px-8 mb-4 max-w-md mx-auto w-full">
          <!-- Left: Gallery icon button -->
          <button
            type="button"
            @click="triggerGalleryPick"
            class="w-12 h-12 rounded-2xl bg-white/10 hover:bg-white/20 border border-white/20 flex items-center justify-center text-white transition-all cursor-pointer shadow-md hover:scale-105 active:scale-95"
            title="Elegir video de la galería"
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
            <span class="absolute -bottom-3.5 left-1/2 -translate-x-1/2 w-12 h-[3px] rounded-full bg-[#f0254c] shadow-[0_0_10px_rgba(240,37,76,0.8)]" />
          </button>
        </nav>
      </footer>
    </template>
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

.fade-enter-active,
.fade-leave-active {
  transition: opacity 150ms ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
