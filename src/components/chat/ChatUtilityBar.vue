<script setup lang="ts">
import { ref } from 'vue'
import { Target, Bell, SquarePen } from 'lucide-vue-next'

const emit = defineEmits<{
  (e: 'click-radar'): void
  (e: 'click-notifications'): void
  (e: 'click-compose'): void
}>()

const unreadNotifications = ref(3)
</script>

<template>
  <div class="flex items-center gap-1">
    <!-- 1. Radar / Target (Minimalist flat accent) -->
    <button
      type="button"
      @click="emit('click-radar')"
      class="w-7 h-7 rounded-full bg-[#f0254c] hover:bg-[#d9193f] text-white flex items-center justify-center transition-colors cursor-pointer shrink-0"
      title="Radar de juego / Matchmaking"
    >
      <Target class="w-4 h-4" />
    </button>

    <!-- 2. Notifications Bell with subtle micro-badge -->
    <button
      type="button"
      @click="emit('click-notifications')"
      class="relative p-1.5 rounded-lg text-gray-400 hover:text-white hover:bg-white/5 transition-colors cursor-pointer"
      title="Notificaciones"
    >
      <Bell class="w-4.5 h-4.5" />
      <span
        v-if="unreadNotifications > 0"
        class="absolute top-1 right-1 w-2 h-2 rounded-full bg-[#f0254c] ring-2 ring-black"
      />
    </button>

    <!-- 3. New Message / Compose Icon -->
    <button
      type="button"
      @click="emit('click-compose')"
      class="p-1.5 rounded-lg text-gray-400 hover:text-white hover:bg-white/5 transition-colors cursor-pointer"
      title="Nuevo mensaje"
    >
      <SquarePen class="w-4.5 h-4.5" />
    </button>
  </div>
</template>

