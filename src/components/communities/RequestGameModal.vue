<script setup lang="ts">
import { ref } from 'vue'
import { Check, ImageIcon, PlusSquare } from 'lucide-vue-next'

interface Props {
  isOpen: boolean
  title?: string
  description?: string
}

withDefaults(defineProps<Props>(), {
  isOpen: false,
  title: 'Incorporar juego al catálogo',
  description: 'La solicitud se guardará con tu comunidad y se enviará al confirmar todo el formulario.',
})

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'submit', data: { name: string; website: string; reason: string }): void
}>()

const form = ref({
  name: '',
  website: '',
  reason: '',
})

const handleClose = () => {
  emit('close')
}

const handleSubmit = () => {
  emit('submit', {
    name: form.value.name.trim(),
    website: form.value.website.trim(),
    reason: form.value.reason.trim(),
  })
  // Reset form
  form.value = { name: '', website: '', reason: '' }
  emit('close')
}
</script>

<template>
  <Teleport to="body">
    <Transition name="modal-fade">
      <div
        v-if="isOpen"
        class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm select-none"
        @click.self="handleClose"
      >
        <div
          class="relative w-full max-w-md rounded-3xl border border-[#232535] bg-[#14151f] p-6 sm:p-7 shadow-2xl transition-all duration-200"
          role="dialog"
          aria-modal="true"
        >
          <!-- Top Icon & Header -->
          <div class="flex items-start gap-4 mb-4">
            <div class="w-12 h-12 rounded-2xl bg-[#70081a] border border-[#a8142b]/50 flex items-center justify-center text-white shrink-0 shadow-lg shadow-[#70081a]/30">
              <PlusSquare class="w-6 h-6 stroke-[2]" />
            </div>

            <div class="flex-1 min-w-0">
              <h3 class="text-xl font-bold text-white tracking-tight leading-snug">
                {{ title }}
              </h3>
              <p class="text-xs text-gray-400 mt-1 leading-relaxed">
                {{ description }}
              </p>
            </div>
          </div>

          <!-- Form Fields -->
          <div class="space-y-4 my-5">
            <!-- Add Game Image Button / Box -->
            <button
              type="button"
              class="w-full h-12 rounded-2xl border border-dashed border-[#f0254c]/40 bg-[#70081a]/10 hover:bg-[#70081a]/20 transition-colors flex items-center justify-center gap-2 text-xs font-semibold text-[#f0254c] cursor-pointer"
            >
              <ImageIcon class="w-4 h-4" />
              <span>Añadir imagen del juego</span>
            </button>

            <!-- 1. Nombre del juego -->
            <div class="relative">
              <div class="bg-[#10111a] border border-[#222433] focus-within:border-[#f0254c] rounded-2xl px-4 pt-2.5 pb-3 transition-colors">
                <label class="block text-[11px] font-semibold text-[#f0254c] mb-0.5">
                  Nombre del juego
                </label>
                <input
                  v-model="form.name"
                  type="text"
                  maxlength="160"
                  placeholder="Escribe el nombre del juego"
                  class="w-full bg-transparent text-white placeholder-gray-600 text-sm focus:outline-none"
                />
              </div>
              <div class="flex justify-end px-2 pt-1 text-[11px] text-gray-500">
                {{ form.name.length }}/160
              </div>
            </div>

            <!-- 2. Sitio web (opcional) -->
            <div class="bg-[#10111a] border border-[#222433] focus-within:border-[#f0254c] rounded-2xl px-4 py-3 transition-colors">
              <input
                v-model="form.website"
                type="url"
                placeholder="Sitio web (opcional)"
                class="w-full bg-transparent text-white placeholder-gray-500 text-sm focus:outline-none"
              />
            </div>

            <!-- 3. Motivo para incorporarlo -->
            <div class="relative">
              <div class="bg-[#10111a] border border-[#222433] focus-within:border-[#f0254c] rounded-2xl px-4 py-3 transition-colors">
                <textarea
                  v-model="form.reason"
                  rows="3"
                  maxlength="3000"
                  placeholder="Motivo para incorporarlo"
                  class="w-full bg-transparent text-white placeholder-gray-500 text-sm focus:outline-none resize-none"
                />
              </div>
              <div class="flex justify-end px-2 pt-1 text-[11px] text-gray-500">
                {{ form.reason.length }}/3000
              </div>
            </div>
          </div>

          <!-- Bottom Action Buttons matching Screenshot -->
          <div class="flex items-center justify-between pt-2">
            <button
              type="button"
              @click="handleClose"
              class="px-4 py-2 text-sm font-semibold text-[#f0254c] hover:text-[#ff3860] hover:underline transition-colors cursor-pointer"
            >
              Cancelar
            </button>

            <button
              type="button"
              @click="handleSubmit"
              class="px-7 py-3 rounded-2xl bg-[#f0254c] hover:bg-[#d9193f] active:scale-[0.99] text-white font-semibold text-sm tracking-wide shadow-lg shadow-[#f0254c]/25 transition-all flex items-center gap-1.5 cursor-pointer"
            >
              <Check class="w-4 h-4 stroke-[3]" />
              <span>Aceptar</span>
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 240ms cubic-bezier(0.23, 1, 0.32, 1), transform 240ms cubic-bezier(0.23, 1, 0.32, 1);
}

.modal-fade-enter-from {
  opacity: 0;
  transform: scale(0.96) translateY(8px);
}

.modal-fade-leave-to {
  opacity: 0;
  transform: scale(0.96) translateY(8px);
}
</style>

