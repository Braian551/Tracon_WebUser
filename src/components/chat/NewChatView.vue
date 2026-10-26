<script setup lang="ts">
import { ref, computed } from 'vue'
import { ChevronLeft, ChevronRight, Search, User } from 'lucide-vue-next'

export interface FriendItem {
  id: string
  name: string
  handle: string
  conversationId?: string
}

const emit = defineEmits<{
  (e: 'back'): void
  (e: 'select-friend', friend: FriendItem): void
}>()

const searchQuery = ref('')

const friends = ref<FriendItem[]>([
  {
    id: 'f1',
    name: 'Braian Andrés Oquendo Duran...',
    handle: '@braianoquendurango',
    conversationId: 'braian-andres',
  },
  {
    id: 'f2',
    name: 'Héctor Maya',
    handle: '@hmaya10',
    conversationId: 'hector-maya',
  },
  {
    id: 'f3',
    name: 'Luis',
    handle: '@luis8288gg',
    conversationId: 'luis-chat',
  },
  {
    id: 'f4',
    name: 'Tracon',
    handle: '@tracon',
    conversationId: 'tracon',
  },
])

const filteredFriends = computed(() => {
  if (!searchQuery.value.trim()) return friends.value
  const q = searchQuery.value.toLowerCase()
  return friends.value.filter(
    f => f.name.toLowerCase().includes(q) || f.handle.toLowerCase().includes(q)
  )
})
</script>

<template>
  <div class="flex flex-col h-[calc(100vh-2rem)] lg:h-[calc(100vh-2.5rem)] sticky top-4 lg:top-5 rounded-2xl lg:rounded-3xl border border-[#1f212a] bg-black overflow-hidden w-full shadow-lg select-none">
    <!-- Top Header with back button and centered title -->
    <div class="h-16 px-4 sm:px-5 border-b border-[#1f212a] flex items-center justify-between shrink-0 bg-black/90 backdrop-blur-md">
      <button
        type="button"
        @click="emit('back')"
        class="p-2 -ml-2 rounded-full text-gray-400 hover:text-white transition-colors cursor-pointer"
        title="Volver a chats"
      >
        <ChevronLeft class="w-6 h-6" />
      </button>

      <h2 class="text-base sm:text-lg font-semibold text-white tracking-wide">
        Nuevo chat
      </h2>

      <!-- Spacer to balance center title -->
      <div class="w-8" />
    </div>

    <!-- Search Input for Friends -->
    <div class="px-4 pt-3 pb-2 shrink-0">
      <div class="relative flex items-center w-full rounded-2xl bg-[#14151f] border border-[#232535] px-4 py-2.5 focus-within:border-[#f0254c] transition-colors">
        <Search class="w-4.5 h-4.5 text-gray-400 mr-2.5 shrink-0" />
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Buscar amistades"
          class="w-full bg-transparent text-sm text-gray-100 placeholder:text-gray-500 focus:outline-none"
        />
      </div>
    </div>

    <!-- Friends List -->
    <div class="flex-1 overflow-y-auto no-scrollbar px-4 py-2 space-y-2.5">
      <div
        v-for="friend in filteredFriends"
        :key="friend.id"
        @click="emit('select-friend', friend)"
        class="p-3.5 rounded-2xl bg-[#14151f] hover:bg-[#1b1d2a] border border-[#232535]/70 hover:border-[#32364c] transition-all flex items-center justify-between cursor-pointer group active:scale-[0.99]"
      >
        <div class="flex items-center min-w-0 flex-1">
          <!-- Circular avatar with burgundy background and user silhouette icon -->
          <div class="w-11 h-11 rounded-full bg-[#3d1219] border border-[#79141b]/60 flex items-center justify-center shrink-0">
            <User class="w-5 h-5 text-gray-200" />
          </div>

          <div class="ml-3.5 min-w-0 flex-1">
            <h4 class="text-[15px] font-semibold text-white truncate group-hover:text-white">
              {{ friend.name }}
            </h4>
            <p class="text-xs text-gray-400 truncate mt-0.5">
              {{ friend.handle }}
            </p>
          </div>
        </div>

        <!-- Chevron right icon -->
        <ChevronRight class="w-5 h-5 text-gray-500 group-hover:text-gray-300 transition-colors shrink-0 ml-2" />
      </div>

      <!-- Empty state if search finds no matches -->
      <div
        v-if="filteredFriends.length === 0"
        class="text-center py-10 text-gray-500 text-sm"
      >
        No se encontraron amistades.
      </div>
    </div>
  </div>
</template>

