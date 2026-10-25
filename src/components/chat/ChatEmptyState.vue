<script setup lang="ts">
import { MessageSquareDashed, MoreHorizontal } from 'lucide-vue-next'

const emit = defineEmits<{
  (e: 'new-message'): void
}>()
</script>

<template>
  <div class="flex-1 flex flex-col h-[calc(100vh-2rem)] lg:h-[calc(100vh-2.5rem)] sticky top-4 lg:top-5 rounded-2xl lg:rounded-3xl border border-[#1f212a] bg-[#0c0d12] overflow-hidden shadow-lg select-none">
    <!-- Top Header with horizontal 3 dots -->
    <header class="h-16 px-6 border-b border-[#1f212a] flex items-center justify-end shrink-0">
      <button
        type="button"
        class="p-2 rounded-full text-gray-500 hover:text-white hover:bg-white/10 transition-colors cursor-pointer"
        title="Opciones"
      >
        <MoreHorizontal class="w-5 h-5" />
      </button>
    </header>

    <!-- Center Minimalist Empty State -->
    <div class="flex-1 flex flex-col items-center justify-center p-8 text-center">
      <!-- Subtle Minimalist Icon -->
      <div class="w-16 h-16 rounded-2xl bg-[#121319] border border-[#1e2029] flex items-center justify-center text-gray-500 mb-5 shadow-inner">
        <MessageSquareDashed class="w-8 h-8 text-gray-400" />
      </div>

      <!-- Heading -->
      <h3 class="text-2xl sm:text-3xl font-bold text-white tracking-tight">
        Selecciona un mensaje
      </h3>

      <!-- Subtext -->
      <p class="text-sm text-gray-400 mt-2 max-w-xs leading-relaxed">
        Elige una conversación de tu lista o inicia una nueva.
      </p>

      <!-- Minimalist "Nuevo mensaje" Button -->
      <button
        type="button"
        @click="emit('new-message')"
        class="mt-6 px-6 py-2.5 rounded-xl bg-[#f0254c] hover:bg-[#d9193f] active:scale-[0.99] text-white text-[15px] font-medium tracking-normal transition-colors cursor-pointer"
      >
        Nuevo mensaje
      </button>
    </div>
  </div>
</template>

