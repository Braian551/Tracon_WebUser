<script setup lang="ts">
import { ref } from 'vue'
import SearchInput from '../common/SearchInput.vue'
import type { SuggestedCommunity } from '../../types'

interface Props {
  communities: SuggestedCommunity[]
}

defineProps<Props>()

const searchQuery = ref('')
</script>

<template>
  <aside class="hidden lg:flex flex-col w-[310px] xl:w-[340px] sticky top-4 lg:top-5 gap-4 select-none">
    <!-- Top Search Bar -->
    <div>
      <SearchInput
        v-model="searchQuery"
        placeholder="Buscar"
      />
    </div>

    <!-- Suggested Communities Card -->
    <div
      class="p-4 rounded-2xl border border-[#1f212a] bg-[#101117] shadow-lg transition-colors"
    >
      <h3 class="text-base font-bold text-white tracking-wide mb-4">
        Comunidades sugeridas
      </h3>

      <div class="space-y-4">
        <div
          v-for="community in communities"
          :key="community.id"
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
      <div class="mt-5 pt-3 border-t border-[#1a1b24]">
        <a
          href="#"
          class="text-xs font-semibold text-[#f0254c] hover:text-[#ff3860] hover:underline transition-colors block"
        >
          Solicitar juego al catálogo
        </a>
      </div>
    </div>

    <!-- Small footer text -->
    <footer class="px-2 text-xs text-gray-400 font-medium tracking-wide">
      Tracon · Comunidad de videojuegos
    </footer>
  </aside>
</template>

