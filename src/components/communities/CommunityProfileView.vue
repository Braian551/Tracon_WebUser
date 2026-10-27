<script setup lang="ts">
import {
  ChevronLeft,
  BadgeCheck,
  Gamepad2,
  MessageSquare,
  Hash,
  Image as ImageIcon,
  Megaphone,
} from 'lucide-vue-next'
import type { CommunityDetail } from '../../types'

interface Props {
  community: CommunityDetail
}

const props = defineProps<Props>()

const emit = defineEmits<{
  (e: 'back'): void
  (e: 'open-chat', channelId?: string): void
  (e: 'leave'): void
}>()

const getChannelIcon = (id: string) => {
  if (id === 'multimedia') return ImageIcon
  if (id === 'anuncios') return Megaphone
  return Hash
}
</script>

<template>
  <div class="flex-1 flex flex-col h-full bg-black overflow-hidden select-none relative">
    <!-- Top Header -->
    <header class="h-16 px-4 sm:px-6 border-b border-[#1f212a] flex items-center justify-between shrink-0 bg-black/90 backdrop-blur-md z-10 select-none">
      <button
        type="button"
        @click="emit('back')"
        class="p-2 -ml-2 rounded-full text-gray-400 hover:text-white transition-colors cursor-pointer"
        title="Volver al chat"
      >
        <ChevronLeft class="w-6 h-6" />
      </button>

      <h2 class="text-base sm:text-lg font-semibold text-white tracking-wide">
        Perfil de comunidad
      </h2>

      <!-- Spacer for centering -->
      <div class="w-8" />
    </header>

    <!-- Scrollable Profile Body -->
    <div class="flex-1 overflow-y-auto no-scrollbar p-4 sm:p-6 space-y-6 select-text">
      <!-- Banner and Avatar container -->
      <div class="relative select-none">
        <!-- Community Banner Art -->
        <div class="relative w-full h-36 sm:h-44 rounded-2xl overflow-hidden bg-gradient-to-r from-[#4d0b16] via-[#79141B] to-[#1a0509] border border-[#2a1117] flex items-center justify-end px-6 shadow-lg">
          <!-- Ambient Monster Shadow Silhouette on left -->
          <div class="absolute inset-y-0 left-0 w-1/2 bg-gradient-to-r from-black/80 via-black/40 to-transparent flex items-center pl-6">
            <div class="w-20 h-20 rounded-full bg-red-950/40 blur-xl absolute" />
          </div>

          <!-- Horror Typographic Title "SPECIMEN ZERO" -->
          <div class="relative z-10 text-right">
            <span class="block text-2xl sm:text-3xl font-black tracking-widest text-red-100 uppercase font-serif drop-shadow-[0_2px_12px_rgba(240,37,76,0.6)]">
              Specimen
            </span>
            <span class="block text-xl sm:text-2xl font-black tracking-[0.25em] text-red-500 uppercase -mt-1 drop-shadow-[0_2px_10px_rgba(0,0,0,0.9)]">
              Zero
            </span>
          </div>
        </div>

        <!-- Overlapping Avatar -->
        <div class="relative -mt-10 sm:-mt-12 ml-4 flex items-end justify-between pr-4 z-20">
          <div class="w-20 h-20 sm:w-24 sm:h-24 rounded-full border-4 border-black bg-[#20080d] overflow-hidden flex items-center justify-center shadow-2xl relative">
            <!-- Horror creature stylized avatar -->
            <div class="w-full h-full bg-gradient-to-b from-[#6b1422] to-[#120306] flex items-center justify-center relative">
              <span class="text-lg sm:text-xl font-black text-red-200 tracking-wider">SZ</span>
              <div class="absolute inset-0 bg-radial from-red-500/20 via-transparent to-black/70 pointer-events-none" />
            </div>
          </div>
        </div>
      </div>

      <!-- Identity & Stats Section -->
      <div class="space-y-1 px-1">
        <!-- Title and Verified Badge -->
        <div class="flex items-center gap-1.5">
          <h3 class="text-xl sm:text-2xl font-bold text-white tracking-tight">
            {{ community.name }}
          </h3>
          <BadgeCheck class="w-5 h-5 text-[#f0254c] fill-[#f0254c]/20" />
        </div>

        <!-- Handle -->
        <p class="text-sm font-medium text-[#f0254c]">
          {{ community.handle || '@specimen-zero' }}
        </p>

        <!-- Stats details -->
        <p class="text-xs sm:text-sm text-gray-400 pt-0.5">
          {{ community.membersCount }} · {{ community.language || 'Español' }} · {{ community.flag || '🇨🇴' }} {{ community.country || 'Colombia' }}
        </p>
      </div>

      <!-- Related Game Card -->
      <div class="p-3.5 rounded-2xl bg-[#14151f] border border-[#232535] flex items-center gap-3.5 select-none">
        <div class="w-11 h-11 rounded-xl bg-[#79141B]/40 border border-[#f0254c]/30 flex items-center justify-center text-[#f0254c] shrink-0">
          <Gamepad2 class="w-5 h-5" />
        </div>
        <div class="min-w-0 flex-1">
          <h4 class="text-sm font-bold text-[#f0254c] truncate">
            {{ community.gameSubtitle || community.name }}
          </h4>
          <p class="text-xs text-gray-400 mt-0.5 truncate">
            Juego relacionado
          </p>
        </div>
      </div>

      <!-- Action Buttons: Chat & Salir -->
      <div class="flex items-center gap-3 select-none">
        <button
          type="button"
          @click="emit('open-chat')"
          class="flex-1 py-3 px-4 rounded-2xl bg-[#f0254c] hover:bg-[#d9193f] text-white font-semibold text-sm flex items-center justify-center gap-2 shadow-lg shadow-[#f0254c]/20 transition-all active:scale-[0.99] cursor-pointer"
        >
          <MessageSquare class="w-4 h-4 fill-current" />
          <span>Chat</span>
        </button>

        <button
          type="button"
          @click="emit('leave')"
          class="flex-1 py-3 px-4 rounded-2xl border border-[#262838] bg-transparent hover:bg-white/5 text-gray-300 font-semibold text-sm text-center transition-colors cursor-pointer"
        >
          Salir
        </button>
      </div>

      <!-- Acerca de -->
      <div class="space-y-1.5 px-1">
        <h4 class="text-base font-bold text-white tracking-tight">
          Acerca de
        </h4>
        <p class="text-sm text-gray-300 leading-relaxed break-words">
          {{ community.description || 'aquí encontraras personas de tu mismo nicho' }}
        </p>
      </div>

      <!-- Reglas -->
      <div class="space-y-3 px-1">
        <h4 class="text-base font-bold text-white tracking-tight">
          Reglas
        </h4>
        <p class="text-sm text-gray-300 leading-relaxed break-words">
          {{ community.rules || '1. no insulstar' }}
        </p>

        <!-- Tags / Topics -->
        <div class="flex items-center gap-2 pt-1">
          <span
            v-for="tag in (community.tags || ['terror', 'survival'])"
            :key="tag"
            class="px-3.5 py-1 rounded-full text-xs font-medium text-gray-300 bg-[#1e202d] border border-[#2a2d3e]"
          >
            {{ tag }}
          </span>
        </div>
      </div>

      <!-- Canales Section -->
      <div class="space-y-2.5 px-1 pt-1">
        <h4 class="text-base font-bold text-white tracking-tight">
          Canales
        </h4>

        <div class="space-y-2 select-none">
          <div
            v-for="channel in community.channels"
            :key="channel.id"
            @click="emit('open-chat', channel.id)"
            class="p-3.5 rounded-2xl bg-[#14151f] hover:bg-[#1a1c29] border border-[#232535] transition-all flex items-center gap-3.5 cursor-pointer group"
          >
            <!-- Channel Icon -->
            <component
              :is="getChannelIcon(channel.id)"
              class="w-5 h-5 text-gray-400 group-hover:text-white transition-colors shrink-0"
            />

            <!-- Channel Details -->
            <div class="min-w-0 flex-1">
              <h5 class="text-sm font-semibold text-white truncate group-hover:text-red-200 transition-colors">
                {{ channel.name }}
              </h5>
              <p class="text-xs text-gray-400 truncate mt-0.5">
                {{ channel.subtitle || (channel.id === 'anuncios' ? 'Publican moderadores' : 'Participación de miembros') }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

