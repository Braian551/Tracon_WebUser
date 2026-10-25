<script setup lang="ts">
import type { SuggestedCommunity } from '../../types'

interface Props {
  communities?: SuggestedCommunity[]
  title?: string
  showActionLink?: boolean
}

withDefaults(defineProps<Props>(), {
  communities: () => [],
  title: 'Comunidades sugeridas',
  showActionLink: true,
})

const emit = defineEmits<{
  (e: 'select-community', community: SuggestedCommunity): void
  (e: 'request-game'): void
}>()
</script>

<template>
  <div
    class="p-4 rounded-2xl border border-[#1f212a] bg-black shadow-lg transition-colors select-none"
  >
    <!-- Title -->
    <h3 class="text-base font-bold text-white tracking-wide mb-4">
      {{ title }}
    </h3>

    <!-- Communities List -->
    <div class="space-y-4">
      <div
        v-for="community in communities"
        :key="community.id"
        @click="emit('select-community', community)"
        class="flex items-center gap-3 group cursor-pointer"
      >
        <!-- Community Avatar circle -->
        <div
          class="w-10 h-10 rounded-full shrink-0 flex items-center justify-center border border-[#2b2e3c] transition-transform group-hover:scale-105"
          :style="{ backgroundColor: community.avatarBg || '#1e202b' }"
        >
          <div class="w-4 h-4 rounded-full bg-white/10" />
        </div>

        <!-- Info -->
        <div class="flex-1 min-w-0">
          <h4
            class="text-sm font-bold text-gray-100 group-hover:text-white truncate transition-colors"
          >
            {{ community.name }}
          </h4>
          <p class="text-xs text-gray-400 truncate">
            {{ community.membersCount || community.subtitle }}
          </p>
        </div>
      </div>
    </div>

    <!-- Action link at bottom -->
    <div v-if="showActionLink" class="mt-5 pt-3 border-t border-[#1a1b24]">
      <button
        type="button"
        @click="emit('request-game')"
        class="text-xs font-semibold text-[#f0254c] hover:text-[#ff3860] hover:underline transition-colors block text-left cursor-pointer"
      >
        Solicitar juego al catálogo
      </button>
    </div>
  </div>
</template>

