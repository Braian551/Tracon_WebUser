<script setup lang="ts">
import { ref } from 'vue'
import {
  ChevronLeft,
  ArrowRight,
  Check,
  Camera,
  Users,
  ShieldCheck,
  Gamepad2,
  ChevronRight,
  ChevronDown,
  Globe,
  ImageIcon,
  Hash,
  PlusSquare,
} from 'lucide-vue-next'
import type { CommunityFeedItem } from '../../types'
import GameSelectorView from '../common/GameSelectorView.vue'
import RequestGameModal from './RequestGameModal.vue'

const emit = defineEmits<{
  (e: 'back'): void
  (e: 'community-created', item: CommunityFeedItem): void
}>()

// Step state: 1 to 4
const currentStep = ref<1 | 2 | 3 | 4>(1)
const isSelectingGame = ref(false)
const isRequestModalOpen = ref(false)

const openGameSelector = () => {
  isSelectingGame.value = true
}

const handleGameSelected = (game: string | null) => {
  form.value.game = game || ''
  isSelectingGame.value = false
}

const handleGameSubmitted = (data: { name: string; website: string; reason: string }) => {
  if (data.name) {
    form.value.game = data.name
  }
}

// Form fields
const form = ref({
  name: '',
  handle: '',
  shortDescription: '',
  fullDescription: '',
  tags: '',
  language: 'Español',
  region: 'General',
  type: 'standard' as 'standard' | 'official',
  game: '',
  rules: '',
  website: '',
  explanation: '',
})

// Navigation between steps
const handleBack = () => {
  if (isSelectingGame.value) {
    isSelectingGame.value = false
    return
  }
  if (currentStep.value > 1) {
    currentStep.value = (currentStep.value - 1) as 1 | 2 | 3 | 4
  } else {
    emit('back')
  }
}

const handleContinue = () => {
  if (currentStep.value < 4) {
    currentStep.value = (currentStep.value + 1) as 1 | 2 | 3 | 4
  } else {
    submitCommunity()
  }
}

const submitCommunity = () => {
  const newCommunity: CommunityFeedItem = {
    id: `comm-${Date.now()}`,
    name: form.value.name.trim() || 'Nueva Comunidad',
    gameSubtitle: form.value.game.trim() || 'Juego comunitario',
    description: form.value.shortDescription.trim() || 'Comunidad creada en Tracon',
    membersCount: '1 miembro',
    isVerified: form.value.type === 'official',
    avatarBg: form.value.type === 'official' ? '#3d0c14' : '#70081a',
  }
  emit('community-created', newCommunity)
}

// Clean handle formatting
const formatHandle = () => {
  let val = form.value.handle.toLowerCase().replace(/[^a-z0-9_]/g, '')
  form.value.handle = val
}
</script>

