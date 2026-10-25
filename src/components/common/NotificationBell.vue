<script setup lang="ts">
import { Bell } from 'lucide-vue-next'

interface Props {
  count?: number
  title?: string
  isActive?: boolean
}

withDefaults(defineProps<Props>(), {
  count: 6,
  title: 'Notificaciones',
  isActive: false,
})

const emit = defineEmits<{
  (e: 'click'): void
}>()
</script>

<template>
  <button
    type="button"
    @click="emit('click')"
    class="relative p-2 rounded-full transition-all duration-200 active:scale-95 cursor-pointer flex items-center justify-center select-none shrink-0"
    :class="isActive ? 'text-[#f0254c] bg-white/10 ring-1 ring-[#f0254c]/40' : 'text-white hover:bg-white/10'"
    :title="title"
  >
    <!-- Bell Icon -->
    <Bell class="w-5 h-5" :class="isActive ? 'text-[#f0254c] fill-[#f0254c]/20' : 'text-white'" />

    <!-- Unread Badge with Salmon/Pink Pill Matching Design -->
    <span
      v-if="count > 0 && !isActive"
      class="absolute top-0.5 right-0.5 min-w-[16px] h-[16px] px-1 rounded-full bg-[#fca5a5] text-black text-[10px] font-black flex items-center justify-center leading-none ring-2 ring-black shadow-sm pointer-events-none"
    >
      {{ count > 99 ? '99+' : count }}
    </span>
  </button>
</template>

