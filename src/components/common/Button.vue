<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  fullWidth?: boolean
  disabled?: boolean
  type?: 'button' | 'submit' | 'reset'
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  fullWidth: false,
  disabled: false,
  type: 'button',
})

const variantClasses = computed(() => {
  switch (props.variant) {
    case 'primary':
      return 'bg-[#f0254c] hover:bg-[#e0163e] active:scale-[0.98] text-white font-semibold shadow-[0_4px_16px_rgba(240,37,76,0.35)] hover:shadow-[0_4px_22px_rgba(240,37,76,0.5)] border border-transparent'
    case 'secondary':
      return 'bg-[#181922] hover:bg-[#20222f] text-gray-200 border border-[#2b2e3d]'
    case 'outline':
      return 'bg-transparent hover:bg-white/5 text-gray-200 border border-gray-700/60'
    case 'ghost':
      return 'bg-transparent hover:bg-white/5 text-gray-300'
  }
})

const sizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'px-4 py-1.5 text-xs rounded-full font-medium'
    case 'lg':
      return 'px-8 py-3.5 text-base rounded-full font-bold'
    case 'md':
    default:
      return 'px-6 py-2.5 text-sm rounded-full font-semibold'
  }
})
</script>

<template>
  <button
    :type="type"
    :disabled="disabled"
    class="inline-flex items-center justify-center transition-all duration-200 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed select-none tracking-wide"
    :class="[
      variantClasses,
      sizeClasses,
      fullWidth ? 'w-full' : '',
    ]"
  >
    <slot />
  </button>
</template>

