<script setup lang="ts">
import { ref, computed } from 'vue'
import {
  Search,
  ChevronRight,
  CheckCircle2,
  Plus,
} from 'lucide-vue-next'
import NotificationBell from '../common/NotificationBell.vue'
import CommunityThreeUsersIcon from '../common/CommunityThreeUsersIcon.vue'
import ChatBubbleSolidIcon from '../common/ChatBubbleSolidIcon.vue'
import type { CommunityFeedItem } from '../../types'

interface Props {
  activeTab?: 'chats' | 'comunidades'
  myCommunities?: CommunityFeedItem[]
  suggestedCommunities?: CommunityFeedItem[]
}

const props = withDefaults(defineProps<Props>(), {
  activeTab: 'comunidades',
  myCommunities: () => [],
  suggestedCommunities: () => [],
})

const emit = defineEmits<{
  (e: 'change-tab', tab: 'chats' | 'comunidades'): void
  (e: 'create-community'): void
  (e: 'request-game'): void
  (e: 'select-community', item: CommunityFeedItem): void
  (e: 'click-notifications'): void
}>()

const searchQuery = ref('')

const filteredMyCommunities = computed(() => {
  if (!searchQuery.value.trim()) return props.myCommunities
  const q = searchQuery.value.toLowerCase()
  return props.myCommunities.filter(
    (c) =>
      c.name.toLowerCase().includes(q) ||
      c.gameSubtitle.toLowerCase().includes(q) ||
      c.description.toLowerCase().includes(q)
  )
})

const filteredSuggestedCommunities = computed(() => {
  if (!searchQuery.value.trim()) return props.suggestedCommunities
  const q = searchQuery.value.toLowerCase()
  return props.suggestedCommunities.filter(
    (c) =>
      c.name.toLowerCase().includes(q) ||
      c.gameSubtitle.toLowerCase().includes(q) ||
      c.description.toLowerCase().includes(q)
  )
})
</script>

