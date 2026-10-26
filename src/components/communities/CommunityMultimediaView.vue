<script setup lang="ts">
import { ref } from 'vue'
import {
  Upload,
  Play,
  Heart,
  MessageSquare,
  Eye,
  X,
  Film,
  Sparkles,
} from 'lucide-vue-next'

interface Props {
  communityName: string
}

defineProps<Props>()

interface MediaItem {
  id: string
  title: string
  authorName: string
  authorAvatarBg: string
  category: 'Clips' | 'Capturas' | 'Guías' | 'Arte'
  duration?: string
  likes: number
  isLiked?: boolean
  commentsCount: number
  views: number
  timeAgo: string
  accentColor: string
  imageGradient: string
  tagBadge: string
}

const activeFilter = ref<'Todos' | 'Clips' | 'Capturas' | 'Guías' | 'Arte'>('Todos')
const isUploadModalOpen = ref(false)

const newTitle = ref('')
const newCategory = ref<'Clips' | 'Capturas' | 'Guías' | 'Arte'>('Capturas')

const mediaList = ref<MediaItem[]>([
  {
    id: 'med-1',
    title: 'Escape extremo de la criatura en el laboratorio nivel 3',
    authorName: 'Braian Andrés',
    authorAvatarBg: '#232634',
    category: 'Clips',
    duration: '02:45',
    likes: 48,
    isLiked: false,
    commentsCount: 14,
    views: 420,
    timeAgo: 'hace 2 h',
    accentColor: '#f0254c',
    imageGradient: 'from-[#3d0912] via-[#1a0509] to-[#0d0d12]',
    tagBadge: 'CLIP DESTACADO',
  },
  {
    id: 'med-2',
    title: 'Easter egg oculto en el quirófano abandonado',
    authorName: 'Axel',
    authorAvatarBg: '#1f2832',
    category: 'Capturas',
    likes: 31,
    isLiked: true,
    commentsCount: 6,
    views: 215,
    timeAgo: 'hace 5 h',
    accentColor: '#38bdf8',
    imageGradient: 'from-[#082f49] via-[#0c1929] to-[#0a0f1d]',
    tagBadge: 'SECRET',
  },
  {
    id: 'med-3',
    title: 'Ruta más rápida para desactivar las 4 cámaras de seguridad',
    authorName: 'Mr Meat',
    authorAvatarBg: '#1e2621',
    category: 'Guías',
    duration: '04:12',
    likes: 67,
    isLiked: false,
    commentsCount: 22,
    views: 680,
    timeAgo: 'ayer',
    accentColor: '#10b981',
    imageGradient: 'from-[#064e3b] via-[#07241c] to-[#091512]',
    tagBadge: 'GUÍA RÁPIDA',
  },
  {
    id: 'med-4',
    title: 'Fanart conceptual: La criatura acechando en las sombras',
    authorName: 'Dayam',
    authorAvatarBg: '#2e2025',
    category: 'Arte',
    likes: 89,
    isLiked: false,
    commentsCount: 19,
    views: 910,
    timeAgo: 'hace 2 d',
    accentColor: '#ec4899',
    imageGradient: 'from-[#4a044e] via-[#240628] to-[#120816]',
    tagBadge: 'ARTE DE LA COMUNIDAD',
  },
  {
    id: 'med-5',
    title: 'Momento de terror puro cuando la luz parpadea a 0% de batería',
    authorName: 'Leogamer2010',
    authorAvatarBg: '#2a2233',
    category: 'Clips',
    duration: '00:58',
    likes: 42,
    isLiked: false,
    commentsCount: 8,
    views: 350,
    timeAgo: 'hace 3 d',
    accentColor: '#eab308',
    imageGradient: 'from-[#422006] via-[#1f1105] to-[#0f0c08]',
    tagBadge: 'JUMPSCARE',
  },
  {
    id: 'med-6',
    title: 'Mapa completo de las alcantarillas del hospital',
    authorName: 'Octavio',
    authorAvatarBg: '#252528',
    category: 'Guías',
    likes: 55,
    isLiked: false,
    commentsCount: 11,
    views: 520,
    timeAgo: 'hace 4 d',
    accentColor: '#a855f7',
    imageGradient: 'from-[#3b0764] via-[#1a082c] to-[#0e0717]',
    tagBadge: 'MAPA',
  },
])

