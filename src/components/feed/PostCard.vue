<script setup lang="ts">
import { Gamepad2, MapPin, Trophy, PlayCircle } from 'lucide-vue-next'
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
  <article class="p-4 sm:p-5 rounded-2xl border border-[#1f212a] bg-black transition-all duration-200 hover:border-[#2d303d] hover:bg-white/[0.015] shadow-sm">
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

        <!-- Tags Row (Game, Location) -->
        <div v-if="post.gameTag || post.locationTag" class="flex items-center gap-2 mt-1.5 flex-wrap">
          <span v-if="post.gameTag" class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-[#1e131d] border border-[#f0254c]/40 text-[#f0254c] text-xs font-medium">
            <Gamepad2 class="w-3 h-3" />
            {{ post.gameTag }}
          </span>
          <span v-if="post.locationTag" class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-cyan-950/40 border border-cyan-500/30 text-cyan-400 text-xs font-medium">
            <MapPin class="w-3 h-3" />
            {{ post.locationTag }}
          </span>
        </div>

        <!-- Challenge Highlight Card (Reto) -->
        <div
          v-if="post.challengeData || post.challengeTag"
          class="mt-2.5 p-4 rounded-2xl bg-gradient-to-br from-[#261019] via-[#16121b] to-black border border-[#f0254c]/40 shadow-[0_0_20px_rgba(240,37,76,0.12)] space-y-3"
        >
          <!-- Badge Row -->
          <div class="flex items-center justify-between">
            <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#f0254c]/20 border border-[#f0254c]/50 text-[#f0254c] text-xs font-bold uppercase tracking-wider shadow-sm">
              <Trophy class="w-3.5 h-3.5 text-[#f0254c]" />
              Reto
            </span>
            <span v-if="post.gameTag" class="text-xs text-gray-400 font-medium flex items-center gap-1">
              <Gamepad2 class="w-3.5 h-3.5 text-[#f0254c]" />
              {{ post.gameTag }}
            </span>
          </div>

          <!-- Challenge Title -->
          <h3 class="text-base sm:text-lg font-black text-white tracking-wide">
            {{ post.challengeData?.title || post.challengeTag }}
          </h3>

          <!-- Rules Section -->
          <div class="p-3 rounded-xl bg-black/60 border border-[#2d1b2e] space-y-1">
            <span class="text-[11px] font-bold uppercase tracking-wider text-[#f0254c]">
              Reglas del reto
            </span>
            <p class="text-sm text-gray-200 leading-relaxed break-words whitespace-pre-line">
              {{ post.challengeData?.rules || post.content }}
            </p>
          </div>
        </div>

        <!-- Normal Post Text (only when not a challenge) -->
        <p v-else-if="post.content || post.poll?.question" class="mt-1 text-[15px] text-gray-100 leading-relaxed break-words">
          {{ post.content || post.poll?.question }}
        </p>

        <!-- Trak Card Highlight -->
        <div v-if="post.trakData" class="mt-2.5 p-3 rounded-xl bg-gradient-to-r from-[#201017] to-[#121319] border border-[#79141b]/50">
          <div class="flex items-center justify-between text-xs text-gray-400 mb-1">
            <span class="inline-flex items-center gap-1 text-[#f0254c] font-bold uppercase tracking-wider">
              <PlayCircle class="w-3.5 h-3.5" />
              Trak Gamer
            </span>
            <span v-if="post.trakData.difficulty" class="px-2 py-0.5 rounded bg-black/50 text-gray-300 font-medium">
              {{ post.trakData.difficulty }}
            </span>
          </div>
          <h4 class="text-sm font-bold text-white">{{ post.trakData.title }}</h4>
          <div class="flex items-center gap-3 mt-1.5 text-xs text-gray-300">
            <span class="font-medium text-gray-400">Juego: <strong class="text-white">{{ post.trakData.game }}</strong></span>
            <span v-if="post.trakData.record" class="text-emerald-400 font-mono font-bold">⏱ {{ post.trakData.record }}</span>
            <span class="text-xs px-2 py-0.5 rounded-full bg-white/5 border border-white/10">{{ post.trakData.category }}</span>
          </div>
        </div>

        <!-- Attached Media Image or Video -->
        <div v-if="post.mediaUrl" class="mt-2.5 rounded-xl overflow-hidden border border-[#1f212a] max-h-96 bg-black">
          <video
            v-if="post.mediaType === 'video' || post.mediaUrl.endsWith('.mp4') || post.mediaUrl.endsWith('.webm') || post.mediaUrl.startsWith('data:video')"
            :src="post.mediaUrl"
            controls
            class="w-full h-full max-h-96 object-cover bg-black"
          />
          <img v-else :src="post.mediaUrl" alt="Adjunto" class="w-full h-full object-cover" />
        </div>

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

