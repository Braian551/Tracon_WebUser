<script setup lang="ts">
import { ref } from 'vue'
import { Search } from 'lucide-vue-next'
import Avatar from '../common/Avatar.vue'
import ChatUtilityBar from './ChatUtilityBar.vue'
import CommunityThreeUsersIcon from '../common/CommunityThreeUsersIcon.vue'
import ChatBubbleSolidIcon from '../common/ChatBubbleSolidIcon.vue'
import NewChatModal from './NewChatModal.vue'
import type { Conversation } from '../../types'

interface Props {
  conversations: Conversation[]
  selectedId?: string
  activeTab?: 'chats' | 'comunidades'
  isNotificationsActive?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  activeTab: 'chats',
  isNotificationsActive: false,
})

const emit = defineEmits<{
  (e: 'select-conversation', id: string): void
  (e: 'new-chat'): void
  (e: 'change-tab', tab: 'chats' | 'comunidades'): void
  (e: 'click-notifications'): void
}>()

const searchQuery = ref('')
const isNewChatModalOpen = ref(false)

const filteredConversations = () => {
  if (!searchQuery.value.trim()) return props.conversations
  const q = searchQuery.value.toLowerCase()
  return props.conversations.filter(c =>
    c.name.toLowerCase().includes(q) || c.lastMessage.toLowerCase().includes(q)
  )
}
</script>

<template>
  <div class="flex flex-col h-[calc(100vh-2rem)] lg:h-[calc(100vh-2.5rem)] sticky top-4 lg:top-5 rounded-2xl lg:rounded-3xl border border-[#1f212a] bg-black overflow-hidden w-full shadow-lg select-none">
    <!-- Header with Chats title and the 3 Action Buttons moved here -->
    <div class="flex items-center justify-between px-4 sm:px-5 pt-4 pb-3">
      <h2 class="text-xl font-bold text-white tracking-tight">
        Chats
      </h2>

      <!-- The 3 Action Buttons: Radar, Notifications, Compose -->
      <ChatUtilityBar
        :is-notifications-active="isNotificationsActive"
        @click-radar="() => {}"
        @click-notifications="emit('click-notifications')"
        @click-compose="isNewChatModalOpen = true"
      />
    </div>

    <!-- New Chat / Create Group Modal matching Design -->
    <NewChatModal
      :is-open="isNewChatModalOpen"
      @close="isNewChatModalOpen = false"
      @new-direct-chat="emit('new-chat')"
      @new-group="() => {}"
    />

    <!-- Sub-tabs: Chats vs Comunidades with icons -->
    <div class="relative flex border-b border-[#15161e] px-2">
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

    <!-- Search input -->
    <div class="p-3">
      <div class="relative flex items-center w-full rounded-full bg-[#121319] hover:bg-[#161720] focus-within:bg-[#181923] transition-colors">
        <div class="pl-3.5 pr-2 text-gray-500 flex items-center">
          <Search class="w-4 h-4" />
        </div>
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Buscar conversaciones"
          class="w-full py-2 pr-3 bg-transparent text-sm text-gray-200 placeholder:text-gray-500 focus:outline-none"
        />
      </div>
    </div>

    <!-- Conversations list -->
    <div class="flex-1 overflow-y-auto divide-y divide-[#15161e]/40">
      <div
        v-for="conv in filteredConversations()"
        :key="conv.id"
        @click="emit('select-conversation', conv.id)"
        class="relative flex items-center gap-3 px-3 py-3 transition-colors cursor-pointer select-none group"
        :class="[
          selectedId === conv.id
            ? 'bg-[#12131a]'
            : 'hover:bg-white/[0.04]',
        ]"
      >
        <!-- Red vertical indicator on right for active conversation (as seen in screenshot) -->
        <div
          v-if="selectedId === conv.id"
          class="absolute right-0 top-0 bottom-0 w-[3px] bg-[#f0254c] rounded-l"
        />

        <!-- Avatar -->
        <Avatar
          size="md"
          :is-tracon-official="conv.isTraconOfficial"
        />

        <!-- Info -->
        <div class="flex-1 min-w-0">
          <div class="flex items-center justify-between gap-1">
            <h3 class="text-sm font-semibold text-white truncate">
              {{ conv.name }}
            </h3>
            <span class="text-xs text-gray-500 shrink-0">
              {{ conv.timeAgo }}
            </span>
          </div>

          <p class="text-xs text-gray-400 truncate mt-0.5 leading-relaxed">
            {{ conv.lastMessage }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

