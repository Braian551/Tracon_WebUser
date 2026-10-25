<script setup lang="ts">
import {
  Zap,
  MessageCircle,
  PlusCircle,
  PlayCircle,
  User,
  Disc,
  MoreHorizontal,
} from 'lucide-vue-next'
import logoImage from '../../assets/logo.png'
import type { NavItem } from '../../types'

interface Props {
  navItems: NavItem[]
  userName?: string
  userHandle?: string
  activeNavId?: string
}

const props = withDefaults(defineProps<Props>(), {
  userName: 'Jeffrey Suárez',
  userHandle: 'SuarezCata655',
  activeNavId: 'inicio',
})

const emit = defineEmits<{
  (e: 'navigate', id: string): void
  (e: 'open-publish-modal'): void
}>()

const getIconComponent = (iconName: string) => {
  switch (iconName) {
    case 'Zap':
      return Zap
    case 'MessageCircle':
      return MessageCircle
    case 'PlusCircle':
      return PlusCircle
    case 'PlayCircle':
      return PlayCircle
    case 'User':
      return User
    case 'Disc':
    default:
      return Disc
  }
}

const handleSelect = (id: string) => {
  emit('navigate', id)
}
</script>

<template>
  <aside
    class="flex flex-col justify-between h-[calc(100vh-2rem)] lg:h-[calc(100vh-2.5rem)] sticky top-4 lg:top-5 px-2.5 sm:px-3 lg:px-4 py-4 rounded-2xl lg:rounded-3xl border border-[#1f212a] bg-black select-none z-20 w-[74px] lg:w-[250px] xl:w-[265px] shrink-0 shadow-lg"
  >
    <!-- Top Area: Logo + Nav Items + CTA -->
    <div class="flex flex-col items-center lg:items-start w-full">
      <!-- Top Brand Logo (left-aligned and prominent) -->
      <a
        href="#"
        class="flex items-center justify-center lg:justify-start w-fit p-1.5 mb-2 rounded-2xl hover:bg-white/5 transition-colors group"
        title="Tracon"
      >
        <img
          :src="logoImage"
          alt="Tracon Logo"
          class="w-12 h-12 lg:w-13 lg:h-13 object-contain transition-transform duration-200 group-hover:scale-105"
        />
      </a>

      <!-- Navigation links (minimalist: slim typography, refined spacing, subtle micro-hover) -->
      <nav class="flex flex-col w-full space-y-0.5">
        <button
          v-for="item in navItems"
          :key="item.id"
          type="button"
          @click="handleSelect(item.id)"
          class="flex items-center gap-4 px-3.5 py-2.5 rounded-xl transition-colors duration-150 group text-left cursor-pointer w-full hover:bg-white/[0.06]"
          :class="[
            activeNavId === item.id
              ? 'text-white'
              : 'text-gray-400 hover:text-gray-100',
          ]"
        >
          <!-- Icon -->
          <div class="relative flex items-center justify-center shrink-0">
            <component
              :is="getIconComponent(item.icon)"
              class="w-6 h-6 transition-colors duration-150"
              :class="[
                activeNavId === item.id
                  ? 'text-[#f0254c] fill-current'
                  : 'text-gray-300 group-hover:text-white',
              ]"
            />
          </div>

          <!-- Label (minimalist, modern weight) -->
          <span
            class="hidden lg:inline text-[16px] tracking-normal leading-none"
            :class="activeNavId === item.id ? 'font-semibold text-white' : 'font-normal text-gray-300 group-hover:text-white'"
          >
            {{ item.label }}
          </span>
        </button>
      </nav>

      <!-- Minimalist "Publicar" Button -->
      <div class="w-full mt-4">
        <!-- Expanded button on desktop: clean, flat, refined height -->
        <button
          type="button"
          @click="emit('open-publish-modal')"
          class="hidden lg:flex items-center justify-center w-full py-2.5 px-5 rounded-xl bg-[#f0254c] hover:bg-[#d9193f] active:scale-[0.99] text-white text-[15px] font-medium tracking-normal transition-colors cursor-pointer select-none"
        >
          Publicar
        </button>

        <!-- Compact button on tablet / collapsed view -->
        <button
          type="button"
          @click="emit('open-publish-modal')"
          class="lg:hidden flex items-center justify-center w-11 h-11 rounded-xl bg-[#f0254c] hover:bg-[#d9193f] text-white transition-colors cursor-pointer"
          title="Publicar"
        >
          <Zap class="w-5 h-5 fill-current" />
        </button>
      </div>
    </div>

    <!-- Bottom Area: Minimalist User Profile -->
    <div class="w-full mt-auto pt-3">
      <button
        type="button"
        class="flex items-center justify-between w-full p-2 rounded-xl hover:bg-white/[0.05] transition-colors cursor-pointer group text-left"
      >
        <div class="flex items-center gap-3 min-w-0">
          <!-- User initial circle avatar -->
          <div
            class="w-9 h-9 rounded-full bg-emerald-600/90 flex items-center justify-center text-white font-medium text-sm shrink-0"
          >
            {{ userName.charAt(0) }}
          </div>

          <!-- Names (desktop lg/xl) -->
          <div class="hidden lg:flex flex-col min-w-0">
            <span class="text-[13px] font-medium text-gray-200 truncate leading-tight group-hover:text-white">
              {{ userName }}
            </span>
            <span class="text-xs text-gray-500 truncate leading-tight">
              @{{ userHandle }}
            </span>
          </div>
        </div>

        <!-- Three dots menu -->
        <div class="hidden lg:flex text-gray-500 group-hover:text-gray-300 pr-1 shrink-0">
          <MoreHorizontal class="w-4 h-4" />
        </div>
      </button>
    </div>
  </aside>
</template>
