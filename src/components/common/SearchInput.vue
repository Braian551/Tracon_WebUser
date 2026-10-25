<script setup lang="ts">
import { ref } from 'vue'
import { Search, X } from 'lucide-vue-next'

interface Props {
  modelValue?: string
  placeholder?: string
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: '',
  placeholder: 'Buscar',
})

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void
}>()

const isFocused = ref(false)

const handleInput = (e: Event) => {
  const target = e.target as HTMLInputElement
  emit('update:modelValue', target.value)
}

const clearInput = () => {
  emit('update:modelValue', '')
}
</script>

<template>
  <div
    class="relative flex items-center w-full transition-colors duration-200 rounded-full group"
    :class="[
      isFocused
        ? 'bg-[#181923] ring-1 ring-[#f0254c]/70 shadow-[0_0_15px_rgba(240,37,76,0.15)]'
        : 'bg-[#121319] hover:bg-[#161720]',
    ]"
  >
    <div class="pl-4 pr-2 text-gray-400 flex items-center justify-center shrink-0">
      <Search
        class="w-4 h-4 transition-colors duration-200"
        :class="isFocused ? 'text-[#f0254c]' : 'text-gray-400 group-hover:text-gray-300'"
      />
    </div>

    <input
      type="text"
      :value="modelValue"
      :placeholder="placeholder"
      @input="handleInput"
      @focus="isFocused = true"
      @blur="isFocused = false"
      class="w-full py-2.5 pr-4 bg-transparent text-sm text-gray-100 placeholder:text-gray-500 focus:outline-none"
    />

    <button
      v-if="modelValue"
      type="button"
      @click="clearInput"
      class="pr-3 text-gray-500 hover:text-gray-300"
    >
      <X class="w-4 h-4" />
    </button>
  </div>
</template>

