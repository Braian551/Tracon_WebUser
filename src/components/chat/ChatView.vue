<script setup lang="ts">
import { ref } from 'vue'
import ChatList from './ChatList.vue'
import ChatEmptyState from './ChatEmptyState.vue'
import ChatConversationView from './ChatConversationView.vue'
import type { Conversation } from '../../types'

interface Props {
  conversations: Conversation[]
}

const props = defineProps<Props>()

const conversationsList = ref<Conversation[]>([...props.conversations])
// Default to null or initial selection
const selectedConversationId = ref<string | null>('hector-maya')
const showMobileChat = ref(false)

const selectedConversation = () => {
  return conversationsList.value.find(c => c.id === selectedConversationId.value)
}

const handleSelect = (id: string) => {
  selectedConversationId.value = id
  showMobileChat.value = true
}

const handleBack = () => {
  showMobileChat.value = false
  selectedConversationId.value = null
}

const handleSendMessage = (text: string) => {
  const conv = selectedConversation()
  if (conv) {
    conv.messages.push({
      id: `msg-${Date.now()}`,
      text,
      timestamp: 'Ahora',
      isMine: true,
      status: 'sent',
    })
    conv.lastMessage = text
    conv.timeAgo = 'Ahora'
  }
}

const handleNewMessage = () => {
  // Select first or prompt new conversation
  selectedConversationId.value = 'hector-maya'
  showMobileChat.value = true
}

const handleClearChat = () => {
  const conv = selectedConversation()
  if (conv) {
    conv.messages = []
    conv.lastMessage = 'Chat vaciado'
  }
}

const handleDeleteChat = () => {
  const currentId = selectedConversationId.value
  if (currentId) {
    conversationsList.value = conversationsList.value.filter(c => c.id !== currentId)
    selectedConversationId.value = null
    showMobileChat.value = false
  }
}
</script>

<template>
  <div class="flex-1 flex gap-4 lg:gap-5 min-w-0">
    <!-- Left Column: Chats List (hidden on mobile if chat is active) -->
    <div
      class="w-full md:w-auto shrink-0"
      :class="showMobileChat ? 'hidden md:block' : 'block'"
    >
      <ChatList
        :conversations="conversationsList"
        :selected-id="selectedConversationId || undefined"
        @select-conversation="handleSelect"
        @new-chat="handleNewMessage"
      />
    </div>

    <!-- Right Column: Conversation or Minimalist Empty State (floating card) -->
    <div
      class="w-full md:w-[420px] lg:w-[460px] xl:w-[480px] shrink-0 flex flex-col min-w-0"
      :class="!showMobileChat ? 'hidden md:flex' : 'flex'"
    >
      <template v-if="selectedConversation()">
        <ChatConversationView
          :conversation="selectedConversation()!"
          @back="handleBack"
          @send-message="handleSendMessage"
          @clear-chat="handleClearChat"
          @delete-chat="handleDeleteChat"
        />
      </template>

      <template v-else>
        <ChatEmptyState
          @new-message="handleNewMessage"
          @click-radar="() => {}"
          @click-notifications="() => {}"
        />
      </template>
    </div>
  </div>
</template>

