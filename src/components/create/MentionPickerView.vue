<script setup lang="ts">
import MentionPickerView from '../common/MentionPickerView.vue'
import type { MentionUser } from '../../types'

interface Props {
  title?: string
  backIcon?: 'chevron' | 'x'
  placeholder?: string
  showHeader?: boolean
}

withDefaults(defineProps<Props>(), {
  title: 'Mención',
  backIcon: 'x',
  placeholder: 'Buscar alias o apodo',
  showHeader: true,
})

const emit = defineEmits<{
  (e: 'cancel'): void
  (e: 'select', handle: string, user: MentionUser): void
}>()
</script>

<template>
  <MentionPickerView
    :title="title"
    :back-icon="backIcon"
    :placeholder="placeholder"
    :show-header="showHeader"
    @cancel="emit('cancel')"
    @select="(handle, user) => emit('select', handle, user)"
  />
</template>
