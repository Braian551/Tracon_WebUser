<script setup lang="ts">
import { computed } from 'vue'
import { ChevronLeft, Bell, User } from 'lucide-vue-next'
import logoImage from '../../assets/logo.png'
import { notificationsData } from '../../data/mockData'
import type { NotificationItem } from '../../types'

interface Props {
  items?: NotificationItem[]
  title?: string
}

const props = withDefaults(defineProps<Props>(), {
  items: () => notificationsData,
  title: 'Notificaciones',
})

const emit = defineEmits<{
  (e: 'back'): void
  (e: 'click-notification', item: NotificationItem): void
}>()

// Group notifications by section (Hoy, Ayer, etc.)
const groupedNotifications = computed(() => {
  const groups: Record<string, NotificationItem[]> = {}
  for (const item of props.items) {
    if (!groups[item.groupSection]) {
      groups[item.groupSection] = []
    }
    groups[item.groupSection].push(item)
  }
  return groups
})
</script>

<template>
  <div
    class="flex-1 min-w-0 rounded-2xl lg:rounded-3xl border border-[#1f212a] bg-black overflow-hidden flex flex-col h-[calc(100vh-2rem)] lg:h-[calc(100vh-2.5rem)] sticky top-4 lg:top-5 shadow-lg select-none"
  >
    <!-- Top Header: Back Button, Centered Title, Bell Action -->
    <div
      class="px-4 sm:px-6 py-4 border-b border-[#15161e] flex items-center justify-between shrink-0 bg-black/95 backdrop-blur-md z-10"
    >
      <!-- Back button -->
      <button
        type="button"
        @click="emit('back')"
        class="p-2 -ml-2 rounded-full text-white hover:bg-white/10 active:scale-95 transition-all duration-150 cursor-pointer flex items-center justify-center"
        title="Volver"
      >
        <ChevronLeft class="w-6 h-6 stroke-[2.5]" />
      </button>

      <!-- Title -->
      <h2 class="text-lg sm:text-xl font-bold text-white tracking-tight text-center">
        {{ title }}
      </h2>

      <!-- Bell action -->
      <button
        type="button"
        class="p-2 -mr-2 rounded-full text-gray-300 hover:text-white hover:bg-white/10 active:scale-95 transition-all duration-150 cursor-pointer flex items-center justify-center"
        title="Configuración de notificaciones"
      >
        <Bell class="w-5 h-5" />
      </button>
    </div>

    <!-- Scrollable Notifications List -->
    <div class="flex-1 overflow-y-auto px-3 sm:px-5 py-3 space-y-6 custom-scrollbar">
      <div
        v-for="(sectionItems, sectionName) in groupedNotifications"
        :key="sectionName"
        class="space-y-1.5"
      >
        <!-- Section Header (e.g. Hoy, Ayer in Red) -->
        <h3 class="text-[#f0254c] text-[15px] font-bold px-2 pt-1 pb-1 tracking-wide">
          {{ sectionName }}
        </h3>

        <!-- Section Items -->
        <div class="space-y-1">
          <div
            v-for="item in sectionItems"
            :key="item.id"
            @click="emit('click-notification', item)"
            class="flex items-center gap-3.5 px-2.5 sm:px-3 py-2.5 rounded-2xl hover:bg-white/[0.04] active:bg-white/[0.08] transition-colors cursor-pointer group"
          >
            <!-- Avatar -->
            <div
              class="relative w-11 h-11 shrink-0 rounded-full flex items-center justify-center overflow-hidden transition-transform duration-200 group-hover:scale-105"
            >
              <!-- 1. Tracon Official Avatar -->
              <template v-if="item.actor.avatarType === 'tracon'">
                <div class="w-full h-full rounded-full bg-red-950/40 border border-red-500/50 flex items-center justify-center p-1 shadow-[0_0_10px_rgba(240,37,76,0.3)]">
                  <img
                    :src="logoImage"
                    alt="Tracon"
                    class="w-full h-full object-cover scale-110 drop-shadow-[0_0_6px_rgba(240,37,76,0.6)]"
                  />
                </div>
              </template>

              <!-- 2. Purple Mask Avatar (pasa pasa) -->
              <template v-else-if="item.actor.avatarType === 'purple_mask'">
                <div class="w-full h-full rounded-full bg-gradient-to-b from-[#4a154b] to-[#12071f] border border-purple-500/40 flex items-center justify-center p-1 shadow-[0_0_12px_rgba(168,85,247,0.3)]">
                  <svg viewBox="0 0 36 36" class="w-full h-full drop-shadow-[0_0_6px_rgba(192,132,252,0.8)]" fill="none">
                    <!-- Stylized Cyber Cat/Demon Mask -->
                    <path d="M7 6L13 14H23L29 6L27 18L18 31L9 18L7 6Z" fill="#a855f7" />
                    <path d="M10 9L14 15H22L26 9L24 18L18 29L12 18L10 9Z" fill="#581c87" />
                    <!-- Eyes glowing -->
                    <circle cx="14" cy="18" r="2.2" fill="#38bdf8" />
                    <circle cx="22" cy="18" r="2.2" fill="#38bdf8" />
                    <!-- Mouth/Fangs -->
                    <path d="M15 24L18 26L21 24" stroke="#c084fc" stroke-width="1.5" stroke-linecap="round" />
                  </svg>
                </div>
              </template>

              <!-- 3. Minecraft Pixel Avatar (camilo828288) -->
              <template v-else-if="item.actor.avatarType === 'minecraft'">
                <div class="w-full h-full rounded-full bg-[#1b2a1a] border border-green-600/40 flex items-center justify-center overflow-hidden">
                  <svg viewBox="0 0 32 32" class="w-full h-full" fill="none">
                    <!-- Head & Hair -->
                    <rect width="32" height="32" fill="#2d1c14" />
                    <rect x="6" y="8" width="20" height="16" fill="#be8568" />
                    <rect x="6" y="6" width="20" height="5" fill="#4a2e1b" />
                    <rect x="6" y="11" width="4" height="6" fill="#4a2e1b" />
                    <rect x="22" y="11" width="4" height="6" fill="#4a2e1b" />
                    <!-- Eyes -->
                    <rect x="8" y="13" width="4" height="2.5" fill="#ffffff" />
                    <rect x="10" y="13" width="2" height="2.5" fill="#3b5998" />
                    <rect x="20" y="13" width="4" height="2.5" fill="#ffffff" />
                    <rect x="20" y="13" width="2" height="2.5" fill="#3b5998" />
                    <!-- Nose / Mouth -->
                    <rect x="13" y="16.5" width="6" height="2" fill="#8f573c" />
                    <rect x="11" y="19" width="10" height="2.5" fill="#532d1d" />
                  </svg>
                </div>
              </template>

              <!-- 4. Red User Avatar (octav20rpro / beatrizcatano) -->
              <template v-else>
                <div class="w-full h-full rounded-full bg-[#161214] border-2 border-[#b91c1c]/70 flex items-center justify-center shadow-[0_0_8px_rgba(185,28,28,0.25)]">
                  <User class="w-5 h-5 text-gray-200 fill-gray-200/20" />
                </div>
              </template>
            </div>

            <!-- Content text -->
            <div class="flex-1 min-w-0 text-[14px] leading-snug">
              <span class="font-bold text-white tracking-wide mr-1.5">{{ item.actor.name }}</span>
              <span v-if="item.actionText" class="text-gray-300 font-normal">{{ item.actionText }}</span>
              <span class="text-gray-400 text-[13px] ml-1.5 whitespace-nowrap">{{ item.timeAgo }}</span>
            </div>

            <!-- Right-side Media Thumbnail (if applicable) -->
            <div
              v-if="item.thumbnailType"
              class="w-10 sm:w-11 h-13 sm:h-14 rounded-lg overflow-hidden shrink-0 border border-white/10 bg-[#12131a] relative group-hover:border-white/25 transition-colors shadow-sm"
            >
              <!-- 1. Dark Atmospheric Scene (tracon comment/reaction) -->
              <template v-if="item.thumbnailType === 'dark_scene'">
                <div class="w-full h-full bg-gradient-to-b from-[#1b1c24] via-[#0d0e14] to-[#161720] flex items-center justify-center relative">
                  <div class="absolute inset-x-2 top-1 bottom-1 flex gap-1 opacity-25">
                    <div class="w-0.5 h-full bg-white/40 blur-[0.5px]" />
                    <div class="w-1 h-full bg-white/20 blur-[1px]" />
                  </div>
                </div>
              </template>

              <!-- 2. Night Car on Bridge / Highway (likes/impulses on Trak) -->
              <template v-else-if="item.thumbnailType === 'night_car'">
                <div class="w-full h-full bg-gradient-to-b from-[#0c1322] via-[#0a0c14] to-[#120e18] flex flex-col justify-end p-1 relative">
                  <!-- Road bridge lines -->
                  <div class="absolute inset-0 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-blue-900/30 via-transparent to-transparent" />
                  <!-- Sports car rear taillights silhouette -->
                  <div class="w-6 h-3 mx-auto relative flex items-center justify-between">
                    <div class="w-1.5 h-1 rounded-sm bg-red-600 shadow-[0_0_6px_#ef4444]" />
                    <div class="w-1.5 h-1 rounded-sm bg-red-600 shadow-[0_0_6px_#ef4444]" />
                  </div>
                  <!-- Road dash -->
                  <div class="w-full h-0.5 bg-white/10 mt-0.5 rounded-full" />
                </div>
              </template>

              <!-- 3. Profile Screen Thumbnail (octav20rpro like) -->
              <template v-else-if="item.thumbnailType === 'profile_preview'">
                <div class="w-full h-full bg-[#0a0a0e] p-1 flex flex-col justify-between">
                  <div class="flex items-center gap-0.5">
                    <div class="w-2 h-2 rounded-full bg-red-500/80" />
                    <div class="w-4 h-1 rounded bg-white/30" />
                  </div>
                  <div class="space-y-0.5">
                    <div class="w-full h-1 bg-white/15 rounded" />
                    <div class="w-3/4 h-1 bg-white/15 rounded" />
                  </div>
                  <div class="w-full h-2 rounded bg-[#f0254c]/60" />
                </div>
              </template>

              <!-- 4. Tracon Promo Card (beatrizcatano comment) -->
              <template v-else-if="item.thumbnailType === 'tracon_promo'">
                <div class="w-full h-full bg-gradient-to-b from-[#40060e] to-[#1a0307] p-1 flex flex-col items-center justify-center text-center">
                  <div class="w-3 h-3 rounded-full bg-white/10 flex items-center justify-center mb-0.5">
                    <img :src="logoImage" alt="" class="w-2 h-2 object-contain" />
                  </div>
                  <span class="text-[6px] font-black tracking-tighter text-white uppercase leading-none">
                    TRACON
                  </span>
                </div>
              </template>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.custom-scrollbar::-webkit-scrollbar {
  width: 5px;
}
.custom-scrollbar::-webkit-scrollbar-track {
  background: transparent;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.12);
  border-radius: 9999px;
}
.custom-scrollbar::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.22);
}
</style>

