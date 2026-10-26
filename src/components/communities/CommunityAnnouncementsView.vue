<script setup lang="ts">
import { ref } from 'vue'
import {
  Megaphone,
  Pin,
  Plus,
  X,
} from 'lucide-vue-next'

interface Props {
  communityName: string
}

defineProps<Props>()

interface AnnouncementItem {
  id: string
  title: string
  content: string
  authorName: string
  authorRole: string
  authorAvatarBg: string
  date: string
  isPinned?: boolean
  tagBadge?: string
  accentColor?: string
  reactions: { emoji: string; count: number; active?: boolean }[]
}

const isPublishModalOpen = ref(false)
const newTitle = ref('')
const newContent = ref('')
const newTag = ref('ACTUALIZACIÓN')

const announcementsList = ref<AnnouncementItem[]>([
  {
    id: 'ann-1',
    title: '🏆 Noche de torneo cooperativo: Escape Specimen Zero',
    content: 'Este fin de semana abriremos 4 salas competitivas simultáneas en dificultad Pesadilla. Los mejores equipos que logren escapar en menor tiempo recibirán una insignia exclusiva en la comunidad y mención destacada en el feed principal de Tracon.',
    authorName: 'Braian Andrés Oquendo Durango',
    authorRole: 'Creador de la comunidad',
    authorAvatarBg: '#232634',
    date: '25 OCT 2026 · 14:30',
    isPinned: true,
    tagBadge: 'EVENTO OFICIAL',
    accentColor: '#f0254c',
    reactions: [
      { emoji: '🔥', count: 42, active: true },
      { emoji: '💀', count: 28, active: false },
      { emoji: '🏆', count: 35, active: false },
      { emoji: '👏', count: 19, active: false },
    ],
  },
  {
    id: 'ann-2',
    title: '⚙️ Optimización de Servidores y Salas de Partida',
    content: 'Hemos desplegado una mejora en la sincronización de salas en vivo. Se redujo la latencia en un 35% para conexiones en Latinoamérica. Si detectas desincronización de monstruos o llaves, repórtalo en el canal de soporte.',
    authorName: 'Tracon Support',
    authorRole: 'Equipo de Soporte Oficial',
    authorAvatarBg: '#79141b',
    date: '22 OCT 2026 · 11:15',
    isPinned: false,
    tagBadge: 'MANTENIMIENTO',
    accentColor: '#38bdf8',
    reactions: [
      { emoji: '👍', count: 54, active: false },
      { emoji: '⚡', count: 21, active: false },
      { emoji: '❤️', count: 30, active: false },
    ],
  },
  {
    id: 'ann-3',
    title: '📜 Reglas de Convivencia y Prevención de Spoilers',
    content: 'Recordatorio para todos los miembros: los secretos de los nuevos cuartos secretos deben marcarse como spoilers. Mantengamos la intriga y la adrenalina intactas para quienes juegan por primera vez.',
    authorName: 'Braian Andrés',
    authorRole: 'Moderador',
    authorAvatarBg: '#232634',
    date: '18 OCT 2026 · 09:00',
    isPinned: false,
    tagBadge: 'NORMATIVA',
    accentColor: '#eab308',
    reactions: [
      { emoji: '🛡️', count: 37, active: false },
      { emoji: '👁️', count: 49, active: false },
    ],
  },
])

const toggleReaction = (announcement: AnnouncementItem, reactionIndex: number) => {
  const r = announcement.reactions[reactionIndex]
  if (r.active) {
    r.count--
    r.active = false
  } else {
    r.count++
    r.active = true
  }
}

const handlePublish = () => {
  if (!newTitle.value.trim() || !newContent.value.trim()) return
  announcementsList.value.unshift({
    id: `ann-${Date.now()}`,
    title: newTitle.value.trim(),
    content: newContent.value.trim(),
    authorName: 'Jeffrey Suárez',
    authorRole: 'Admin',
    authorAvatarBg: '#f0254c',
    date: 'Hoy · Ahora mismo',
    isPinned: false,
    tagBadge: newTag.value,
    accentColor: '#f0254c',
    reactions: [
      { emoji: '🔥', count: 1, active: true },
      { emoji: '👍', count: 0, active: false },
    ],
  })
  newTitle.value = ''
  newContent.value = ''
  isPublishModalOpen.value = false
}
</script>

