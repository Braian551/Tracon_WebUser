<script setup lang="ts">
import { computed } from 'vue'
import logoImage from '../../assets/logo.png'

interface Props {
  size?: 'sm' | 'md' | 'lg'
  isTraconOfficial?: boolean
  src?: string
  alt?: string
}

const props = withDefaults(defineProps<Props>(), {
  size: 'md',
  isTraconOfficial: false,
  src: '',
  alt: 'Avatar',
})

const sizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'w-8 h-8'
    case 'lg':
      return 'w-12 h-12'
    case 'md':
    default:
      return 'w-10 h-10'
  }
})
</script>

<template>
  <div
    class="relative rounded-full flex items-center justify-center shrink-0 overflow-hidden select-none transition-transform hover:scale-105"
    :class="[
      sizeClasses,
      isTraconOfficial
        ? 'bg-red-950/40 border border-red-500/40 shadow-[0_0_12px_rgba(240,37,76,0.25)]'
        : 'bg-[#20222a] border border-[#2b2d38]',
    ]"
  >
    <!-- Tracon official avatar -->
    <template v-if="isTraconOfficial">
      <img
        :src="logoImage"
        alt="Tracon Logo"
        class="w-full h-full object-cover scale-110 drop-shadow-[0_0_6px_rgba(240,37,76,0.6)]"
      />
    </template>

    <!-- Custom image avatar -->
    <template v-else-if="src">
      <img :src="src" :alt="alt" class="w-full h-full object-cover" />
    </template>

    <!-- Default neutral placeholder (dark circle matching screenshot) -->
    <template v-else>
      <div class="w-full h-full bg-[#20222a] flex items-center justify-center">
        <div class="w-1/2 h-1/2 rounded-full bg-[#2e313d]" />
      </div>
    </template>
  </div>
</template>

