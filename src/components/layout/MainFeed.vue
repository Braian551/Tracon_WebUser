<script setup lang="ts">
import { ref } from 'vue'
import FeedTabs from '../feed/FeedTabs.vue'
import PostComposer from '../feed/PostComposer.vue'
import PostCard from '../feed/PostCard.vue'
import type { Post } from '../../types'

interface Props {
  initialPosts: Post[]
}

const props = defineProps<Props>()

const posts = ref<Post[]>([...props.initialPosts])
const activeTab = ref('para-ti')

const handleNewPost = (content: string) => {
  const newPost: Post = {
    id: `post-${Date.now()}`,
    author: {
      name: 'Tú',
      handle: 'usuario',
    },
    timeAgo: 'ahora',
    content,
    stats: {
      comments: 0,
      likes: 0,
      impulses: 0,
    },
  }
  posts.value.unshift(newPost)
}

const handleTabChange = (tabId: string) => {
  activeTab.value = tabId
}
</script>

<template>
  <main
    class="flex-1 min-w-0 max-w-2xl rounded-2xl lg:rounded-3xl border border-[#1f212a] bg-black overflow-hidden flex flex-col h-[calc(100vh-2rem)] lg:h-[calc(100vh-2.5rem)] sticky top-4 lg:top-5 shadow-lg"
  >
    <!-- Top sticky feed tabs -->
    <FeedTabs
      :active-tab="activeTab"
      @change-tab="handleTabChange"
    />

    <!-- Scrollable container inside the floating card (hidden scrollbar) -->
    <div class="flex-1 overflow-y-auto no-scrollbar p-3.5 sm:p-4 space-y-3.5 sm:space-y-4">
      <!-- Post creation composer -->
      <PostComposer @publish="handleNewPost" />

      <!-- Posts stream -->
      <div class="flex flex-col gap-3.5 sm:gap-4">
        <PostCard
          v-for="post in posts"
          :key="post.id"
          :post="post"
        />
      </div>

      <!-- Empty state fallback if needed -->
      <div
        v-if="posts.length === 0"
        class="p-12 text-center text-gray-500 text-sm"
      >
        No hay publicaciones aún en esta sección.
      </div>
    </div>
  </main>
</template>

