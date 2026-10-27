<script setup lang="ts">
import { ref, computed } from 'vue'
import { X, Search, User, Gamepad2, Skull, Zap } from 'lucide-vue-next'
import logoImage from '../../assets/logo.png'
import { mentionUsersData } from '../../data/mockData'
import type { MentionUser } from '../../types'

const emit = defineEmits<{
  (e: 'cancel'): void
  (e: 'select', handle: string): void
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

const handleSelect = (handle: string) => {
  emit('select', handle)
}
</script>

<template>
  <div class="flex-1 min-w-0 bg-black flex flex-col h-full overflow-hidden select-none">
    <!-- Top Bar: X + "Mención" -->
    <header class="flex items-center justify-between px-5 py-3.5 border-b border-[#1f212a] bg-black/90 backdrop-blur-md">
      <!-- Left: X button -->
      <button
        type="button"
        @click="emit('cancel')"
        class="w-9 h-9 rounded-full flex items-center justify-center text-gray-300 hover:text-white hover:bg-white/10 transition-colors cursor-pointer"
        title="Cancelar"
      >
        <X class="w-5 h-5" />
      </button>

      <!-- Center Title -->
      <h2 class="text-base sm:text-lg font-bold text-white tracking-tight">
        Mención
      </h2>

      <!-- Spacer to balance centered title -->
      <div class="w-9" />
    </header>

    <!-- Search Input matching screenshot capsule -->
    <div class="px-5 py-3.5 border-b border-[#181520] bg-black/50">
      <div class="relative flex items-center bg-[#1d1324] border border-[#2d1c35] rounded-full px-4 py-2.5 focus-within:border-[#f0254c]/70 transition-colors shadow-inner">
        <Search class="w-4 h-4 text-gray-400 mr-2.5 shrink-0" />
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Buscar alias o apodo"
          class="w-full bg-transparent text-sm text-white placeholder:text-gray-400 focus:outline-none"
        />
        <button
          v-if="searchQuery"
          type="button"
          @click="searchQuery = ''"
          class="text-gray-400 hover:text-white ml-2 text-xs font-bold"
        >
          ×
        </button>
      </div>
    </div>

    <!-- Users List matching screenshot -->
    <div class="flex-1 overflow-y-auto no-scrollbar p-3 space-y-1">
      <div
        v-for="user in filteredUsers"
        :key="user.id"
        @click="handleSelect(user.handle)"
        class="flex items-center justify-between p-3 rounded-2xl hover:bg-white/[0.04] transition-colors cursor-pointer group"
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

