<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
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
  (e: 'new-direct-chat'): void
  (e: 'new-group'): void
}>()

const isMenuOpen = ref(false)
const menuRef = ref<HTMLElement | null>(null)

const toggleMenu = () => {
  isMenuOpen.value = !isMenuOpen.value
}

const handleOption = (option: 'direct' | 'group') => {
  isMenuOpen.value = false
  if (option === 'direct') {
    emit('new-direct-chat')
  } else {
    emit('new-group')
  }
}

const handleClickOutside = (e: MouseEvent) => {
  if (menuRef.value && !menuRef.value.contains(e.target as Node)) {
    isMenuOpen.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
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

    <!-- 3. New Message / Compose Icon with Dropdown matching 3-dots style -->
    <div ref="menuRef" class="relative">
      <button
        type="button"
        @click.stop="toggleMenu"
        class="p-1.5 rounded-lg text-gray-400 hover:text-white hover:bg-white/5 transition-colors cursor-pointer"
        :class="isMenuOpen ? 'text-white bg-white/10' : ''"
        title="Nuevo mensaje"
      >
        <SquarePen class="w-4.5 h-4.5" />
      </button>

      <!-- Dropdown Menu exactly matching 3-dots conversation style -->
      <Transition name="dropdown-fade">
        <div
          v-if="isMenuOpen"
          class="absolute right-0 top-full mt-2 w-48 rounded-2xl bg-[#161722] border border-[#262838] py-2 shadow-2xl shadow-black/90 z-50 overflow-hidden"
        >
          <button
            type="button"
            @click="handleOption('direct')"
            class="w-full text-left px-5 py-3 text-[15px] font-normal text-white hover:bg-white/[0.06] transition-colors cursor-pointer"
          >
            Nuevo chat
          </button>

          <button
            type="button"
            @click="handleOption('group')"
            class="w-full text-left px-5 py-3 text-[15px] font-normal text-white hover:bg-white/[0.06] transition-colors cursor-pointer"
          >
            Crear grupo
          </button>
        </div>
      </Transition>
    </div>
  </div>
</template>

<style scoped>
.dropdown-fade-enter-active,
.dropdown-fade-leave-active {
  transition: opacity 150ms ease, transform 150ms cubic-bezier(0.23, 1, 0.32, 1);
}
.dropdown-fade-enter-from,
.dropdown-fade-leave-to {
  opacity: 0;
  transform: translateY(-4px) scale(0.98);
}
</style>

