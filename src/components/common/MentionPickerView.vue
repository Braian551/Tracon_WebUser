<script setup lang="ts">
import { ref, computed } from 'vue'
import {
  ChevronLeft,
  X,
  User,
  Gamepad2,
  Skull,
  Zap,
} from 'lucide-vue-next'
import SearchInput from './SearchInput.vue'
import logoImage from '../../assets/logo.png'
import { mentionUsersData } from '../../data/mockData'
import type { MentionUser } from '../../types'

interface Props {
  title?: string
  backIcon?: 'chevron' | 'x'
  placeholder?: string
  showHeader?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  title: 'Mención',
  backIcon: 'chevron',
  placeholder: 'Buscar alias o apodo',
  showHeader: true,
})

const emit = defineEmits<{
  (e: 'cancel'): void
  (e: 'select', handle: string, user: MentionUser): void
}>()

const searchQuery = ref('')
const usersList = ref<MentionUser[]>([...mentionUsersData])

const filteredUsers = computed(() => {
  if (!searchQuery.value.trim()) return usersList.value
  const q = searchQuery.value.toLowerCase().trim()
  return usersList.value.filter(
    u => u.name.toLowerCase().includes(q) || u.handle.toLowerCase().includes(q)
  )
})

const toggleFollow = (user: MentionUser) => {
  if (user.followingStatus === 'seguir-tambien') {
    user.followingStatus = 'siguiendo'
  } else if (user.followingStatus === 'siguiendo') {
    user.followingStatus = 'seguir-tambien'
  }
}

const handleSelect = (user: MentionUser) => {
  emit('select', user.handle, user)
}
</script>

