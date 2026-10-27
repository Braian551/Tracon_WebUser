<script setup lang="ts">
import { ref, computed } from 'vue'
import LeftSidebar from './components/layout/LeftSidebar.vue'
import MainFeed from './components/layout/MainFeed.vue'
import RightSidebar from './components/layout/RightSidebar.vue'
import ChatView from './components/chat/ChatView.vue'
import CommunitiesFeed from './components/communities/CommunitiesFeed.vue'
import CommunityChatRoom from './components/communities/CommunityChatRoom.vue'
import CommunityDetailSidebar from './components/communities/CommunityDetailSidebar.vue'
import NotificationsView from './components/notifications/NotificationsView.vue'
import CreateCommunityView from './components/communities/CreateCommunityView.vue'
import CreatePostView from './components/create/CreatePostView.vue'
import RequestGameModal from './components/communities/RequestGameModal.vue'
import {
  navItemsData,
  initialPostsData,
  suggestedCommunitiesData,
  conversationsData,
  myCommunitiesData,
  suggestedFeedCommunitiesData,
  communityDetailsData,
} from './data/mockData'
import type { CommunityFeedItem, Post } from './types'
import { Zap, MessageCircle, PlusCircle, PlayCircle, User } from 'lucide-vue-next'

const navItems = ref(navItemsData)
const initialPosts = ref(initialPostsData)
const suggestedCommunities = ref(suggestedCommunitiesData)
const myCommunities = ref(myCommunitiesData)
const suggestedFeedCommunities = ref(suggestedFeedCommunitiesData)
const conversations = ref(conversationsData)
const activeNavId = ref('inicio')
const chatSubTab = ref<'chats' | 'comunidades'>('chats')
const selectedCommunityId = ref<string | null>(null)
const showCommunitiesNotifications = ref(false)
const isCreatingCommunity = ref(false)
const isGlobalRequestGameOpen = ref(false)

const activeCommunityDetail = computed(() => {
  if (!selectedCommunityId.value) return null
  return (
    communityDetailsData[selectedCommunityId.value] ||
    communityDetailsData['specimen-zero']
  )
})

const handleSelectCommunity = (comm: CommunityFeedItem) => {
  selectedCommunityId.value = comm.id
  showCommunitiesNotifications.value = false
  isCreatingCommunity.value = false
}

const handleBackFromCommunity = () => {
  selectedCommunityId.value = null
  showCommunitiesNotifications.value = false
  isCreatingCommunity.value = false
}

const handleCommunityCreated = (newComm: CommunityFeedItem) => {
  myCommunities.value.unshift(newComm)
  isCreatingCommunity.value = false
}

const handleNavigate = (id: string) => {
  activeNavId.value = id
  isCreatingCommunity.value = false
  if (id !== 'chats') {
    selectedCommunityId.value = null
    showCommunitiesNotifications.value = false
  }
}

const handlePostPublished = (newPost: Post) => {
  initialPosts.value.unshift(newPost)
  activeNavId.value = 'inicio'
}
</script>

