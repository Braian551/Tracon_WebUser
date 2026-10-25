<script setup lang="ts">
interface Props {
  activeTab?: string
}

const props = withDefaults(defineProps<Props>(), {
  activeTab: 'para-ti',
})

const emit = defineEmits<{
  (e: 'change-tab', tabId: string): void
}>()

const tabs = [
  { id: 'para-ti', label: 'Para ti' },
  { id: 'siguiendo', label: 'Siguiendo' },
  { id: 'radar', label: 'Radar' },
]

const selectTab = (tabId: string) => {
  emit('change-tab', tabId)
}
</script>

<template>
  <nav
    class="relative sticky top-0 z-30 flex items-center justify-around border-b border-[#1f212a] bg-black/85 backdrop-blur-md select-none"
  >
    <button
      v-for="tab in tabs"
      :key="tab.id"
      type="button"
      @click="selectTab(tab.id)"
      class="relative flex-1 py-3.5 text-center text-sm font-semibold transition-colors duration-200 cursor-pointer"
      :class="[
        activeTab === tab.id
          ? 'text-white'
          : 'text-gray-400 hover:text-gray-200',
      ]"
    >
      <span>{{ tab.label }}</span>
    </button>

    <!-- Smooth sliding active underline indicator -->
    <span
      class="absolute bottom-0 h-[3px] w-14 rounded-full bg-[#f0254c] shadow-[0_0_10px_rgba(240,37,76,0.6)] transition-all duration-300 ease-[cubic-bezier(0.23,1,0.32,1)] -translate-x-1/2 pointer-events-none"
      :style="{
        left: activeTab === 'para-ti' ? '16.666%' : activeTab === 'siguiendo' ? '50%' : '83.333%'
      }"
    />
  </nav>
</template>