<template>
  <main
    class="flex-1 min-w-0 rounded-2xl lg:rounded-3xl border border-[#1f212a] bg-black overflow-hidden flex flex-col h-[calc(100vh-2rem)] lg:h-[calc(100vh-2.5rem)] sticky top-4 lg:top-5 shadow-lg select-none"
  >
    <!-- Header with Comunidades Title + Reusable NotificationBell matching design -->
    <div class="px-5 pt-4 pb-2 border-b border-[#15161e] flex items-center justify-between">
      <h2 class="text-xl font-bold text-white tracking-tight">
        Comunidades
      </h2>
      <NotificationBell
        :count="6"
        @click="emit('click-notifications')"
      />
    </div>

    <!-- Sub-tabs: Chats vs Comunidades with icons -->
    <div class="relative flex border-b border-[#15161e] px-2 bg-black/70 backdrop-blur-md">
      <button
        type="button"
        @click="emit('change-tab', 'chats')"
        class="relative flex-1 py-3 text-sm font-semibold text-center transition-colors duration-200 cursor-pointer flex items-center justify-center gap-2"
        :class="activeTab === 'chats' ? 'text-[#f0254c]' : 'text-gray-400 hover:text-gray-200'"
      >
        <ChatBubbleSolidIcon class="w-4 h-4" />
        <span>Chats</span>
      </button>

      <button
        type="button"
        @click="emit('change-tab', 'comunidades')"
        class="relative flex-1 py-3 text-sm font-semibold text-center transition-colors duration-200 cursor-pointer flex items-center justify-center gap-2"
        :class="activeTab === 'comunidades' ? 'text-[#f0254c]' : 'text-gray-400 hover:text-gray-200'"
      >
        <CommunityThreeUsersIcon class="w-4 h-4" />
        <span>Comunidades</span>
      </button>

      <!-- Smooth sliding indicator -->
      <span
        class="absolute bottom-0 h-[3px] rounded-full bg-[#f0254c] shadow-[0_0_8px_rgba(240,37,76,0.6)] transition-all duration-300 ease-[cubic-bezier(0.23,1,0.32,1)] -translate-x-1/2 pointer-events-none"
        :class="activeTab === 'chats' ? 'w-16' : 'w-24'"
        :style="{
          left: activeTab === 'chats' ? '25%' : '75%'
        }"
      />
    </div>

    <!-- Scrollable Feed Content -->
    <div class="flex-1 overflow-y-auto no-scrollbar p-4 sm:p-6 space-y-4 relative">
      <!-- Search Bar -->
      <div class="relative flex items-center bg-[#121319] border border-[#20222e] rounded-full px-4 py-2.5 focus-within:border-gray-500 transition-colors">
        <Search class="w-4 h-4 text-gray-400 shrink-0 mr-2.5" />
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Buscar comunidades o juegos"
          class="w-full bg-transparent text-sm text-gray-100 placeholder:text-gray-500 focus:outline-none"
        />
      </div>

      <!-- Action link: + Solicitar juego al catálogo -->
      <button
        type="button"
        @click="emit('request-game')"
        class="text-sm font-semibold text-[#f0254c] hover:underline flex items-center gap-1 px-1 cursor-pointer transition-colors"
      >
        + Solicitar juego al catálogo
      </button>

      <!-- Section: Tus comunidades -->
      <div class="pt-2">
        <h3 class="text-base sm:text-lg font-bold text-white tracking-wide mb-3">
          Tus comunidades
        </h3>

        <div class="space-y-3">
          <div
            v-for="comm in filteredMyCommunities"
            :key="comm.id"
            @click="emit('select-community', comm)"
            class="p-4 rounded-2xl border border-[#1f212a] bg-[#121319] hover:bg-[#151722] hover:border-[#2d303f] flex items-center justify-between transition-all duration-200 cursor-pointer group shadow-sm"
          >
            <!-- Left Avatar -->
            <div
              class="w-12 h-12 rounded-full border border-[#262835] shrink-0 flex items-center justify-center mr-3.5 transition-transform group-hover:scale-105"
              :style="{ backgroundColor: comm.avatarBg || '#1a1b24' }"
            >
              <div class="w-4 h-4 rounded-full bg-white/10" />
            </div>

            <!-- Middle Info -->
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-1.5">
                <span class="font-bold text-[15px] text-white group-hover:text-red-400 transition-colors truncate">
                  {{ comm.name }}
                </span>
                <CheckCircle2
                  v-if="comm.isVerified"
                  class="w-4 h-4 text-[#f0254c] shrink-0"
                />
              </div>

              <p class="text-xs font-semibold text-[#f0254c] mt-0.5 truncate">
                {{ comm.gameSubtitle }}
              </p>

              <p class="text-xs sm:text-sm text-gray-300 mt-1 leading-snug line-clamp-2">
                {{ comm.description }}
              </p>

              <p class="text-xs text-gray-400 mt-1">
                {{ comm.membersCount }}
              </p>
            </div>

            <!-- Right Chevron -->
            <ChevronRight
              class="w-5 h-5 text-gray-500 group-hover:text-white group-hover:translate-x-0.5 transition-all shrink-0 ml-4"
            />
          </div>
        </div>
      </div>

      <!-- Section: Sugeridas para ti -->
      <div class="pt-3">
        <h3 class="text-base sm:text-lg font-bold text-white tracking-wide mb-3">
          Sugeridas para ti
        </h3>

        <div class="space-y-3">
          <div
            v-for="comm in filteredSuggestedCommunities"
            :key="comm.id"
            @click="emit('select-community', comm)"
            class="p-4 rounded-2xl border border-[#1f212a] bg-[#121319] hover:bg-[#151722] hover:border-[#2d303f] flex items-center justify-between transition-all duration-200 cursor-pointer group shadow-sm"
          >
            <!-- Left Avatar -->
            <div
              class="w-12 h-12 rounded-full border border-[#262835] shrink-0 flex items-center justify-center mr-3.5 transition-transform group-hover:scale-105"
              :style="{ backgroundColor: comm.avatarBg || '#1a1b24' }"
            >
              <div class="w-4 h-4 rounded-full bg-white/10" />
            </div>

            <!-- Middle Info -->
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-1.5">
                <span class="font-bold text-[15px] text-white group-hover:text-red-400 transition-colors truncate">
                  {{ comm.name }}
                </span>
                <CheckCircle2
                  v-if="comm.isVerified"
                  class="w-4 h-4 text-[#f0254c] shrink-0"
                />
              </div>

              <p class="text-xs font-semibold text-[#f0254c] mt-0.5 truncate">
                {{ comm.gameSubtitle }}
              </p>

              <p class="text-xs sm:text-sm text-gray-300 mt-1 leading-snug line-clamp-2">
                {{ comm.description }}
              </p>

              <p class="text-xs text-gray-400 mt-1">
                {{ comm.membersCount }}
              </p>
            </div>

            <!-- Right Chevron -->
            <ChevronRight
              class="w-5 h-5 text-gray-500 group-hover:text-white group-hover:translate-x-0.5 transition-all shrink-0 ml-4"
            />
          </div>
        </div>
      </div>

      <!-- Bottom Floating + Crear Action Button -->
      <div class="sticky bottom-2 flex justify-end pr-1 pt-6 pointer-events-none">
        <button
          type="button"
          @click="emit('create-community')"
          class="pointer-events-auto px-5 py-2.5 rounded-full bg-[#f0254c] hover:bg-[#d9193f] text-white text-sm font-bold shadow-[0_4px_20px_rgba(240,37,76,0.4)] flex items-center gap-1.5 transition-all duration-200 active:scale-95 cursor-pointer"
        >
          <Plus class="w-4 h-4" />
          <span>Crear</span>
        </button>
      </div>
    </div>
  </main>
</template>