const filterCategories = ['Todos', 'Clips', 'Capturas', 'Guías', 'Arte'] as const

const filteredMedia = () => {
  if (activeFilter.value === 'Todos') return mediaList.value
  return mediaList.value.filter(m => m.category === activeFilter.value)
}

const toggleLike = (item: MediaItem) => {
  if (item.isLiked) {
    item.likes--
    item.isLiked = false
  } else {
    item.likes++
    item.isLiked = true
  }
}

const handleUpload = () => {
  if (!newTitle.value.trim()) return
  mediaList.value.unshift({
    id: `med-${Date.now()}`,
    title: newTitle.value.trim(),
    authorName: 'Jeffrey Suárez',
    authorAvatarBg: '#f0254c',
    category: newCategory.value,
    duration: newCategory.value === 'Clips' ? '01:30' : undefined,
    likes: 1,
    isLiked: true,
    commentsCount: 0,
    views: 1,
    timeAgo: 'Ahora',
    accentColor: '#f0254c',
    imageGradient: 'from-[#79141b] via-[#3a0b12] to-[#140508]',
    tagBadge: 'NUEVO',
  })
  newTitle.value = ''
  isUploadModalOpen.value = false
}
</script>

<template>
  <div class="flex-1 flex flex-col h-full overflow-hidden bg-black select-none">
    <!-- Top Filter Bar & Upload Button -->
    <div class="px-4 sm:px-6 py-3.5 border-b border-[#181923] bg-black/60 backdrop-blur-md flex items-center justify-between gap-3 shrink-0">
      <!-- Tag Filters -->
      <div class="flex items-center gap-1.5 overflow-x-auto no-scrollbar py-0.5">
        <button
          v-for="cat in filterCategories"
          :key="cat"
          type="button"
          @click="activeFilter = cat"
          class="px-3.5 py-1.5 rounded-full text-xs font-semibold whitespace-nowrap transition-all cursor-pointer"
          :class="[
            activeFilter === cat
              ? 'bg-[#f0254c] text-white shadow-sm shadow-[#f0254c]/30'
              : 'bg-[#14151f] hover:bg-[#1f212e] text-gray-400 hover:text-white border border-[#232535]'
          ]"
        >
          {{ cat }}
        </button>
      </div>

      <!-- Upload Button -->
      <button
        type="button"
        @click="isUploadModalOpen = true"
        class="px-3.5 py-1.5 rounded-full bg-[#181a26] hover:bg-[#222435] border border-[#2c2f44] text-xs font-semibold text-white flex items-center gap-1.5 shrink-0 transition-colors cursor-pointer"
        title="Compartir multimedia"
      >
        <Upload class="w-3.5 h-3.5 text-[#f0254c]" />
        <span>Subir</span>
      </button>
    </div>

    <!-- Media Grid Gallery -->
    <div class="flex-1 overflow-y-auto no-scrollbar p-4 sm:p-6 select-text">
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div
          v-for="item in filteredMedia()"
          :key="item.id"
          class="rounded-2xl bg-[#12131c] border border-[#20222f] hover:border-[#32364c] overflow-hidden flex flex-col transition-all duration-200 group hover:shadow-lg hover:shadow-black/60"
        >
          <!-- Media Thumbnail / Preview Area -->
          <div
            class="relative w-full aspect-video bg-gradient-to-br flex items-center justify-center overflow-hidden"
            :class="item.imageGradient"
          >
            <!-- Ambient Game Glow Pattern -->
            <div class="absolute inset-0 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-white/5 via-transparent to-black/60" />

            <!-- Category / Tag Badge -->
            <div class="absolute top-2.5 left-2.5 z-10 flex items-center gap-1.5">
              <span
                class="px-2.5 py-0.5 rounded-md text-[10px] font-bold tracking-wider uppercase text-white shadow-sm"
                :style="{ backgroundColor: item.accentColor }"
              >
                {{ item.tagBadge }}
              </span>
            </div>

            <!-- Video Duration or Clip Icon -->
            <div
              v-if="item.duration"
              class="absolute bottom-2.5 right-2.5 z-10 px-2 py-0.5 rounded-md bg-black/80 backdrop-blur-sm text-[11px] font-semibold text-white flex items-center gap-1"
            >
              <Film class="w-3 h-3 text-red-400" />
              <span>{{ item.duration }}</span>
            </div>

            <!-- Central Play Button for Video/Clip -->
            <div
              v-if="item.duration"
              class="w-12 h-12 rounded-full bg-black/60 backdrop-blur-md border border-white/20 flex items-center justify-center text-white group-hover:scale-110 group-hover:bg-[#f0254c] transition-all cursor-pointer shadow-xl z-10"
            >
              <Play class="w-5 h-5 ml-0.5 fill-current" />
            </div>

            <!-- Horror atmosphere icon for screenshots/art -->
            <div v-else class="text-white/20 group-hover:text-white/40 transition-colors">
              <Sparkles class="w-10 h-10" />
            </div>
          </div>

          <!-- Card Content -->
          <div class="p-3.5 flex flex-col justify-between flex-1 space-y-3">
            <div>
              <!-- Author Row -->
              <div class="flex items-center gap-2 mb-1.5 select-none">
                <div
                  class="w-6 h-6 rounded-full border border-white/10 flex items-center justify-center text-[10px] font-bold text-white shrink-0"
                  :style="{ backgroundColor: item.authorAvatarBg }"
                >
                  {{ item.authorName[0] }}
                </div>
                <span class="text-xs font-medium text-gray-300 truncate">
                  {{ item.authorName }}
                </span>
                <span class="text-gray-600 text-xs">·</span>
                <span class="text-[11px] text-gray-500 truncate">
                  {{ item.timeAgo }}
                </span>
              </div>

              <!-- Title -->
              <h4 class="text-sm font-semibold text-white leading-snug line-clamp-2 group-hover:text-red-200 transition-colors">
                {{ item.title }}
              </h4>
            </div>

            <!-- Stats & Actions Bar -->
            <div class="flex items-center justify-between pt-2 border-t border-[#1a1b26] text-xs text-gray-400 select-none">
              <div class="flex items-center gap-3">
                <!-- Like / Impulso button -->
                <button
                  type="button"
                  @click.stop="toggleLike(item)"
                  class="flex items-center gap-1 hover:text-red-400 transition-colors cursor-pointer"
                  :class="item.isLiked ? 'text-[#f0254c]' : 'text-gray-400'"
                >
                  <Heart
                    class="w-3.5 h-3.5 transition-transform active:scale-125"
                    :class="item.isLiked ? 'fill-current' : ''"
                  />
                  <span>{{ item.likes }}</span>
                </button>

                <!-- Comments count -->
                <div class="flex items-center gap-1 text-gray-500">
                  <MessageSquare class="w-3.5 h-3.5" />
                  <span>{{ item.commentsCount }}</span>
                </div>
              </div>

              <!-- Views count -->
              <div class="flex items-center gap-1 text-gray-500 text-[11px]">
                <Eye class="w-3.5 h-3.5" />
                <span>{{ item.views }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty state if filter has no items -->
      <div
        v-if="filteredMedia().length === 0"
        class="text-center py-16 text-gray-500 text-sm select-none"
      >
        No hay contenido multimedia en esta categoría.
      </div>
    </div>

    <!-- Simple Upload Modal -->
    <Teleport to="body">
      <Transition name="upload-modal-fade">
        <div
          v-if="isUploadModalOpen"
          class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm select-none"
          @click.self="isUploadModalOpen = false"
        >
          <div class="relative w-full max-w-md rounded-3xl border border-[#232535] bg-[#14151f] p-5 sm:p-6 shadow-2xl">
            <!-- Modal Header -->
            <div class="flex items-center justify-between pb-3 border-b border-[#20222f] mb-4">
              <h3 class="text-base font-bold text-white flex items-center gap-2">
                <Upload class="w-4 h-4 text-[#f0254c]" />
                <span>Compartir multimedia</span>
              </h3>
              <button
                type="button"
                @click="isUploadModalOpen = false"
                class="p-1 rounded-full text-gray-400 hover:text-white transition-colors cursor-pointer"
              >
                <X class="w-5 h-5" />
              </button>
            </div>

            <!-- Form -->
            <div class="space-y-4">
              <!-- Category selector -->
              <div>
                <label class="block text-xs font-semibold text-gray-300 mb-1.5">
                  Tipo de contenido
                </label>
                <div class="grid grid-cols-4 gap-2">
                  <button
                    v-for="cat in ['Clips', 'Capturas', 'Guías', 'Arte'] as const"
                    :key="cat"
                    type="button"
                    @click="newCategory = cat"
                    class="py-2 text-xs font-semibold rounded-xl border text-center transition-all cursor-pointer"
                    :class="[
                      newCategory === cat
                        ? 'bg-[#79141B] border-[#f0254c] text-white shadow-sm'
                        : 'bg-[#10111a] border-[#222433] text-gray-400 hover:text-white'
                    ]"
                  >
                    {{ cat }}
                  </button>
                </div>
              </div>

              <!-- Title / Caption input -->
              <div>
                <label class="block text-xs font-semibold text-gray-300 mb-1.5">
                  Título o descripción
                </label>
                <div class="bg-[#10111a] border border-[#222433] rounded-2xl p-3 focus-within:border-[#f0254c] transition-colors">
                  <textarea
                    v-model="newTitle"
                    maxlength="160"
                    rows="3"
                    placeholder="¿De qué trata este clip o captura?"
                    class="w-full bg-transparent text-sm text-gray-100 placeholder:text-gray-500 focus:outline-none resize-none"
                  />
                </div>
              </div>

              <!-- File upload mock area -->
              <div class="h-24 rounded-2xl border border-dashed border-[#2f3246] bg-[#10111a] flex flex-col items-center justify-center gap-1.5 text-gray-400 hover:border-[#f0254c]/60 transition-colors cursor-pointer">
                <Upload class="w-5 h-5 text-gray-500" />
                <span class="text-xs text-gray-400">Seleccionar video o imagen</span>
              </div>
            </div>

            <!-- Action buttons -->
            <div class="flex items-center gap-3 mt-6">
              <button
                type="button"
                @click="isUploadModalOpen = false"
                class="flex-1 py-2.5 rounded-xl border border-[#232535] bg-[#10111a] text-xs font-semibold text-gray-300 hover:text-white transition-colors cursor-pointer"
              >
                Cancelar
              </button>
              <button
                type="button"
                :disabled="!newTitle.trim()"
                @click="handleUpload"
                class="flex-1 py-2.5 rounded-xl bg-[#f0254c] hover:bg-[#d9193f] text-xs font-semibold text-white disabled:opacity-40 disabled:cursor-not-allowed shadow-md shadow-[#f0254c]/20 transition-all cursor-pointer"
              >
                Publicar
              </button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<style scoped>
.upload-modal-fade-enter-active,
.upload-modal-fade-leave-active {
  transition: opacity 180ms ease, transform 180ms cubic-bezier(0.23, 1, 0.32, 1);
}
.upload-modal-fade-enter-from,
.upload-modal-fade-leave-to {
  opacity: 0;
  transform: scale(0.97);
}
</style>
