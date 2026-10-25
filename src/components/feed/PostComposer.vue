<script setup lang="ts">
import { ref } from 'vue'
import { PlusCircle } from 'lucide-vue-next'
import Avatar from '../common/Avatar.vue'
import Button from '../common/Button.vue'

const emit = defineEmits<{
  (e: 'publish', content: string): void
}>()

const textContent = ref('')
const textareaRef = ref<HTMLTextAreaElement | null>(null)

const handlePublish = () => {
  if (!textContent.value.trim()) return
  emit('publish', textContent.value)
  textContent.value = ''
  if (textareaRef.value) {
    textareaRef.value.style.height = 'auto'
  }
}

const adjustHeight = () => {
  if (textareaRef.value) {
    textareaRef.value.style.height = 'auto'
    textareaRef.value.style.height = `${textareaRef.value.scrollHeight}px`
  }
}
</script>

<template>
  <div class="p-4 sm:p-5 rounded-2xl border border-[#1f212a] bg-black shadow-sm transition-colors">
    <div class="flex gap-3">
      <!-- User avatar -->
      <Avatar size="md" />

      <!-- Composer input and actions -->
      <div class="flex-1 min-w-0">
        <textarea
          ref="textareaRef"
          v-model="textContent"
          rows="2"
          @input="adjustHeight"
          placeholder="¿Qué está pasando en tu juego?"
          class="w-full bg-transparent text-[15px] text-gray-100 placeholder:text-gray-500 focus:outline-none resize-none pt-1 leading-relaxed"
        />

        <div class="flex items-center justify-between pt-3 mt-1 border-t border-[#181922]">
          <!-- Left tool icons -->
          <button
            type="button"
            title="Añadir multimedia"
            class="p-1.5 text-gray-400 hover:text-[#f0254c] rounded-full hover:bg-red-500/10 transition-colors"
          >
            <PlusCircle class="w-5 h-5 text-[#f0254c]" />
          </button>

          <!-- Right CTA -->
          <Button
            size="sm"
            :disabled="!textContent.trim()"
            @click="handlePublish"
          >
            Publicar
          </Button>
        </div>
      </div>
    </div>
  </div>
</template>

