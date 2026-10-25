<script setup lang="ts">
interface Props {
  title?: string
  subtitle?: string
  badgeText?: string
}

withDefaults(defineProps<Props>(), {
  title: 'TRACON',
  subtitle: 'COMUNIDAD DE VIDEOJUEGOS',
  badgeText: 'Próximamente en App Store',
})
</script>

<template>
  <div
    class="relative w-full rounded-2xl overflow-hidden p-8 sm:p-12 my-3 border border-[#3b121b] bg-gradient-to-br from-[#450c18] via-[#20070e] to-[#0c0d12] shadow-[0_8px_30px_rgba(240,37,76,0.12)] group transition-all duration-300 hover:border-[#521724]"
  >
    <!-- Background atmospheric glow -->
    <div
      class="absolute -top-16 -left-16 w-48 h-48 bg-red-600/15 rounded-full blur-3xl pointer-events-none"
    />
    <div
      class="absolute -bottom-16 -right-16 w-48 h-48 bg-red-900/20 rounded-full blur-3xl pointer-events-none"
    />

    <div class="relative z-10 flex flex-col items-center justify-center text-center">
      <!-- Big Bold Title -->
      <h2
        class="text-3xl sm:text-4xl md:text-5xl font-black tracking-[0.2em] text-white drop-shadow-[0_2px_10px_rgba(0,0,0,0.8)]"
      >
        {{ title }}
      </h2>

      <!-- Subtitle -->
      <p
        class="mt-2 text-xs sm:text-sm font-semibold tracking-[0.3em] uppercase text-gray-300/80"
      >
        {{ subtitle }}
      </p>

      <!-- App Store Badge / Button -->
      <div class="mt-7">
        <div
          class="inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-black/40 hover:bg-black/60 border border-white/15 text-xs sm:text-sm font-medium text-white transition-all duration-200 backdrop-blur-sm cursor-pointer shadow-lg hover:border-white/30"
        >
          <svg
            class="w-4 h-4 fill-current text-white/90"
            viewBox="0 0 24 24"
          >
            <path
              d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 6.37c.63-.77 1.06-1.84.94-2.91-.91.04-2.02.61-2.67 1.38-.58.67-1.09 1.76-.95 2.81 1.02.08 2.05-.51 2.68-1.28z"
            />
          </svg>
          <span>{{ badgeText }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