<template>
  <div
    class="flex-1 min-w-0 rounded-2xl lg:rounded-3xl border border-[#1f212a] bg-black overflow-hidden flex flex-col h-[calc(100vh-2rem)] lg:h-[calc(100vh-2.5rem)] sticky top-4 lg:top-5 shadow-lg select-none"
  >
    <!-- Top Header: Back Button + Centered Title -->
    <div
      class="px-4 sm:px-6 pt-4 pb-3 flex items-center justify-between shrink-0 bg-black/95 backdrop-blur-md z-10"
    >
      <button
        type="button"
        @click="handleBack"
        class="p-2 -ml-2 rounded-full text-white hover:bg-white/10 active:scale-95 transition-all duration-150 cursor-pointer flex items-center justify-center"
        title="Volver"
      >
        <ChevronLeft class="w-6 h-6 stroke-[2.5]" />
      </button>

      <h2 class="text-lg sm:text-xl font-bold text-white tracking-tight text-center">
        {{ isSelectingGame ? 'Seleccionar juegos' : 'Crear comunidad' }}
      </h2>

      <!-- Spacer for centering -->
      <div class="w-8" />
    </div>

    <!-- Step Progress Indicator: 4 Segments matching Screenshots (smooth fade when selecting game) -->
    <Transition name="progress-fade">
      <div v-if="!isSelectingGame" class="px-5 sm:px-7 pb-4 flex items-center gap-2 shrink-0">
        <div
          v-for="step in [1, 2, 3, 4]"
          :key="step"
          class="flex-1 h-1 rounded-full transition-all duration-300"
          :class="step <= currentStep ? 'bg-[#f0254c]' : 'bg-[#262836]'"
        />
      </div>
    </Transition>

    <!-- Main Content Area: Relative overflow-hidden container with smooth sliding transition -->
    <div class="flex-1 relative overflow-hidden min-h-0">
      <Transition name="step-slide">
        <!-- ================= REUSABLE GAME SELECTION VIEW ================= -->
        <GameSelectorView
          v-if="isSelectingGame"
          key="game-selector-view"
          :initial-selected-game="form.game || 'Sin juego relacionado'"
          :show-header="false"
          @cancel="isSelectingGame = false"
          @select="handleGameSelected"
        />

        <!-- Scrollable Form Body (when NOT selecting game) -->
        <div
          v-else
          key="steps-wizard-view"
          class="absolute inset-0 overflow-y-auto px-5 sm:px-7 py-2 space-y-6 custom-scrollbar"
        >
      <!-- ================= STEP 1: IDENTIDAD ================= -->
      <template v-if="currentStep === 1">
        <div>
          <h3 class="text-2xl font-bold text-white tracking-tight">
            Identidad
          </h3>
          <p class="text-sm text-gray-400 mt-1">
            Dale a tu comunidad una presencia clara y reconocible.
          </p>
        </div>

        <!-- Cover & Avatar section -->
        <div class="space-y-0 pt-1">
          <!-- Cover container -->
          <div
            class="w-full h-32 rounded-2xl bg-[#171822] border border-[#232536] hover:border-white/20 transition-colors flex items-center justify-center cursor-pointer group"
          >
            <span class="text-sm font-medium text-gray-300 group-hover:text-white transition-colors">
              Añadir portada
            </span>
          </div>

          <!-- Overlapping Avatar -->
          <div class="relative -mt-8 ml-4 z-10 w-fit">
            <div
              class="w-16 h-16 rounded-full bg-[#70081a] border-4 border-black flex items-center justify-center shadow-xl cursor-pointer hover:scale-105 active:scale-95 transition-transform"
              title="Añadir foto de comunidad"
            >
              <Camera class="w-6 h-6 text-white" />
            </div>
          </div>
        </div>

        <!-- Form Inputs -->
        <div class="space-y-4 pt-1">
          <!-- 1. Nombre -->
          <div class="relative">
            <div class="bg-[#14151e] border border-[#222433] rounded-2xl px-4 py-3 focus-within:border-[#f0254c] transition-colors">
              <input
                v-model="form.name"
                type="text"
                maxlength="120"
                placeholder="Nombre"
                class="w-full bg-transparent text-white placeholder-gray-500 text-sm focus:outline-none"
              />
            </div>
            <div class="flex justify-end px-2 pt-1 text-[11px] text-gray-500">
              {{ form.name.length }}/120
            </div>
          </div>

          <!-- 2. Identificador público -->
          <div class="relative">
            <div class="bg-[#14151e] border border-[#222433] rounded-2xl px-4 py-3 focus-within:border-[#f0254c] transition-colors">
              <div class="flex items-center gap-1">
                <span class="text-gray-500 text-sm">@</span>
                <input
                  v-model="form.handle"
                  @input="formatHandle"
                  type="text"
                  maxlength="120"
                  placeholder="Identificador público"
                  class="w-full bg-transparent text-white placeholder-gray-500 text-sm focus:outline-none"
                />
              </div>
            </div>
            <div class="flex items-center justify-between px-2 pt-1 text-[11px] text-gray-500">
              <span>Así encontrarán tu comunidad en Tracon.</span>
              <span>{{ form.handle.length }}/120</span>
            </div>
          </div>

          <!-- 3. Descripción breve -->
          <div class="relative">
            <div class="bg-[#14151e] border border-[#222433] rounded-2xl px-4 py-3 focus-within:border-[#f0254c] transition-colors">
              <input
                v-model="form.shortDescription"
                type="text"
                maxlength="240"
                placeholder="Descripción breve"
                class="w-full bg-transparent text-white placeholder-gray-500 text-sm focus:outline-none"
              />
            </div>
            <div class="flex justify-end px-2 pt-1 text-[11px] text-gray-500">
              {{ form.shortDescription.length }}/240
            </div>
          </div>

          <!-- 4. Descripción completa -->
          <div class="relative">
            <div class="bg-[#14151e] border border-[#222433] rounded-2xl px-4 py-3 focus-within:border-[#f0254c] transition-colors">
              <textarea
                v-model="form.fullDescription"
                rows="4"
                maxlength="2000"
                placeholder="Descripción completa"
                class="w-full bg-transparent text-white placeholder-gray-500 text-sm focus:outline-none resize-none"
              />
            </div>
            <div class="flex justify-end px-2 pt-1 text-[11px] text-gray-500">
              {{ form.fullDescription.length }}/2000
            </div>
          </div>
        </div>
      </template>

      <!-- ================= STEP 2: TEMA Y DESCUBRIMIENTO ================= -->
      <template v-else-if="currentStep === 2">
        <div>
          <h3 class="text-2xl font-bold text-white tracking-tight">
            Tema y descubrimiento
          </h3>
          <p class="text-sm text-gray-400 mt-1">
            Ayuda a las personas correctas a encontrar tu comunidad.
          </p>
        </div>

        <div class="space-y-4 pt-2">
          <!-- 1. Etiquetas -->
          <div class="relative">
            <div class="bg-[#14151e] border border-[#222433] rounded-2xl px-4 pt-2.5 pb-3 focus-within:border-[#f0254c] transition-colors">
              <label class="block text-[11px] font-semibold text-gray-400 mb-1">
                Etiquetas
              </label>
              <input
                v-model="form.tags"
                type="text"
                placeholder="terror, survival"
                class="w-full bg-transparent text-white placeholder-gray-600 text-sm focus:outline-none"
              />
            </div>
            <p class="px-2 pt-1 text-[11px] text-gray-500">
              Máximo 8 · separa con coma o Enter
            </p>
          </div>

          <!-- 2. Idioma -->
          <div class="relative bg-[#14151e] border border-[#222433] hover:border-[#2f3246] focus-within:border-[#f0254c] rounded-2xl px-4 py-3 transition-colors">
            <label class="block text-[11px] font-semibold text-gray-400 mb-1">
              Idioma
            </label>
            <div class="relative flex items-center">
              <select
                v-model="form.language"
                class="w-full bg-transparent text-white text-sm font-medium focus:outline-none cursor-pointer appearance-none pr-8 border-none ring-0 outline-none"
              >
                <option value="Español" class="bg-[#14151e] text-white py-1">Español</option>
                <option value="Inglés" class="bg-[#14151e] text-white py-1">Inglés</option>
                <option value="Portugués" class="bg-[#14151e] text-white py-1">Portugués</option>
              </select>
              <ChevronDown class="w-4 h-4 text-gray-400 absolute right-0 pointer-events-none" />
            </div>
          </div>

          <!-- 3. Región -->
          <div class="relative bg-[#14151e] border border-[#222433] hover:border-[#2f3246] focus-within:border-[#f0254c] rounded-2xl px-4 py-3 transition-colors">
            <label class="block text-[11px] font-semibold text-gray-400 mb-1">
              Región
            </label>
            <div class="relative flex items-center">
              <Globe class="w-4 h-4 text-gray-400 shrink-0 mr-2.5 pointer-events-none" />
              <select
                v-model="form.region"
                class="w-full bg-transparent text-white text-sm font-medium focus:outline-none cursor-pointer appearance-none pr-8 border-none ring-0 outline-none"
              >
                <option value="General" class="bg-[#14151e] text-white py-1">General</option>
                <option value="Argentina" class="bg-[#14151e] text-white py-1">Argentina</option>
                <option value="Colombia" class="bg-[#14151e] text-white py-1">Colombia</option>
                <option value="México" class="bg-[#14151e] text-white py-1">México</option>
                <option value="España" class="bg-[#14151e] text-white py-1">España</option>
                <option value="Chile" class="bg-[#14151e] text-white py-1">Chile</option>
              </select>
              <ChevronDown class="w-4 h-4 text-gray-400 absolute right-0 pointer-events-none" />
            </div>
          </div>
        </div>
      </template>

      <!-- ================= STEP 3: TIPO DE COMUNIDAD ================= -->
      <template v-else-if="currentStep === 3">
        <div>
          <h3 class="text-2xl font-bold text-white tracking-tight">
            Tipo de comunidad
          </h3>
          <p class="text-sm text-gray-400 mt-1">
            Elige cómo quieres presentar y proteger este espacio.
          </p>
        </div>

        <!-- Type Selector: Estándar vs Oficial -->
        <div class="flex items-center justify-around border-b border-[#222433] pt-2 pb-1">
          <!-- Estándar tab -->
          <button
            type="button"
            @click="form.type = 'standard'"
            class="flex items-center gap-2 pb-2.5 text-sm font-semibold transition-all relative cursor-pointer"
            :class="form.type === 'standard' ? 'text-[#f0254c]' : 'text-gray-400 hover:text-white'"
          >
            <Users class="w-4 h-4" />
            <span>Estándar</span>
            <div
              v-if="form.type === 'standard'"
              class="absolute bottom-0 inset-x-0 h-0.5 bg-[#f0254c] rounded-full"
            />
          </button>

          <!-- Oficial tab -->
          <button
            type="button"
            @click="form.type = 'official'"
            class="flex items-center gap-2 pb-2.5 text-sm font-semibold transition-all relative cursor-pointer"
            :class="form.type === 'official' ? 'text-[#f0254c]' : 'text-gray-400 hover:text-white'"
          >
            <ShieldCheck class="w-4 h-4" />
            <span>Oficial</span>
            <div
              v-if="form.type === 'official'"
              class="absolute bottom-0 inset-x-0 h-0.5 bg-[#f0254c] rounded-full"
            />
          </button>
        </div>

        <!-- Select Game Box -->
        <div
          @click="openGameSelector"
          class="bg-[#14151e] border border-[#222433] rounded-2xl p-3.5 flex items-center justify-between hover:border-white/20 transition-colors cursor-pointer group"
        >
          <div class="flex items-center gap-3">
            <div
              class="w-10 h-10 rounded-xl flex items-center justify-center transition-colors"
              :class="form.game ? 'bg-[#70081a] text-white' : 'bg-[#202230] text-gray-300 group-hover:text-white'"
            >
              <Gamepad2 class="w-5 h-5" />
            </div>
            <div>
              <h4 class="text-sm font-semibold text-white">
                {{ form.game || 'Seleccionar juegos' }}
              </h4>
              <p class="text-xs text-gray-400">
                {{ form.game ? 'Juego vinculado a la comunidad' : 'Opcional para cualquier comunidad' }}
              </p>
            </div>
          </div>
          <ChevronRight class="w-5 h-5 text-gray-500 group-hover:text-white transition-colors" />
        </div>

        <!-- Action button: Incorporar juego al catálogo -->
        <button
          type="button"
          @click="isRequestModalOpen = true"
          class="flex items-center gap-2 text-xs font-semibold text-[#f0254c] hover:text-[#ff3860] transition-colors cursor-pointer"
        >
          <PlusSquare class="w-4 h-4 stroke-[2]" />
          <span>Incorporar juego al catálogo</span>
        </button>

        <!-- Explanatory note -->
        <p class="text-xs text-gray-400 leading-relaxed">
          <template v-if="form.type === 'standard'">
            Las comunidades estándar se publican inmediatamente al crearlas. Vincular un juego es opcional.
          </template>
          <template v-else>
            Las comunidades oficiales se revisan y permanecen privadas hasta ser aprobadas. Vincular un juego es opcional.
          </template>
        </p>

        <!-- Conditional Fields for Oficial -->
        <div v-if="form.type === 'official'" class="space-y-4">
          <!-- Sitio web -->
          <div class="bg-[#14151e] border border-[#222433] rounded-2xl px-4 py-3 focus-within:border-[#f0254c] transition-colors">
            <input
              v-model="form.website"
              type="url"
              placeholder="Sitio web (opcional)"
              class="w-full bg-transparent text-white placeholder-gray-500 text-sm focus:outline-none"
            />
          </div>

          <!-- Explicación -->
          <div class="relative">
            <div class="bg-[#14151e] border border-[#222433] rounded-2xl px-4 py-3 focus-within:border-[#f0254c] transition-colors">
              <textarea
                v-model="form.explanation"
                rows="3"
                maxlength="3000"
                placeholder="Explicación"
                class="w-full bg-transparent text-white placeholder-gray-500 text-sm focus:outline-none resize-none"
              />
            </div>
            <div class="flex justify-end px-2 pt-1 text-[11px] text-gray-500">
              {{ form.explanation.length }}/3000
            </div>
          </div>
        </div>

        <!-- Reglas Field (both standard and official) -->
        <div class="relative">
          <div class="bg-[#14151e] border border-[#222433] rounded-2xl px-4 py-3 focus-within:border-[#f0254c] transition-colors">
            <textarea
              v-model="form.rules"
              rows="4"
              maxlength="3000"
              placeholder="Reglas"
              class="w-full bg-transparent text-white placeholder-gray-500 text-sm focus:outline-none resize-none"
            />
          </div>
          <div class="flex justify-end px-2 pt-1 text-[11px] text-gray-500">
            {{ form.rules.length }}/3000
          </div>
        </div>
      </template>

      <!-- ================= STEP 4: REVISAR ================= -->
      <template v-else-if="currentStep === 4">
        <div>
          <h3 class="text-2xl font-bold text-white tracking-tight">
            Revisar
          </h3>
          <p class="text-sm text-gray-400 mt-1">
            Confirma los datos antes de enviar tu comunidad.
          </p>
        </div>

        <!-- Preview Card section -->
        <div class="space-y-2">
          <h4 class="text-xs font-bold uppercase tracking-wider text-gray-400">
            Vista previa
          </h4>

          <div class="rounded-2xl bg-[#14151e] border border-[#222433] overflow-hidden shadow-md">
            <!-- Cover preview banner -->
            <div class="h-24 bg-gradient-to-r from-[#201d2a] to-[#161722] flex items-center justify-center text-gray-500">
              <ImageIcon class="w-6 h-6 opacity-40" />
            </div>

            <!-- Header info with overlapping avatar -->
            <div class="px-4 pb-4 pt-1">
              <div class="flex items-end gap-3 -mt-7 mb-2">
                <div class="w-14 h-14 rounded-full bg-[#70081a] border-4 border-black flex items-center justify-center shrink-0 shadow-lg">
                  <Users class="w-6 h-6 text-white" />
                </div>
                <div class="pb-1 min-w-0">
                  <h4 class="text-base font-bold text-white truncate">
                    {{ form.name || 'Sin nombre' }}
                  </h4>
                  <p class="text-xs font-semibold text-[#f0254c] truncate">
                    @{{ form.handle || 'identificador' }}
                  </p>
                </div>
              </div>

              <!-- Region & Description -->
              <div class="space-y-1 text-xs text-gray-300">
                <p class="flex items-center gap-1.5 text-gray-400">
                  <span>🌐</span>
                  <span>{{ form.region }}</span>
                </p>
                <p v-if="form.shortDescription" class="text-gray-300 text-xs">
                  {{ form.shortDescription }}
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Key-Value Summary List -->
        <div class="space-y-2.5 text-sm pt-2">
          <div class="flex justify-between py-1 border-b border-white/5">
            <span class="text-gray-400 font-medium">Nombre</span>
            <span class="text-white font-semibold text-right">{{ form.name || 'Sin nombre' }}</span>
          </div>
          <div class="flex justify-between py-1 border-b border-white/5">
            <span class="text-gray-400 font-medium">Identificador</span>
            <span class="text-white font-semibold text-right">@{{ form.handle || 'identificador' }}</span>
          </div>
          <div class="flex justify-between py-1 border-b border-white/5">
            <span class="text-gray-400 font-medium">Descripción</span>
            <span class="text-white font-semibold text-right truncate max-w-[200px]">{{ form.shortDescription || 'Sin descripción' }}</span>
          </div>
          <div class="flex justify-between py-1 border-b border-white/5">
            <span class="text-gray-400 font-medium">Juego</span>
            <span class="text-white font-semibold text-right">{{ form.game || 'Sin juego relacionado' }}</span>
          </div>
          <div class="flex justify-between py-1 border-b border-white/5">
            <span class="text-gray-400 font-medium">Región</span>
            <span class="text-white font-semibold text-right">{{ form.region }}</span>
          </div>
          <div class="flex justify-between py-1 border-b border-white/5">
            <span class="text-gray-400 font-medium">Etiquetas</span>
            <span class="text-white font-semibold text-right truncate max-w-[200px]">{{ form.tags || 'Sin etiquetas' }}</span>
          </div>
          <div class="flex justify-between py-1 border-b border-white/5">
            <span class="text-gray-400 font-medium">Tipo</span>
            <span class="text-white font-semibold text-right">
              {{ form.type === 'standard' ? 'Estándar · pública al crear' : 'Oficial · requiere aprobación' }}
            </span>
          </div>
        </div>

        <!-- Initial Channels -->
        <div class="pt-2">
          <h4 class="text-xs font-bold uppercase tracking-wider text-gray-400 mb-2">
            Canales iniciales
          </h4>
          <div class="flex items-center gap-3 p-3 rounded-xl bg-[#14151e] border border-[#222433]">
            <Hash class="w-5 h-5 text-gray-400" />
            <div>
              <p class="text-sm font-semibold text-white">General</p>
              <p class="text-xs text-gray-400">Todos los miembros</p>
            </div>
          </div>
        </div>
      </template>

      <!-- Bottom Action Button (Steps 1 to 4) -->
      <div class="pt-4 pb-6">
        <button
          type="button"
          @click="handleContinue"
          class="w-full py-3.5 px-6 rounded-2xl bg-[#f0254c] hover:bg-[#d9193f] active:scale-[0.99] text-white font-bold text-sm tracking-wide shadow-lg shadow-[#f0254c]/20 transition-all flex items-center justify-center gap-2 cursor-pointer"
        >
          <template v-if="currentStep < 4">
            <ArrowRight class="w-4 h-4" />
            <span>Continuar</span>
          </template>
          <template v-else>
            <Check class="w-4 h-4 stroke-[3]" />
            <span>Crear comunidad</span>
          </template>
        </button>
      </div>
    </div>
  </Transition>
