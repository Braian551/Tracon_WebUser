<script setup lang="ts">
import { ref, computed } from 'vue'
import { ChevronLeft, ChevronRight, Search, User, Check } from 'lucide-vue-next'
import type { FriendItem } from './NewChatView.vue'

const emit = defineEmits<{
  (e: 'back'): void
  (e: 'create-group', payload: { name: string; members: FriendItem[] }): void
}>()

const groupName = ref('')
const searchQuery = ref('')
const selectedFriendIds = ref<string[]>(['f1', 'f2']) // Pre-select 2 like in the reference image

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

const isSelected = (id: string) => selectedFriendIds.value.includes(id)

const toggleFriend = (id: string) => {
  if (isSelected(id)) {
    selectedFriendIds.value = selectedFriendIds.value.filter(item => item !== id)
  } else {
    selectedFriendIds.value.push(id)
  }
}

const filteredFriends = computed(() => {
  if (!searchQuery.value.trim()) return friends.value
  const q = searchQuery.value.toLowerCase()
  return friends.value.filter(
    f => f.name.toLowerCase().includes(q) || f.handle.toLowerCase().includes(q)
  )
})

const handleCreate = () => {
  if (!groupName.value.trim() || selectedFriendIds.value.length === 0) return
  const members = friends.value.filter(f => selectedFriendIds.value.includes(f.id))
  emit('create-group', {
    name: groupName.value.trim(),
    members,
  })
}
</script>

<template>
  <div class="flex flex-col h-[calc(100vh-2rem)] lg:h-[calc(100vh-2.5rem)] sticky top-4 lg:top-5 rounded-2xl lg:rounded-3xl border border-[#1f212a] bg-black overflow-hidden w-full shadow-lg select-none">
    <!-- Top Header with back button, centered title and Crear action button -->
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
        Crear grupo
      </h2>

      <!-- Crear action button -->
      <button
        type="button"
        :disabled="!groupName.trim() || selectedFriendIds.length === 0"
        @click="handleCreate"
        class="text-sm font-semibold text-[#f0254c] hover:text-[#ff3860] disabled:opacity-30 disabled:cursor-not-allowed transition-colors cursor-pointer"
      >
        Crear
      </button>
    </div>

    <!-- Group Name Input Box (0/160) -->
    <div class="px-4 pt-3 pb-1 shrink-0">
      <div class="bg-[#14151f] border border-[#232535] rounded-2xl p-3.5 focus-within:border-[#f0254c] transition-colors">
        <input
          v-model="groupName"
          maxlength="160"
          type="text"
          placeholder="Nombre del grupo"
          class="w-full bg-transparent text-sm text-gray-100 placeholder:text-gray-500 focus:outline-none"
        />
      </div>
      <div class="text-right text-[11px] text-gray-500 mt-1 mr-1">
        {{ groupName.length }}/160
      </div>
    </div>

    <!-- Search Input for Friends -->
    <div class="px-4 pb-2 shrink-0">
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

    <!-- Selection Count Label -->
    <div class="px-5 py-1 text-xs text-gray-400 font-medium shrink-0">
      {{ selectedFriendIds.length === 1 ? '1 persona seleccionada' : `${selectedFriendIds.length} personas seleccionadas` }}
    </div>

    <!-- Friends Selection List -->
    <div class="flex-1 overflow-y-auto no-scrollbar px-4 py-1 space-y-2.5">
      <div
        v-for="friend in filteredFriends"
        :key="friend.id"
        @click="toggleFriend(friend.id)"
        class="p-3.5 rounded-2xl transition-all flex items-center justify-between cursor-pointer group active:scale-[0.99]"
        :class="[
          isSelected(friend.id)
            ? 'bg-[#79141B] border border-[#9b1d26] shadow-sm'
            : 'bg-[#14151f] hover:bg-[#1b1d2a] border border-[#232535]/70 hover:border-[#32364c]'
        ]"
      >
        <div class="flex items-center min-w-0 flex-1">
          <!-- User Avatar -->
          <div
            class="w-11 h-11 rounded-full flex items-center justify-center shrink-0"
            :class="isSelected(friend.id) ? 'bg-[#5a0f14] border border-white/20' : 'bg-[#3d1219] border border-[#79141b]/60'"
          >
            <User class="w-5 h-5 text-gray-200" />
          </div>

          <div class="ml-3.5 min-w-0 flex-1">
            <h4 class="text-[15px] font-semibold text-white truncate">
              {{ friend.name }}
            </h4>
            <p
              class="text-xs truncate mt-0.5"
              :class="isSelected(friend.id) ? 'text-gray-200' : 'text-gray-400'"
            >
              {{ friend.handle }}
            </p>
          </div>
        </div>

        <!-- Right indicator: CheckCircle if selected, ChevronRight if unselected -->
        <div
          v-if="isSelected(friend.id)"
          class="w-6 h-6 rounded-full bg-[#f0254c] flex items-center justify-center text-white shrink-0 ml-2 shadow-sm"
        >
          <Check class="w-3.5 h-3.5 stroke-[3]" />
        </div>
        <ChevronRight
          v-else
          class="w-5 h-5 text-gray-500 group-hover:text-gray-300 transition-colors shrink-0 ml-2"
        />
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
