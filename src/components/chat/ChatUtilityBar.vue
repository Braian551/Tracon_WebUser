<script setup lang="ts">
import { Target, SquarePen } from 'lucide-vue-next'
import NotificationBell from '../common/NotificationBell.vue'

interface Props {
  isNotificationsActive?: boolean
}

withDefaults(defineProps<Props>(), {
  isNotificationsActive: false,
})

const emit = defineEmits<{
  (e: 'click-radar'): void
  (e: 'click-notifications'): void
  (e: 'click-compose'): void
}>()
</script>

<template>
  <div class="flex items-center gap-1.5">
    <!-- 1. Radar / Target (Minimalist flat accent) -->
    <button
      type="button"
      @click="emit('click-radar')"
      class="w-7 h-7 rounded-full bg-[#f0254c] hover:bg-[#d9193f] text-white flex items-center justify-center transition-colors cursor-pointer shrink-0"
      title="Radar de juego / Matchmaking"
    >
      <Target class="w-4 h-4" />
    </button>

    <!-- 2. Reusable Notifications Bell -->
    <NotificationBell
      :count="6"
      :is-active="isNotificationsActive"
      @click="emit('click-notifications')"
    />

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

