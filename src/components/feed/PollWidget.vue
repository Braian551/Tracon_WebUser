<script setup lang="ts">
import { ref } from 'vue'
import type { PollData } from '../../types'

interface Props {
  poll: PollData
}

const props = defineProps<Props>()

const localPoll = ref<PollData>({
  totalVotes: props.poll.totalVotes,
  userVotedId: props.poll.userVotedId,
  options: props.poll.options.map(opt => ({ ...opt })),
})

const handleVote = (optionId: string) => {
  if (localPoll.value.userVotedId) return // already voted

  localPoll.value.userVotedId = optionId
  localPoll.value.totalVotes += 1

  const opt = localPoll.value.options.find(o => o.id === optionId)
  if (opt) {
    opt.votes += 1
  }

  // Recalculate percentages
  const maxVotes = Math.max(...localPoll.value.options.map(o => o.votes))
  localPoll.value.options.forEach(o => {
    o.percentage = Math.round((o.votes / localPoll.value.totalVotes) * 100)
    o.isLeading = o.votes === maxVotes && maxVotes > 0
  })
}
</script>

<template>
  <div class="my-3 space-y-2.5">
    <div
      v-for="option in localPoll.options"
      :key="option.id"
      @click="handleVote(option.id)"
      class="relative flex items-center justify-between px-4 py-3 rounded-xl border border-[#232530] bg-[#121319] overflow-hidden cursor-pointer select-none transition-all duration-200 hover:border-[#343746]"
    >
      <!-- Background fill bar (animated / visual percentage indicator) -->
      <div
        class="absolute inset-y-0 left-0 transition-all duration-500 rounded-l-xl pointer-events-none"
        :style="{ width: `${option.percentage}%` }"
        :class="[
          option.isLeading
            ? 'bg-gradient-to-r from-[#701024] to-[#470a16] border-r border-red-500/40'
            : 'bg-[#1e202b]',
        ]"
      />

      <!-- Option text -->
      <span
        class="relative z-10 text-sm font-semibold tracking-wide transition-colors"
        :class="option.isLeading ? 'text-white' : 'text-gray-200'"
      >
        {{ option.text }}
      </span>

      <!-- Percentage -->
      <span
        class="relative z-10 text-sm font-bold tracking-wider"
        :class="option.isLeading ? 'text-white' : 'text-gray-300'"
      >
        {{ option.percentage }}%
      </span>
    </div>

    <!-- Poll footer info -->
    <div class="pt-1 text-xs text-gray-500 font-medium">
      {{ localPoll.totalVotes }} votos
    </div>
  </div>
</template>

