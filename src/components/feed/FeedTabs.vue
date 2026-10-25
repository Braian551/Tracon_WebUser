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
    class="sticky top-0 z-30 flex items-center justify-around border-b border-[#1f212a] bg-black/85 backdrop-blur-md"
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
      <span
        v-if="activeTab === tab.id"
        class="absolute bottom-0 left-1/2 h-[3px] w-12 -translate-x-1/2 rounded-full bg-[#f0254c] shadow-[0_0_8px_rgba(240,37,76,0.6)]"
      />
    </button>
  </nav>
</template>