<template>
  <div class="flex-1 flex flex-col h-full overflow-hidden bg-black select-none">
    <!-- Top Action / Info Banner -->
    <div class="px-4 sm:px-6 py-3.5 border-b border-[#181923] bg-black/60 backdrop-blur-md flex items-center justify-between gap-3 shrink-0">
      <div class="flex items-center gap-2 text-xs text-gray-400">
        <Megaphone class="w-4 h-4 text-[#f0254c]" />
        <span>Canal oficial de avisos y novedades de {{ communityName }}</span>
      </div>

      <!-- Publish Announcement Button -->
      <button
        type="button"
        @click="isPublishModalOpen = true"
        class="px-3.5 py-1.5 rounded-full bg-[#181a26] hover:bg-[#222435] border border-[#2c2f44] text-xs font-semibold text-white flex items-center gap-1.5 shrink-0 transition-colors cursor-pointer"
        title="Publicar anuncio"
      >
        <Plus class="w-3.5 h-3.5 text-[#f0254c]" />
        <span>Publicar</span>
      </button>
    </div>

    <!-- Announcements Feed -->
    <div class="flex-1 overflow-y-auto no-scrollbar p-4 sm:p-6 space-y-4 select-text">
      <div
        v-for="item in announcementsList"
        :key="item.id"
        class="rounded-2xl bg-[#12131c] border border-[#20222f] hover:border-[#2f334a] p-4 sm:p-5 transition-all shadow-md relative overflow-hidden"
      >
        <!-- Accent Top Line -->
        <div
          v-if="item.isPinned"
          class="absolute top-0 inset-x-0 h-[2px] bg-gradient-to-r from-transparent via-[#f0254c] to-transparent"
        />

        <!-- Top Pinned / Tag row -->
        <div class="flex items-center justify-between gap-2 mb-3 select-none">
          <div class="flex items-center gap-2">
            <!-- Pinned Pill -->
            <span
              v-if="item.isPinned"
              class="px-2.5 py-0.5 rounded-full text-[11px] font-bold tracking-wide bg-[#79141B]/50 border border-[#f0254c]/40 text-red-200 flex items-center gap-1"
            >
              <Pin class="w-3 h-3 text-[#f0254c]" />
              <span>FIJADO</span>
            </span>

            <!-- Category tag -->
            <span
              v-if="item.tagBadge"
              class="px-2.5 py-0.5 rounded-md text-[10px] font-bold tracking-wider text-gray-300 uppercase bg-[#181a26] border border-[#262838]"
            >
              {{ item.tagBadge }}
            </span>
          </div>

          <span class="text-[11px] text-gray-500 font-medium">
            {{ item.date }}
          </span>
        </div>

        <!-- Author Header -->
        <div class="flex items-center gap-2.5 mb-3 select-none">
          <div
            class="w-9 h-9 rounded-full border border-white/10 flex items-center justify-center text-xs font-bold text-white shrink-0"
            :style="{ backgroundColor: item.authorAvatarBg }"
          >
            {{ item.authorName[0] }}
          </div>

          <div class="min-w-0 flex-1">
            <h5 class="text-[13px] font-semibold text-white truncate flex items-center gap-1.5">
              <span>{{ item.authorName }}</span>
              <span class="w-1.5 h-1.5 rounded-full bg-[#f0254c]" />
            </h5>
            <p class="text-[11px] text-gray-400 truncate">
              {{ item.authorRole }}
            </p>
          </div>
        </div>

        <!-- Title & Content -->
        <div class="space-y-2 mb-4">
          <h4 class="text-base sm:text-lg font-bold text-white tracking-tight leading-snug">
            {{ item.title }}
          </h4>
          <p class="text-sm text-gray-200 leading-relaxed break-words whitespace-pre-line">
            {{ item.content }}
          </p>
        </div>

        <!-- Interactive Reactions Bar -->
        <div class="flex items-center gap-2 pt-3 border-t border-[#1a1b26] select-none overflow-x-auto no-scrollbar">
          <button
            v-for="(reaction, idx) in item.reactions"
            :key="idx"
            type="button"
            @click="toggleReaction(item, idx)"
            class="px-3 py-1.5 rounded-xl border text-xs font-semibold flex items-center gap-1.5 transition-all cursor-pointer active:scale-95"
            :class="[
              reaction.active
                ? 'bg-[#79141B]/40 border-[#f0254c]/70 text-white shadow-sm'
                : 'bg-[#151622] border-[#222433] text-gray-300 hover:bg-[#1b1c2b] hover:text-white'
            ]"
          >
            <span>{{ reaction.emoji }}</span>
            <span>{{ reaction.count }}</span>
          </button>
        </div>
      </div>
    </div>

    <!-- Publish Announcement Modal -->
    <Teleport to="body">
      <Transition name="announcement-modal-fade">
        <div
          v-if="isPublishModalOpen"
          class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm select-none"
          @click.self="isPublishModalOpen = false"
        >
          <div class="relative w-full max-w-md rounded-3xl border border-[#232535] bg-[#14151f] p-5 sm:p-6 shadow-2xl">
            <!-- Modal Header -->
            <div class="flex items-center justify-between pb-3 border-b border-[#20222f] mb-4">
              <h3 class="text-base font-bold text-white flex items-center gap-2">
                <Megaphone class="w-4 h-4 text-[#f0254c]" />
                <span>Publicar anuncio</span>
              </h3>
              <button
                type="button"
                @click="isPublishModalOpen = false"
                class="p-1 rounded-full text-gray-400 hover:text-white transition-colors cursor-pointer"
              >
                <X class="w-5 h-5" />
              </button>
            </div>

            <!-- Form -->
            <div class="space-y-4">
              <!-- Tag selector -->
              <div>
                <label class="block text-xs font-semibold text-gray-300 mb-1.5">
                  Etiqueta
                </label>
                <div class="grid grid-cols-3 gap-2">
                  <button
                    v-for="tag in ['EVENTO', 'ACTUALIZACIÓN', 'NORMATIVA'] as const"
                    :key="tag"
                    type="button"
                    @click="newTag = tag"
                    class="py-2 text-xs font-semibold rounded-xl border text-center transition-all cursor-pointer"
                    :class="[
                      newTag === tag
                        ? 'bg-[#79141B] border-[#f0254c] text-white shadow-sm'
                        : 'bg-[#10111a] border-[#222433] text-gray-400 hover:text-white'
                    ]"
                  >
                    {{ tag }}
                  </button>
                </div>
              </div>

              <!-- Title -->
              <div>
                <label class="block text-xs font-semibold text-gray-300 mb-1.5">
                  Título del anuncio
                </label>
                <div class="bg-[#10111a] border border-[#222433] rounded-2xl p-3 focus-within:border-[#f0254c] transition-colors">
                  <input
                    v-model="newTitle"
                    maxlength="120"
                    type="text"
                    placeholder="Ej. Nueva fecha para el torneo..."
                    class="w-full bg-transparent text-sm text-gray-100 placeholder:text-gray-500 focus:outline-none"
                  />
                </div>
              </div>

              <!-- Content -->
              <div>
                <label class="block text-xs font-semibold text-gray-300 mb-1.5">
                  Contenido
                </label>
                <div class="bg-[#10111a] border border-[#222433] rounded-2xl p-3 focus-within:border-[#f0254c] transition-colors">
                  <textarea
                    v-model="newContent"
                    maxlength="1500"
                    rows="4"
                    placeholder="Escribe el comunicado para la comunidad..."
                    class="w-full bg-transparent text-sm text-gray-100 placeholder:text-gray-500 focus:outline-none resize-none leading-relaxed"
                  />
                </div>
              </div>
            </div>

            <!-- Action buttons -->
            <div class="flex items-center gap-3 mt-6">
              <button
                type="button"
                @click="isPublishModalOpen = false"
                class="flex-1 py-2.5 rounded-xl border border-[#232535] bg-[#10111a] text-xs font-semibold text-gray-300 hover:text-white transition-colors cursor-pointer"
              >
                Cancelar
              </button>
              <button
                type="button"
                :disabled="!newTitle.trim() || !newContent.trim()"
                @click="handlePublish"
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
.announcement-modal-fade-enter-active,
.announcement-modal-fade-leave-active {
  transition: opacity 180ms ease, transform 180ms cubic-bezier(0.23, 1, 0.32, 1);
}
.announcement-modal-fade-enter-from,
.announcement-modal-fade-leave-to {
  opacity: 0;
  transform: scale(0.97);
}
</style>