<template>
  <div class="flex-1 min-w-0 bg-black flex flex-col h-full overflow-hidden select-none">
    <!-- Top Bar: Header with Back button & centered Title -->
    <header
      v-if="showHeader"
      class="px-4 sm:px-6 pt-4 pb-3 flex items-center justify-between shrink-0 bg-black/95 backdrop-blur-md z-10 border-b border-[#1f212a]"
    >
      <button
        type="button"
        @click="emit('cancel')"
        class="p-2 -ml-2 rounded-full text-white hover:bg-white/10 active:scale-95 transition-all duration-150 cursor-pointer flex items-center justify-center"
        :title="backIcon === 'x' ? 'Cerrar' : 'Volver'"
      >
        <X v-if="backIcon === 'x'" class="w-6 h-6 stroke-[2.5]" />
        <ChevronLeft v-else class="w-6 h-6 stroke-[2.5]" />
      </button>

      <h2 class="text-lg sm:text-xl font-bold text-white tracking-tight text-center">
        {{ title }}
      </h2>

      <!-- Spacer to balance centered title -->
      <div class="w-8" />
    </header>

    <!-- Search Input matching standard Tracon SearchInput capsule -->
    <div class="px-5 py-3 border-b border-[#181520] bg-black/40 shrink-0">
      <SearchInput
        v-model="searchQuery"
        :placeholder="placeholder"
      />
    </div>

    <!-- Users List matching screenshot -->
    <div class="flex-1 overflow-y-auto no-scrollbar p-3 sm:px-5 space-y-1">
      <div
        v-for="user in filteredUsers"
        :key="user.id"
        @click="handleSelect(user)"
        class="flex items-center justify-between p-3 rounded-2xl hover:bg-white/[0.04] transition-colors cursor-pointer group active:scale-[0.99]"
      >
        <!-- Left: Avatar + Details -->
        <div class="flex items-center gap-3.5 min-w-0">
          <!-- 1. Tracon Official Logo Avatar -->
          <div
            v-if="user.isTraconOfficial"
            class="w-11 h-11 rounded-full bg-red-950/40 border border-red-500/40 shadow-[0_0_12px_rgba(240,37,76,0.3)] flex items-center justify-center shrink-0 overflow-hidden"
          >
            <img
              :src="logoImage"
              alt="Tracon Logo"
              class="w-full h-full object-cover scale-110 drop-shadow-[0_0_6px_rgba(240,37,76,0.6)]"
            />
          </div>

          <!-- 2. Unsplash Image Avatar -->
          <div
            v-else-if="user.avatarUrl"
            class="w-11 h-11 rounded-full overflow-hidden shrink-0 border border-[#2b192c] bg-black"
          >
            <img :src="user.avatarUrl" :alt="user.name" class="w-full h-full object-cover" />
          </div>

          <!-- 3. Purple Mask (Sparky67) -->
          <div
            v-else-if="user.avatarType === 'purple_mask'"
            class="w-11 h-11 rounded-full bg-gradient-to-br from-[#401252] to-[#1a0822] border-2 border-purple-500/50 flex items-center justify-center shadow-[0_0_10px_rgba(168,85,247,0.3)] shrink-0"
          >
            <Zap class="w-5 h-5 text-purple-300" />
          </div>

          <!-- 4. Minecraft Pink (Camilo) -->
          <div
            v-else-if="user.avatarType === 'minecraft_pink'"
            class="w-11 h-11 rounded-full bg-gradient-to-br from-[#6b2545] to-[#2b0f1c] border-2 border-pink-500/40 flex items-center justify-center shrink-0"
          >
            <span class="text-xs font-black text-pink-200 font-mono">■■</span>
          </div>

          <!-- 5. Gamer Blue (Alejandro) -->
          <div
            v-else-if="user.avatarType === 'gamer_blue'"
            class="w-11 h-11 rounded-full bg-gradient-to-br from-[#12314e] to-[#0a1827] border-2 border-cyan-500/50 flex items-center justify-center shadow-[0_0_8px_rgba(6,182,212,0.3)] shrink-0"
          >
            <Gamepad2 class="w-5 h-5 text-cyan-300" />
          </div>

          <!-- 6. Horror Meat (Mr Meat) -->
          <div
            v-else-if="user.avatarType === 'horror_meat'"
            class="w-11 h-11 rounded-full bg-gradient-to-br from-[#541c1c] to-[#250b0b] border-2 border-amber-500/50 flex items-center justify-center shadow-[0_0_8px_rgba(245,158,11,0.3)] shrink-0"
          >
            <Skull class="w-5 h-5 text-amber-300" />
          </div>

          <!-- 7. Red User Silhouette (Octavio, el men, Dayam) -->
          <div
            v-else
            class="w-11 h-11 rounded-full bg-[#161214] border-2 border-[#b91c1c]/70 flex items-center justify-center shadow-[0_0_8px_rgba(185,28,28,0.25)] shrink-0"
          >
            <User class="w-5 h-5 text-gray-200 fill-gray-200/20" />
          </div>

          <!-- Name & Handle info -->
          <div class="min-w-0">
            <p class="text-sm font-bold text-white group-hover:text-[#f0254c] transition-colors leading-tight truncate">
              {{ user.name }}
            </p>
            <p class="text-xs text-gray-400 mt-0.5 truncate">
              @{{ user.handle }}
              <span v-if="user.relation" class="text-gray-400">· {{ user.relation }}</span>
            </p>
          </div>
        </div>

        <!-- Right: Status / Follow Pill Button -->
        <div class="shrink-0 ml-3">
          <!-- Siguiendo Pill -->
          <span
            v-if="user.followingStatus === 'siguiendo'"
            class="px-4 py-1.5 rounded-xl bg-[#1c1422] border border-[#311c38] text-xs font-semibold text-gray-300 select-none"
          >
            Siguiendo
          </span>

          <!-- Seguir también Button -->
          <button
            v-else-if="user.followingStatus === 'seguir-tambien'"
            type="button"
            @click.stop="toggleFollow(user)"
            class="px-4 py-1.5 rounded-xl bg-[#f0254c] hover:bg-[#d9193f] text-xs font-bold text-white shadow-sm transition-colors cursor-pointer"
          >
            Seguir también
          </button>
        </div>
      </div>

      <!-- Empty State -->
      <div
        v-if="filteredUsers.length === 0"
        class="text-center py-12 text-gray-400 text-sm"
      >
        No se encontraron usuarios para "{{ searchQuery }}"
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

