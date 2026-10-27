<script setup lang="ts">
import { ref, computed, nextTick } from 'vue'
import {
  X,
  Hash,
  AtSign,
  SquareCheck,
  List,
  Camera,
  ImageIcon,
  Trash2,
  Plus,
  Info,
} from 'lucide-vue-next'
import type { PollData } from '../../types'

interface Props {
  initialPoll?: PollData | null
}

const props = defineProps<Props>()

const emit = defineEmits<{
  (e: 'cancel'): void
  (e: 'save', poll: PollData): void
}>()

// State
const question = ref(props.initialPoll?.question || '')
const questionTextareaRef = ref<HTMLTextAreaElement | null>(null)
const responseType = ref<'texto' | 'imagen'>(
  props.initialPoll?.responseType ||
  (props.initialPoll?.options.some(o => !!o.imageUrl) ? 'imagen' : 'texto')
)

interface OptionItem {
  id: string
  text: string
  imageUrl?: string
}

const options = ref<OptionItem[]>(
  props.initialPoll?.options && props.initialPoll.options.length >= 2
    ? props.initialPoll.options.map((opt, idx) => ({
        id: `opt-${idx + 1}`,
        text: opt.text,
        imageUrl: opt.imageUrl,
      }))
    : [
        { id: 'opt-1', text: '' },
        { id: 'opt-2', text: '' },
      ]
)

// File inputs refs
const fileInputRefs = ref<Record<string, HTMLInputElement | null>>({})

const triggerOptionImagePicker = (optId: string) => {
  fileInputRefs.value[optId]?.click()
}

const handleOptionImageChange = (opt: OptionItem, e: Event) => {
  const target = e.target as HTMLInputElement
  if (target.files && target.files[0]) {
    const file = target.files[0]
    const reader = new FileReader()
    reader.onload = (event) => {
      if (event.target?.result) {
        opt.imageUrl = event.target.result as string
      }
    }
    reader.readAsDataURL(file)
  }
}

const removeOptionImage = (opt: OptionItem, e?: Event) => {
  e?.stopPropagation()
  opt.imageUrl = undefined
}

// Character limit
const maxQuestionLength = 280
const maxOptionLength = 65

// Quick hashtag / mention insert
const insertHash = () => {
  const el = questionTextareaRef.value
  if (!el) {
    question.value = question.value ? `${question.value} #` : '#'
    return
  }
  const start = el.selectionStart ?? question.value.length
  const end = el.selectionEnd ?? question.value.length
  const before = question.value.substring(0, start)
  const after = question.value.substring(end)
  const prefix = (before.length > 0 && !before.endsWith(' ') && !before.endsWith('\n')) ? ' #' : '#'
  question.value = before + prefix + after
  nextTick(() => {
    el.focus()
    const pos = start + prefix.length
    el.setSelectionRange(pos, pos)
  })
}

const insertMention = () => {
  const el = questionTextareaRef.value
  if (!el) {
    question.value = question.value ? `${question.value} @` : '@'
    return
  }
  const start = el.selectionStart ?? question.value.length
  const end = el.selectionEnd ?? question.value.length
  const before = question.value.substring(0, start)
  const after = question.value.substring(end)
  const prefix = (before.length > 0 && !before.endsWith(' ') && !before.endsWith('\n')) ? ' @' : '@'
  question.value = before + prefix + after
  nextTick(() => {
    el.focus()
    const pos = start + prefix.length
    el.setSelectionRange(pos, pos)
  })
}

// Option management
const addOption = () => {
  if (options.value.length < 4) {
    options.value.push({
      id: `opt-${options.value.length + 1}`,
      text: '',
    })
  }
}

const removeOption = (index: number) => {
  if (options.value.length > 2) {
    options.value.splice(index, 1)
  }
}

// Validation
const validOptionsCount = computed(() => {
  return options.value.filter(o => o.text.trim().length > 0 || (responseType.value === 'imagen' && !!o.imageUrl)).length
})

const canComplete = computed(() => {
  return question.value.trim().length > 0 && validOptionsCount.value >= 2
})

const validationMessage = computed(() => {
  if (!question.value.trim()) {
    return 'Escribe una pregunta para publicar.'
  }
  if (validOptionsCount.value < 2) {
    return responseType.value === 'imagen'
      ? 'Agrega al menos 2 opciones con imagen o texto.'
      : 'Agrega al menos 2 opciones con texto.'
  }
  return null
})

// Save poll
const handleSave = () => {
  if (!canComplete.value) return

  const filtered = options.value
    .filter(o => o.text.trim().length > 0 || (responseType.value === 'imagen' && !!o.imageUrl))
    .map((o, idx) => ({
      id: `poll-opt-${idx + 1}`,
      text: o.text.trim(),
      imageUrl: responseType.value === 'imagen' ? o.imageUrl : undefined,
      votes: 0,
      percentage: 0,
    }))

  const pollData: PollData = {
    question: question.value.trim(),
    responseType: responseType.value,
    totalVotes: 0,
    options: filtered,
  }

  emit('save', pollData)
}
</script>

