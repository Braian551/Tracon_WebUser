<script setup lang="ts">
import type { Post } from '../../types'
import Avatar from '../common/Avatar.vue'
import TraconHeroCard from './TraconHeroCard.vue'
import PollWidget from './PollWidget.vue'
import PostActions from './PostActions.vue'

interface Props {
  post: Post
}

defineProps<Props>()
</script>

<template>
  <article class="p-4 sm:p-5 rounded-2xl border border-[#1f212a] bg-[#101117] transition-all duration-200 hover:bg-[#14151f] shadow-sm">
    <div class="flex gap-3">
      <!-- Author Avatar -->
      <Avatar
        size="md"
        :is-tracon-official="post.author.isTraconOfficial"
      />

      <!-- Content Area -->
      <div class="flex-1 min-w-0">
        <!-- Author Header -->
        <header class="flex items-center gap-1.5 flex-wrap">
          <span class="font-bold text-[15px] text-white tracking-wide">
            {{ post.author.name }}
          </span>

          <span class="text-xs text-gray-400">
            @{{ post.author.handle }}
          </span>

          <span class="text-gray-500 text-xs">·</span>

          <time class="text-xs text-gray-400">
            {{ post.timeAgo }}
          </time>
        </header>

        <!-- Post Text -->
        <p class="mt-1 text-[15px] text-gray-100 leading-relaxed break-words">
          {{ post.content }}
        </p>

        <!-- Hero Card Banner (Tracon official) -->
        <template v-if="post.bannerType === 'tracon-announcement' && post.bannerData">
          <TraconHeroCard
            :title="post.bannerData.title"
            :subtitle="post.bannerData.subtitle"
            :badge-text="post.bannerData.badgeText"
          />
        </template>

        <!-- Interactive Poll Widget -->
        <template v-if="post.poll">
          <PollWidget :poll="post.poll" />
        </template>

        <!-- Post Action Bar -->
        <PostActions :stats="post.stats" />
      </div>
    </div>
  </article>
</template>