</div>
</div>

  <!-- Request Game Modal for step 2 -->
  <RequestGameModal
    :is-open="isRequestModalOpen"
    @close="isRequestModalOpen = false"
    @submit="handleGameSubmitted"
  />
</template>

<style scoped>
.step-slide-enter-active,
.step-slide-leave-active {
  transition: opacity 250ms cubic-bezier(0.23, 1, 0.32, 1), transform 250ms cubic-bezier(0.23, 1, 0.32, 1);
  will-change: opacity, transform;
}

.step-slide-leave-active {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 0;
}

.step-slide-enter-active {
  z-index: 10;
}

.step-slide-enter-from {
  opacity: 0;
  transform: translateY(12px) scale(0.995);
}

.step-slide-leave-to {
  opacity: 0;
  transform: translateY(-10px) scale(0.995);
}

.progress-fade-enter-active,
.progress-fade-leave-active {
  transition: opacity 180ms cubic-bezier(0.23, 1, 0.32, 1), transform 180ms cubic-bezier(0.23, 1, 0.32, 1);
}

.progress-fade-enter-from,
.progress-fade-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}

@media (prefers-reduced-motion: reduce) {
  .step-slide-enter-active,
  .step-slide-leave-active,
  .progress-fade-enter-active,
  .progress-fade-leave-active {
    transition: opacity 120ms ease;
    transform: none;
  }
}

.custom-scrollbar::-webkit-scrollbar {
  width: 5px;
}
.custom-scrollbar::-webkit-scrollbar-track {
  background: transparent;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.12);
  border-radius: 9999px;
}
.custom-scrollbar::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.22);
}
</style>
