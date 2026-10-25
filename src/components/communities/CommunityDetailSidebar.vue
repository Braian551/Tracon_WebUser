<script setup lang="ts">
import { ref } from 'vue'
import type { CommunityDetail } from '../../types'

interface Props {
  community: CommunityDetail
}

const props = defineProps<Props>()
const activeChannel = ref(props.community.activeChannel || 'general')
</script>

<template>
  <aside class="hidden lg:flex flex-col w-[300px] xl:w-[340px] sticky top-4 lg:top-5 gap-4 select-none shrink-0">
    <!-- Acerca de la comunidad Card -->
    <div class="p-5 rounded-2xl border border-[#1f212a] bg-[#101117] shadow-lg select-none transition-colors">
      <h3 class="text-base font-bold text-white tracking-wide mb-1">
        Acerca de la comunidad
      </h3>

      <p class="text-xs text-gray-400 mb-4">
        {{ community.gameSubtitle }} · {{ community.membersCount }}
      </p>

      <div class="space-y-2.5">
        <div
          v-for="ch in community.channels"
          :key="ch.id"
          @click="activeChannel = ch.id"
          class="text-sm cursor-pointer transition-colors py-0.5"
          :class="activeChannel === ch.id ? 'font-bold text-white' : 'font-normal text-gray-400 hover:text-gray-200'"
        >
          {{ ch.name }}
        </div>
      </div>
    </div>
  </aside>
</template>

