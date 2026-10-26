<script setup lang="ts">
import { ref } from 'vue'
import ChatList from './ChatList.vue'
import NewChatView, { type FriendItem } from './NewChatView.vue'
import CreateGroupView from './CreateGroupView.vue'
import ChatEmptyState from './ChatEmptyState.vue'
import ChatConversationView from './ChatConversationView.vue'
import NotificationsView from '../notifications/NotificationsView.vue'
import type { Conversation } from '../../types'

interface Props {
  conversations: Conversation[]
  activeTab?: 'chats' | 'comunidades'
}

const props = withDefaults(defineProps<Props>(), {
  activeTab: 'chats',
})

const emit = defineEmits<{
  (e: 'change-tab', tab: 'chats' | 'comunidades'): void
}>()

const conversationsList = ref<Conversation[]>([...props.conversations])
// Default to null or initial selection
const selectedConversationId = ref<string | null>('hector-maya')
const showMobileChat = ref(false)
const showNotifications = ref(false)
const activeLeftView = ref<'list' | 'new-chat' | 'create-group'>('list')

const selectedConversation = () => {
  return conversationsList.value.find(c => c.id === selectedConversationId.value)
}

const handleSelect = (id: string) => {
  selectedConversationId.value = id
  showNotifications.value = false
  showMobileChat.value = true
}

const handleBack = () => {
  showMobileChat.value = false
  selectedConversationId.value = null
}

const handleToggleNotifications = () => {
  showNotifications.value = !showNotifications.value
  if (showNotifications.value) {
    showMobileChat.value = true
  }
}

const handleBackFromNotifications = () => {
  showNotifications.value = false
  showMobileChat.value = false
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
  activeLeftView.value = 'new-chat'
}

const handleSelectFriend = (friend: FriendItem) => {
  activeLeftView.value = 'list'
  let conv = conversationsList.value.find(c =>
    (friend.conversationId && c.id === friend.conversationId) ||
    c.name.toLowerCase() === friend.name.toLowerCase() ||
    (c.handle && friend.handle && c.handle.toLowerCase() === friend.handle.replace('@', '').toLowerCase())
  )

  if (!conv) {
    const newConv: Conversation = {
      id: friend.conversationId || `conv-${Date.now()}`,
      name: friend.name,
      handle: friend.handle.replace('@', ''),
      lastMessage: 'Inicia la conversación',
      timeAgo: 'Ahora',
      messages: [],
    }
    conversationsList.value.unshift(newConv)
    selectedConversationId.value = newConv.id
  } else {
    selectedConversationId.value = conv.id
  }

  showNotifications.value = false
  showMobileChat.value = true
}

const handleCreateGroup = ({ name, members }: { name: string; members: FriendItem[] }) => {
  activeLeftView.value = 'list'
  const newGroupId = `group-${Date.now()}`
  const newGroup: Conversation = {
    id: newGroupId,
    name,
    handle: `${members.length} miembros`,
    isGroup: true,
    lastMessage: 'Grupo creado',
    timeAgo: 'Ahora',
    messages: [
      {
        id: `gm-1`,
        text: `Creaste el grupo "${name}" con ${members.map(m => m.name.split(' ')[0]).join(', ')}.`,
        timestamp: 'Ahora',
        isMine: true,
        status: 'sent',
      }
    ],
  }
  conversationsList.value.unshift(newGroup)
  selectedConversationId.value = newGroupId
  showNotifications.value = false
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
  <div class="flex-1 flex gap-3 sm:gap-4 lg:gap-5 min-w-0">
    <!-- Left Column: Chats List, New Chat View or Create Group View (40%) -->
    <div
      class="w-full md:flex-[2] min-w-0 relative"
      :class="showMobileChat ? 'hidden md:block' : 'block'"
    >
      <Transition name="chat-view-slide" mode="out-in">
        <NewChatView
          v-if="activeLeftView === 'new-chat'"
          key="new-chat-view"
          @back="activeLeftView = 'list'"
          @select-friend="handleSelectFriend"
        />

        <CreateGroupView
          v-else-if="activeLeftView === 'create-group'"
          key="create-group-view"
          @back="activeLeftView = 'list'"
          @create-group="handleCreateGroup"
        />

        <ChatList
          v-else
          key="chat-list-view"
          :conversations="conversationsList"
          :selected-id="selectedConversationId || undefined"
          :active-tab="activeTab"
          :is-notifications-active="showNotifications"
          @select-conversation="handleSelect"
          @new-chat="handleNewMessage"
          @new-group="activeLeftView = 'create-group'"
          @change-tab="(tab) => emit('change-tab', tab)"
          @click-notifications="handleToggleNotifications"
        />
      </Transition>
    </div>

    <!-- Right Column: Conversation, Notifications or Minimalist Empty State (60%) -->
    <div
      class="w-full md:flex-[3] min-w-0 h-[calc(100vh-2rem)] lg:h-[calc(100vh-2.5rem)] sticky top-4 lg:top-5 relative overflow-hidden flex flex-col"
      :class="!showMobileChat ? 'hidden md:flex' : 'flex'"
    >
      <Transition name="chat-fade">
        <NotificationsView
          v-if="showNotifications"
          key="notifications-view"
          @back="handleBackFromNotifications"
        />

        <ChatConversationView
          v-else-if="selectedConversation()"
          :key="selectedConversation()!.id"
          :conversation="selectedConversation()!"
          @back="handleBack"
          @send-message="handleSendMessage"
          @clear-chat="handleClearChat"
          @delete-chat="handleDeleteChat"
          @leave-group="handleDeleteChat"
        />

        <ChatEmptyState
          v-else
          key="empty-state"
          @new-message="handleNewMessage"
          @click-radar="() => {}"
          @click-notifications="handleToggleNotifications"
        />
      </Transition>
    </div>
  </div>
</template>

<style scoped>
.chat-fade-enter-active,
.chat-fade-leave-active,
.chat-view-slide-enter-active,
.chat-view-slide-leave-active {
  transition: opacity 240ms cubic-bezier(0.23, 1, 0.32, 1), transform 240ms cubic-bezier(0.23, 1, 0.32, 1);
  will-change: opacity, transform;
}

.chat-fade-leave-active,
.chat-view-slide-leave-active {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 0;
}

.chat-fade-enter-active,
.chat-view-slide-enter-active {
  z-index: 10;
}

.chat-fade-enter-from,
.chat-view-slide-enter-from {
  opacity: 0;
  transform: translateY(8px) scale(0.995);
}

.chat-fade-leave-to,
.chat-view-slide-leave-to {
  opacity: 0;
  transform: translateY(-8px) scale(0.995);
}

@media (prefers-reduced-motion: reduce) {
  .chat-fade-enter-active,
  .chat-fade-leave-active,
  .chat-view-slide-enter-active,
  .chat-view-slide-leave-active {
    transition: opacity 150ms ease;
    transform: none;
  }
}
</style>