<template>
  <div class="flex-1 min-w-0 bg-black flex flex-col h-full overflow-hidden select-none">
    <!-- Header -->
    <header class="flex items-center justify-between px-5 py-3.5 border-b border-[#1f212a] bg-black/90 backdrop-blur-md">
      <!-- Left: X button -->
      <button
        type="button"
        @click="emit('cancel')"
        class="w-9 h-9 rounded-full flex items-center justify-center text-gray-300 hover:text-white hover:bg-white/10 transition-colors cursor-pointer"
        title="Cancelar encuesta"
      >
        <X class="w-5 h-5" />
      </button>

      <!-- Center: Title -->
      <h2 class="text-base sm:text-lg font-bold text-white tracking-tight">
        Crear encuesta
      </h2>

      <!-- Right: Listo button -->
      <button
        type="button"
        @click="handleSave"
        :disabled="!canComplete"
        class="px-4 py-1.5 rounded-full text-sm font-semibold transition-all duration-200"
        :class="
          canComplete
            ? 'bg-[#f0254c] hover:bg-[#d9193f] active:scale-95 text-white shadow-md shadow-[#f0254c]/30 cursor-pointer'
            : 'bg-[#232532] text-gray-500 cursor-not-allowed'
        "
      >
        Listo
      </button>
    </header>

    <!-- Scrollable Form Body -->
    <div class="flex-1 overflow-y-auto no-scrollbar p-5 space-y-5">
      <!-- Title & Subtitle Section -->
      <div>
        <h3 class="text-base sm:text-lg font-bold text-white tracking-tight leading-snug">
          Haz una pregunta para tu comunidad
        </h3>
        <p class="text-xs sm:text-sm text-gray-400 mt-1 leading-relaxed">
          Elige si responderán con texto o imágenes y agrega de 2 a 4 respuestas.
        </p>
      </div>

      <!-- Question Textbox Card -->
      <div class="p-4 rounded-2xl bg-[#141018] border border-[#2d1b2e] focus-within:border-[#f0254c]/70 transition-colors shadow-sm">
        <textarea
          ref="questionTextareaRef"
          v-model="question"
          :maxlength="maxQuestionLength"
          rows="3"
          placeholder="¿Qué quieres preguntar?"
          class="w-full bg-transparent text-white placeholder:text-gray-500 focus:outline-none resize-none text-[15px] sm:text-[16px] leading-relaxed select-text"
        />
        <div class="text-right text-xs text-gray-500 font-mono mt-1">
          {{ question.length }}/{{ maxQuestionLength }}
        </div>
      </div>

      <!-- Quick Action Pills (# Hashtag & @ Mención) -->
      <div class="flex items-center gap-2.5">
        <button
          type="button"
          @click="insertHash"
          class="flex items-center gap-1.5 px-4 py-1.5 rounded-full bg-[#18121f] border border-[#2b192e] hover:border-[#f0254c]/50 text-gray-300 hover:text-white text-xs font-semibold transition-colors cursor-pointer"
        >
          <Hash class="w-3.5 h-3.5 text-[#f0254c]" />
          <span>Hashtag</span>
        </button>

        <button
          type="button"
          @click="insertMention"
          class="flex items-center gap-1.5 px-4 py-1.5 rounded-full bg-[#18121f] border border-[#2b192e] hover:border-[#f0254c]/50 text-gray-300 hover:text-white text-xs font-semibold transition-colors cursor-pointer"
        >
          <AtSign class="w-3.5 h-3.5 text-[#f0254c]" />
          <span>Mención</span>
        </button>
      </div>

      <!-- Response Type Section -->
      <div class="space-y-3 pt-1">
        <div class="flex items-center justify-between">
          <span class="text-sm font-bold text-white tracking-tight">
            Tipo de respuesta
          </span>
          <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-[#1e1320] text-gray-400 text-xs border border-[#2f1b32]">
            <span class="w-1.5 h-1.5 rounded-full bg-[#f0254c]" />
            {{ responseType === 'texto' ? 'Texto' : 'Imagen' }}
          </span>
        </div>

        <div class="flex items-center gap-2.5">
          <!-- Texto pill button -->
          <button
            type="button"
            @click="responseType = 'texto'"
            class="flex items-center gap-1.5 px-4 py-2 rounded-full text-xs font-bold transition-all cursor-pointer"
            :class="
              responseType === 'texto'
                ? 'bg-[#f0254c] text-white shadow-md shadow-[#f0254c]/20'
                : 'bg-[#18131d] border border-[#2c1b2f] text-gray-300 hover:text-white'
            "
          >
            <SquareCheck v-if="responseType === 'texto'" class="w-3.5 h-3.5 text-white" />
            <List v-else class="w-3.5 h-3.5 text-gray-400" />
            <span>Texto</span>
          </button>

          <!-- Imagen pill button -->
          <button
            type="button"
            @click="responseType = 'imagen'"
            class="flex items-center gap-1.5 px-4 py-2 rounded-full text-xs font-bold transition-all cursor-pointer"
            :class="
              responseType === 'imagen'
                ? 'bg-[#f0254c] text-white shadow-md shadow-[#f0254c]/20'
                : 'bg-[#18131d] border border-[#2c1b2f] text-gray-300 hover:text-white'
            "
          >
            <SquareCheck v-if="responseType === 'imagen'" class="w-3.5 h-3.5 text-white" />
            <ImageIcon v-else class="w-3.5 h-3.5 text-gray-400" />
            <span>Imagen</span>
          </button>
        </div>
      </div>

      <!-- Options Section -->
      <div class="space-y-3 pt-1">
        <div class="flex items-center justify-between">
          <span class="text-sm font-bold text-white tracking-tight">
            Opciones
          </span>
          <span class="text-xs text-gray-400 font-mono">
            {{ options.length }}/4
          </span>
        </div>

        <div class="space-y-2.5">
          <div
            v-for="(opt, idx) in options"
            :key="opt.id"
            class="flex items-center gap-3.5 p-3 rounded-2xl bg-[#141018] border border-[#2d1b2e] focus-within:border-[#f0254c]/70 transition-colors shadow-sm"
          >
            <!-- Mode 1: Imagen mode - Square image picker box matching user screenshot -->
            <div
              v-if="responseType === 'imagen'"
              class="relative w-20 h-20 rounded-2xl bg-[#221627] border border-[#3b2440] hover:border-[#f0254c]/70 transition-all flex items-center justify-center cursor-pointer shrink-0 overflow-hidden group select-none shadow-inner"
              @click="triggerOptionImagePicker(opt.id)"
              title="Seleccionar imagen"
            >
              <!-- Hidden input for file selection -->
              <input
                :ref="el => { fileInputRefs[opt.id] = el as HTMLInputElement }"
                type="file"
                accept="image/*"
                class="hidden"
                @change="e => handleOptionImageChange(opt, e)"
              />

              <!-- Preview of chosen image -->
              <template v-if="opt.imageUrl">
                <img
                  :src="opt.imageUrl"
                  alt="Opción"
                  class="w-full h-full object-cover"
                />
                <!-- Hover controls -->
                <div class="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-1.5">
                  <span class="p-1 rounded-md bg-black/80 text-white hover:text-[#f0254c] transition-colors" title="Cambiar imagen">
                    <Camera class="w-3.5 h-3.5" />
                  </span>
                  <button
                    type="button"
                    @click="e => removeOptionImage(opt, e)"
                    class="p-1 rounded-md bg-black/80 text-white hover:text-red-400 transition-colors"
                    title="Quitar imagen"
                  >
                    <Trash2 class="w-3.5 h-3.5" />
                  </button>
                </div>
              </template>

              <!-- Empty placeholder matching screenshot -->
              <template v-else>
                <!-- Central gallery icon -->
                <ImageIcon class="w-8 h-8 text-gray-300 stroke-[1.5]" />

                <!-- Bottom right Camera with + badge -->
                <div class="absolute bottom-2 right-2 flex items-center text-gray-300">
                  <Camera class="w-3.5 h-3.5" />
                  <span class="text-[9px] font-black leading-none ml-0.5">+</span>
                </div>
              </template>
            </div>

            <!-- Mode 2: Texto mode - Crimson Circle with number -->
            <div
              v-else
              class="w-7 h-7 rounded-full bg-[#79141b] text-white font-bold text-xs flex items-center justify-center shrink-0 shadow-sm"
            >
              {{ idx + 1 }}
            </div>

            <!-- Option Text Input -->
            <input
              v-model="opt.text"
              type="text"
              :maxlength="maxOptionLength"
              :placeholder="`Respuesta ${idx + 1}`"
              class="flex-1 bg-transparent text-sm sm:text-base text-white placeholder:text-gray-500 focus:outline-none"
            />

            <!-- Trash button -->
            <button
              v-if="options.length > 2"
              type="button"
              @click="removeOption(idx)"
              class="text-gray-500 hover:text-red-400 p-1.5 transition-colors cursor-pointer shrink-0"
              title="Eliminar opción"
            >
              <Trash2 class="w-4 h-4" />
            </button>
          </div>
        </div>

        <!-- + Agregar respuesta button -->
        <button
          v-if="options.length < 4"
          type="button"
          @click="addOption"
          class="w-full p-3.5 rounded-2xl border border-[#28182b] bg-[#120e15] hover:bg-[#1a121e] hover:border-[#f0254c]/40 text-[#f0254c] text-sm font-semibold flex items-center gap-2 transition-all cursor-pointer"
        >
          <Plus class="w-4 h-4" />
          <span>Agregar respuesta</span>
        </button>

        <!-- Footnote text -->
        <p class="text-xs text-gray-500 pt-1">
          De 2 a 4 respuestas · hasta 65 caracteres cada una.
        </p>
      </div>

      <!-- Validation Error Banner matching screenshot -->
      <div
        v-if="validationMessage"
        class="p-3.5 rounded-xl bg-[#79141b] border border-red-500/30 text-white text-xs sm:text-sm flex items-center gap-2.5 shadow-md shadow-[#79141b]/20"
      >
        <Info class="w-4 h-4 shrink-0 text-white" />
        <span class="font-medium">{{ validationMessage }}</span>
      </div>
    </div>
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