<template>
  <div class="min-h-screen bg-black text-[#f3f4f6] font-sans antialiased selection:bg-[#f0254c] selection:text-white px-2 sm:px-3 lg:px-4 py-2 sm:py-3 lg:py-4 flex justify-center">
    <!-- Floating Cards layout with gap separation between all columns -->
    <div class="w-full max-w-[1320px] flex items-start gap-3 sm:gap-4 lg:gap-5 pb-16 md:pb-0">
      <!-- Left Column: Navigation Sidebar -->
      <LeftSidebar
        :nav-items="navItems"
        :active-nav-id="activeNavId"
        user-name="Jeffrey Suárez"
        user-handle="SuarezCata655"
        @navigate="handleNavigate"
        @open-publish-modal="handleNavigate('crear')"
      />

      <!-- Dynamic Section: Chats / Communities or Main Feed with smooth transitions -->
      <Transition name="fade-view" mode="out-in">
        <div
          :key="activeNavId === 'chats' ? (selectedCommunityId ? `community-${selectedCommunityId}` : `chats-${chatSubTab}`) : activeNavId"
          class="flex-1 flex gap-3 sm:gap-4 lg:gap-5 min-w-0"
        >
          <template v-if="activeNavId === 'chats'">
            <template v-if="chatSubTab === 'chats'">
              <ChatView
                :conversations="conversations"
                :active-tab="chatSubTab"
                @change-tab="(tab) => { chatSubTab = tab; selectedCommunityId = null }"
              />
            </template>

            <template v-else>
              <!-- When a community room chat is opened -->
              <template v-if="selectedCommunityId && activeCommunityDetail">
                <CommunityChatRoom
                  :community="activeCommunityDetail"
                  @back="handleBackFromCommunity"
                />

                <CommunityDetailSidebar
                  :community="activeCommunityDetail"
                />
              </template>

              <!-- When browsing communities list -->
              <template v-else>
                <!-- Middle Column: Communities Feed, Create Community or Notifications View -->
                <Transition name="fade-view" mode="out-in">
                  <CreateCommunityView
                    v-if="isCreatingCommunity"
                    key="create-community-feed"
                    @back="isCreatingCommunity = false"
                    @community-created="handleCommunityCreated"
                  />
                  <NotificationsView
                    v-else-if="showCommunitiesNotifications"
                    key="notifications-feed"
                    @back="showCommunitiesNotifications = false"
                  />
                  <CommunitiesFeed
                    v-else
                    key="communities-feed"
                    :active-tab="chatSubTab"
                    :my-communities="myCommunities"
                    :suggested-communities="suggestedFeedCommunities"
                    @change-tab="(tab) => { chatSubTab = tab; selectedCommunityId = null; showCommunitiesNotifications = false; isCreatingCommunity = false }"
                    @select-community="handleSelectCommunity"
                    @click-notifications="showCommunitiesNotifications = true"
                    @create-community="isCreatingCommunity = true"
                    @request-game="isGlobalRequestGameOpen = true"
                  />
                </Transition>

                <!-- Right Column: Search & Communities Sidebar -->
                <RightSidebar
                  :communities="suggestedCommunities"
                  @request-game="isGlobalRequestGameOpen = true"
                />
              </template>
            </template>
          </template>

          <template v-else-if="activeNavId === 'crear'">
            <!-- Middle Column: Create Post & Trak View -->
            <CreatePostView
              @close="handleNavigate('inicio')"
              @published="handlePostPublished"
            />

            <!-- Right Column: Search & Communities Sidebar -->
            <RightSidebar
              :communities="suggestedCommunities"
              @request-game="isGlobalRequestGameOpen = true"
            />
          </template>

          <template v-else>
            <!-- Middle Column: Main Feed -->
            <MainFeed :initial-posts="initialPosts" />

            <!-- Right Column: Search & Communities Sidebar -->
            <RightSidebar
              :communities="suggestedCommunities"
              @request-game="isGlobalRequestGameOpen = true"
            />
          </template>
        </div>
      </Transition>
    </div>

    <!-- Global Modal: Solicitar juego al catálogo -->
    <RequestGameModal
      :is-open="isGlobalRequestGameOpen"
      title="Solicitar juego al catálogo"
      description="Envía los datos del juego para incorporarlo al catálogo oficial de Tracon."
      @close="isGlobalRequestGameOpen = false"
    />

    <!-- Mobile Bottom Navigation Bar (< 768px) -->
    <nav
      class="md:hidden fixed bottom-0 left-0 right-0 z-40 bg-black/90 backdrop-blur-md border-t border-[#1f212a] flex items-center justify-around py-2.5 px-4"
    >
      <button
        @click="activeNavId = 'inicio'"
        type="button"
        class="p-2 transition-colors"
        :class="activeNavId === 'inicio' ? 'text-[#f0254c]' : 'text-gray-400'"
      >
        <Zap class="w-6 h-6 fill-current" />
      </button>

      <button
        @click="activeNavId = 'chats'"
        type="button"
        class="p-2 transition-colors"
        :class="activeNavId === 'chats' ? 'text-white' : 'text-gray-400'"
      >
        <MessageCircle class="w-6 h-6" />
      </button>

      <button
        @click="activeNavId = 'crear'"
        type="button"
        class="p-2 transition-colors"
        :class="activeNavId === 'crear' ? 'text-white' : 'text-gray-400'"
      >
        <PlusCircle class="w-6 h-6 text-[#f0254c]" />
      </button>

      <button
        @click="activeNavId = 'traks'"
        type="button"
        class="p-2 transition-colors"
        :class="activeNavId === 'traks' ? 'text-white' : 'text-gray-400'"
      >
        <PlayCircle class="w-6 h-6" />
      </button>

      <button
        @click="activeNavId = 'perfil'"
        type="button"
        class="p-2 transition-colors"
        :class="activeNavId === 'perfil' ? 'text-white' : 'text-gray-400'"
      >
        <User class="w-6 h-6" />
      </button>
    </nav>
  </div>
</template>

<style scoped>
.fade-view-enter-active,
.fade-view-leave-active {
  transition: opacity 200ms cubic-bezier(0.23, 1, 0.32, 1), transform 200ms cubic-bezier(0.23, 1, 0.32, 1);
}

.fade-view-enter-from {
  opacity: 0;
  transform: translateY(5px);
}

.fade-view-leave-to {
  opacity: 0;
  transform: translateY(-5px);
}

@media (prefers-reduced-motion: reduce) {
  .fade-view-enter-active,
  .fade-view-leave-active {
    transition: opacity 150ms ease;
    transform: none;
  }
}
</style>
