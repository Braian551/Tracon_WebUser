<script setup lang="ts">
import { ref, computed } from 'vue'
import {
  ChevronLeft,
  Search,
  CircleSlash,
  Check,
  Flag,
  Gamepad2,
} from 'lucide-vue-next'
import RequestGameModal from '../communities/RequestGameModal.vue'
import { availableGamesCatalog } from '../../data/mockData'
import type { GameItem } from '../../types'

interface Props {
  initialSelectedGame?: string | null
  title?: string
  allowNone?: boolean
  noneLabel?: string
  buttonText?: string
  showHeader?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  initialSelectedGame: null,
  title: 'Seleccionar juegos',
  allowNone: true,
  noneLabel: 'Sin juego relacionado',
  buttonText: 'Continuar',
  showHeader: true,
})

const emit = defineEmits<{
  (e: 'cancel'): void
  (e: 'select', gameName: string | null): void
}>()

const isRequestModalOpen = ref(false)
const gameSearchQuery = ref('')
const tempSelectedGame = ref<string>(props.initialSelectedGame || (props.allowNone ? props.noneLabel : ''))

const availableGames = ref<GameItem[]>([...availableGamesCatalog])

const filteredGames = computed(() => {
  if (!gameSearchQuery.value.trim()) return availableGames.value
  const q = gameSearchQuery.value.toLowerCase().trim()
  return availableGames.value.filter(
    g => g.name.toLowerCase().includes(q) || g.genre.toLowerCase().includes(q)
  )
})

const handleGameSubmitted = (data: { name: string; website: string; reason: string }) => {
  if (data.name) {
    availableGames.value.unshift({
      id: `game-${Date.now()}`,
      name: data.name,
      genre: 'Comunitario',
    })
    tempSelectedGame.value = data.name
  }
}

const confirmGameSelection = () => {
  if (props.allowNone && tempSelectedGame.value === props.noneLabel) {
    emit('select', null)
  } else {
    emit('select', tempSelectedGame.value || null)
  }
}
</script>

