<script setup lang="ts">
import { ref } from 'vue'
import SearchInput from '../common/SearchInput.vue'
import SuggestedCommunitiesCard from '../communities/SuggestedCommunitiesCard.vue'
import type { SuggestedCommunity } from '../../types'

interface Props {
  communities: SuggestedCommunity[]
}

defineProps<Props>()

const emit = defineEmits<{
  (e: 'select-community', community: SuggestedCommunity): void
  (e: 'request-game'): void
}>()

const searchQuery = ref('')
</script>

<template>
  <aside class="hidden lg:flex flex-col w-[300px] xl:w-[340px] sticky top-4 lg:top-5 gap-4 select-none shrink-0">
    <!-- Top Search Bar -->
    <div>
      <SearchInput
        v-model="searchQuery"
        placeholder="Buscar"
      />
    </div>

    <!-- Suggested Communities Reusable Card -->
    <SuggestedCommunitiesCard
      :communities="communities"
      @select-community="(comm) => emit('select-community', comm)"
      @request-game="emit('request-game')"
    />

    <!-- Small footer text -->
    <footer class="px-2 text-xs text-gray-400 font-medium tracking-wide">
      Tracon · Comunidad de videojuegos
    </footer>
  </aside>
</template>

