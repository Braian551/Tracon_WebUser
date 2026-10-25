<script setup lang="ts">
import { ref } from 'vue'
import {
  MessageCircle,
  Heart,
  Zap,
  Bookmark,
  Share,
} from 'lucide-vue-next'

interface Stats {
  comments: number
  likes: number
  impulses: number
  isLiked?: boolean
  isImpulsed?: boolean
  isSaved?: boolean
}

interface Props {
  stats: Stats
}

const props = defineProps<Props>()

const localStats = ref<Stats>({
  comments: props.stats.comments,
  likes: props.stats.likes,
  impulses: props.stats.impulses,
  isLiked: props.stats.isLiked ?? false,
  isImpulsed: props.stats.isImpulsed ?? false,
  isSaved: props.stats.isSaved ?? false,
})

const toggleLike = () => {
  localStats.value.isLiked = !localStats.value.isLiked
  localStats.value.likes += localStats.value.isLiked ? 1 : -1
}

const toggleImpulse = () => {
  localStats.value.isImpulsed = !localStats.value.isImpulsed
  localStats.value.impulses += localStats.value.isImpulsed ? 1 : -1
}

const toggleSave = () => {
  localStats.value.isSaved = !localStats.value.isSaved
}

const handleShare = () => {
  if (navigator.share) {
    navigator.share({ title: 'Tracon Post', url: window.location.href }).catch(() => {})
  }
}
</script>

<template>
  <div class="flex items-center justify-between pt-3 text-gray-500 max-w-md select-none">
    <!-- Comments -->
    <button
      type="button"
      class="group flex items-center gap-2 text-xs font-medium text-gray-400 hover:text-blue-400 transition-colors"
    >
      <div class="p-1.5 rounded-full group-hover:bg-blue-500/10 transition-colors">
        <MessageCircle class="w-4 h-4" />
      </div>
      <span>{{ localStats.comments || '' }}</span>
    </button>

    <!-- Likes -->
    <button
      type="button"
      @click="toggleLike"
      class="group flex items-center gap-2 text-xs font-medium transition-colors"
      :class="localStats.isLiked ? 'text-pink-500' : 'text-gray-400 hover:text-pink-400'"
    >
      <div class="p-1.5 rounded-full group-hover:bg-pink-500/10 transition-colors">
        <Heart
          class="w-4 h-4 transition-transform active:scale-125"
          :class="localStats.isLiked ? 'fill-current text-pink-500' : ''"
        />
      </div>
      <span>{{ localStats.likes || '' }}</span>
    </button>

    <!-- Impulso (Tracon Special Lightning) -->
    <button
      type="button"
      @click="toggleImpulse"
      class="group flex items-center gap-2 text-xs font-medium transition-colors"
      :class="localStats.isImpulsed ? 'text-[#f0254c]' : 'text-gray-400 hover:text-[#f0254c]'"
    >
      <div class="p-1.5 rounded-full group-hover:bg-red-500/10 transition-colors">
        <Zap
          class="w-4 h-4 transition-transform active:scale-125"
          :class="localStats.isImpulsed ? 'fill-current text-[#f0254c] drop-shadow-[0_0_6px_rgba(240,37,76,0.8)]' : ''"
        />
      </div>
      <span :class="localStats.isImpulsed ? 'text-[#f0254c] font-bold' : ''">
        {{ localStats.impulses || '' }}
      </span>
    </button>

    <!-- Bookmark -->
    <button
      type="button"
      @click="toggleSave"
      class="group p-1.5 rounded-full text-gray-400 hover:text-yellow-400 hover:bg-yellow-500/10 transition-colors"
      :class="localStats.isSaved ? 'text-yellow-400' : ''"
    >
      <Bookmark
        class="w-4 h-4"
        :class="localStats.isSaved ? 'fill-current' : ''"
      />
    </button>

    <!-- Share -->
    <button
      type="button"
      @click="handleShare"
      class="group p-1.5 rounded-full text-gray-400 hover:text-green-400 hover:bg-green-500/10 transition-colors"
    >
      <Share class="w-4 h-4" />
    </button>
  </div>
</template>