<template>
  <div class="flex-1 min-w-0 bg-black flex flex-col h-full overflow-hidden select-none">
    <!-- Top Header: Optional self-contained header with Back button & centered Title -->
    <header
      v-if="showHeader"
      class="px-4 sm:px-6 pt-4 pb-3 flex items-center justify-between shrink-0 bg-black/95 backdrop-blur-md z-10 border-b border-[#1f212a]"
    >
      <button
        type="button"
        @click="emit('cancel')"
        class="p-2 -ml-2 rounded-full text-white hover:bg-white/10 active:scale-95 transition-all duration-150 cursor-pointer flex items-center justify-center"
        title="Volver"
      >
        <ChevronLeft class="w-6 h-6 stroke-[2.5]" />
      </button>

      <h2 class="text-lg sm:text-xl font-bold text-white tracking-tight text-center">
        {{ title }}
      </h2>

      <!-- Spacer for centering -->
      <div class="w-8" />
    </header>

    <!-- Main Game Selection View matching CreateCommunityView exactly -->
    <div class="flex-1 overflow-y-auto px-5 sm:px-7 py-4 flex flex-col justify-between no-scrollbar">
      <div class="space-y-4">
        <!-- Search bar matching exact screenshot -->
        <div class="bg-[#14151e] border border-[#222433] focus-within:border-[#f0254c] rounded-2xl px-4 py-3 flex items-center gap-3 transition-colors">
          <Search class="w-5 h-5 text-gray-400 shrink-0" />
          <input
            v-model="gameSearchQuery"
            type="text"
            placeholder="Buscar juego"
            class="w-full bg-transparent text-white placeholder-gray-500 text-sm focus:outline-none"
          />
        </div>

        <!-- Sin juego relacionado option matching screenshot (if allowNone) -->
        <div
          v-if="allowNone"
          @click="tempSelectedGame = noneLabel"
          class="flex items-center justify-between p-3 rounded-2xl hover:bg-white/[0.04] transition-colors cursor-pointer group"
          :class="tempSelectedGame === noneLabel || !tempSelectedGame ? 'bg-white/[0.03]' : ''"
        >
          <div class="flex items-center gap-3.5">
            <div class="w-10 h-10 rounded-full bg-[#70081a] border border-[#a8142b]/40 flex items-center justify-center shrink-0">
              <CircleSlash class="w-5 h-5 text-white stroke-[2.5]" />
            </div>
            <span class="text-sm font-semibold text-white">
              {{ noneLabel }}
            </span>
          </div>
          <div
            v-if="tempSelectedGame === noneLabel || !tempSelectedGame"
            class="w-5 h-5 rounded-full bg-[#f0254c] flex items-center justify-center"
          >
            <Check class="w-3.5 h-3.5 text-white stroke-[3]" />
          </div>
        </div>

        <!-- Action: Solicitar juego al catálogo -->
        <button
          type="button"
          @click="isRequestModalOpen = true"
          class="flex items-center gap-2.5 px-3 py-1 text-sm font-semibold text-[#f0254c] hover:text-[#ff3860] transition-colors cursor-pointer"
        >
          <Flag class="w-4 h-4 stroke-[2]" />
          <span>Solicitar juego al catálogo</span>
        </button>

        <!-- Games List matching search query -->
        <div v-if="filteredGames.length > 0" class="space-y-2 pt-1">
          <div
            v-for="game in filteredGames"
            :key="game.id"
            @click="tempSelectedGame = game.name"
            class="flex items-center justify-between p-3 rounded-2xl hover:bg-white/[0.04] transition-colors cursor-pointer group"
            :class="tempSelectedGame === game.name ? 'bg-white/[0.03]' : ''"
          >
            <div class="flex items-center gap-3.5 min-w-0">
              <div class="w-10 h-10 rounded-xl bg-[#202230] border border-[#2d3042] flex items-center justify-center text-gray-300 group-hover:text-white shrink-0">
                <Gamepad2 class="w-5 h-5" />
              </div>
              <div class="min-w-0">
                <h4 class="text-sm font-semibold text-white truncate">
                  {{ game.name }}
                </h4>
                <p class="text-xs text-gray-400 truncate">
                  {{ game.genre }}
                </p>
              </div>
            </div>
            <div
              v-if="tempSelectedGame === game.name"
              class="w-5 h-5 rounded-full bg-[#f0254c] flex items-center justify-center shrink-0"
            >
              <Check class="w-3.5 h-3.5 text-white stroke-[3]" />
            </div>
          </div>
        </div>

        <!-- Empty search state matching user screenshot -->
        <div v-else class="flex flex-col items-center justify-center py-20 text-center">
          <p class="text-sm text-gray-400">
            No encontramos ese juego.
          </p>
        </div>
      </div>

      <!-- Bottom button: Continuar (0) or Continuar (1) matching screenshot -->
      <div class="pt-6 pb-4">
        <button
          type="button"
          @click="confirmGameSelection"
          class="w-full py-3.5 px-6 rounded-2xl bg-[#f0254c] hover:bg-[#d9193f] active:scale-[0.99] text-white font-bold text-sm tracking-wide shadow-lg shadow-[#f0254c]/20 transition-all flex items-center justify-center cursor-pointer"
        >
          <span>{{ buttonText }} ({{ tempSelectedGame && tempSelectedGame !== noneLabel ? 1 : 0 }})</span>
        </button>
      </div>
    </div>

    <!-- Request Game Modal -->
    <RequestGameModal
      :is-open="isRequestModalOpen"
      @close="isRequestModalOpen = false"
      @submit="handleGameSubmitted"
    />
  </div>
</template>

<style scoped>
.no-scrollbar::-webkit-scrollbar {
  display: none;
}
.no-scrollbar {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
</style>

