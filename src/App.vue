<script setup lang="ts">
import { ref } from 'vue'
import LeftSidebar from './components/layout/LeftSidebar.vue'
import MainFeed from './components/layout/MainFeed.vue'
import RightSidebar from './components/layout/RightSidebar.vue'
import ChatView from './components/chat/ChatView.vue'
import {
  navItemsData,
  initialPostsData,
  suggestedCommunitiesData,
  conversationsData,
} from './data/mockData'
import { Zap, MessageCircle, PlusCircle, PlayCircle, User } from 'lucide-vue-next'

const navItems = ref(navItemsData)
const initialPosts = ref(initialPostsData)
const suggestedCommunities = ref(suggestedCommunitiesData)
const conversations = ref(conversationsData)
const activeNavId = ref('chats')

const handleNavigate = (id: string) => {
  activeNavId.value = id
}
</script>

<template>
  <div class="min-h-screen bg-black text-[#f3f4f6] font-sans antialiased selection:bg-[#f0254c] selection:text-white p-2 sm:p-3 lg:p-4">
    <!-- Floating Cards layout with gap separation between all columns -->
    <div class="w-full max-w-[1360px] mx-auto flex items-start gap-3 sm:gap-4 lg:gap-5 justify-center pb-16 md:pb-0">
      <!-- Left Column: Navigation Sidebar -->
      <LeftSidebar
        :nav-items="navItems"
        :active-nav-id="activeNavId"
        user-name="Jeffrey Suárez"
        user-handle="SuarezCata655"
        @navigate="handleNavigate"
        @open-publish-modal="() => {}"
      />

      <!-- Dynamic Section: Chats or Main Feed -->
      <template v-if="activeNavId === 'chats'">
        <ChatView :conversations="conversations" />
      </template>

      <template v-else>
        <!-- Middle Column: Main Feed -->
        <MainFeed :initial-posts="initialPosts" />

        <!-- Right Column: Search & Communities Sidebar -->
        <RightSidebar :communities="suggestedCommunities" />
      </template>
    </div>

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
