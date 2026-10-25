<script setup lang="ts">
import { onMounted, onUnmounted } from 'vue'
import { MessageSquare, UserPlus } from 'lucide-vue-next'

interface Props {
  isOpen: boolean
}

defineProps<Props>()

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'new-direct-chat'): void
  (e: 'new-group'): void
}>()

const handleKeyDown = (e: KeyboardEvent) => {
  if (e.key === 'Escape') {
    emit('close')
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleKeyDown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeyDown)
})
</script>

<template>
  <Teleport to="body">
    <Transition name="modal-fade">
      <div
        v-if="isOpen"
        class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/75 backdrop-blur-sm select-none"
        @click.self="emit('close')"
      >
        <div
          class="relative w-full max-w-sm rounded-3xl border border-[#232535] bg-[#14151f] p-6 shadow-2xl transition-all duration-200"
        >
          <!-- Options List -->
          <div class="space-y-2">
            <!-- 1. Nuevo chat -->
            <button
              type="button"
              @click="emit('new-direct-chat'); emit('close')"
              class="w-full flex items-start gap-4 p-3.5 rounded-2xl hover:bg-white/[0.06] active:scale-[0.99] transition-all duration-150 text-left cursor-pointer group"
            >
              <div class="p-1 text-gray-300 group-hover:text-white transition-colors shrink-0 mt-0.5">
                <MessageSquare class="w-6 h-6" />
              </div>

              <div class="flex-1 min-w-0">
                <h4 class="text-[17px] font-semibold text-white tracking-wide">
                  Nuevo chat
                </h4>
                <p class="text-xs sm:text-sm text-gray-400 mt-0.5">
                  Escribe a una amistad
                </p>
              </div>
            </button>

            <!-- 2. Crear grupo -->
            <button
              type="button"
              @click="emit('new-group'); emit('close')"
              class="w-full flex items-start gap-4 p-3.5 rounded-2xl hover:bg-white/[0.06] active:scale-[0.99] transition-all duration-150 text-left cursor-pointer group"
            >
              <div class="p-1 text-gray-300 group-hover:text-white transition-colors shrink-0 mt-0.5">
                <UserPlus class="w-6 h-6" />
              </div>

              <div class="flex-1 min-w-0">
                <h4 class="text-[17px] font-semibold text-white tracking-wide">
                  Crear grupo
                </h4>
                <p class="text-xs sm:text-sm text-gray-400 mt-0.5">
                  Invita a tus amistades
                </p>
              </div>
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
  transition: opacity 180ms ease, transform 180ms cubic-bezier(0.23, 1, 0.32, 1);
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
  transform: scale(0.96);
}
</style>

