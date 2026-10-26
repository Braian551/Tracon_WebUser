<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import {
  ChevronLeft,
  ChevronRight,
  Users,
  Pencil,
  Info,
  UserPlus,
  User,
  Search,
  Check,
  MoreHorizontal,
} from 'lucide-vue-next'
import type { Conversation } from '../../types'

interface GroupMember {
  id: string
  name: string
  handle: string
  isAdmin?: boolean
}

interface Props {
  conversation: Conversation
}

const props = defineProps<Props>()

const emit = defineEmits<{
  (e: 'back'): void
}>()

type SubView = 'main' | 'edit-name' | 'edit-desc' | 'add-members'
const activeSubView = ref<SubView>('main')

const groupDescription = ref('')
const tempName = ref('')
const tempDescription = ref('')
const searchMemberQuery = ref('')
const selectedMemberIds = ref<string[]>([])
const activeMemberMenuId = ref<string | null>(null)

const membersList = ref<GroupMember[]>([
  {
    id: 'm-me',
    name: 'Jeffrey Suárez Cataño (Tú)',
    handle: '@lordderiam',
    isAdmin: true,
  },
  {
    id: 'm-braian',
    name: 'Braian Andrés Oquendo Durango',
    handle: '@braianoquendurango',
    isAdmin: false,
  },
])

const isCurrentUserAdmin = computed(() => {
  const me = membersList.value.find(m => m.id === 'm-me')
  return !!me?.isAdmin
})

const toggleMemberMenu = (memberId: string) => {
  if (activeMemberMenuId.value === memberId) {
    activeMemberMenuId.value = null
  } else {
    activeMemberMenuId.value = memberId
  }
}

const handleToggleAdmin = (member: GroupMember) => {
  member.isAdmin = !member.isAdmin
  activeMemberMenuId.value = null
}

const handleRemoveMember = (memberId: string) => {
  membersList.value = membersList.value.filter(m => m.id !== memberId)
  activeMemberMenuId.value = null
}

const handleClickOutsideMemberMenu = (e: MouseEvent) => {
  const target = e.target as HTMLElement
  if (!target.closest('.member-menu-container')) {
    activeMemberMenuId.value = null
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutsideMemberMenu)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutsideMemberMenu)
})

const candidateFriends = ref<GroupMember[]>([
  {
    id: 'f-hector',
    name: 'Héctor Maya',
    handle: '@hmaya10',
    isAdmin: false,
  },
  {
    id: 'f-luis',
    name: 'Luis',
    handle: '@luis8288gg',
    isAdmin: false,
  },
  {
    id: 'f-braian',
    name: 'Braian Andrés Oquendo Durango',
    handle: '@braianoquendurango',
    isAdmin: false,
  },
  {
    id: 'f-tracon',
    name: 'Tracon',
    handle: '@tracon',
    isAdmin: false,
  },
])

const availableCandidates = computed(() => {
  const currentNames = membersList.value.map(m => m.name.toLowerCase())
  return candidateFriends.value.filter(c => !currentNames.includes(c.name.toLowerCase()))
})

const filteredCandidates = computed(() => {
  if (!searchMemberQuery.value.trim()) return availableCandidates.value
  const q = searchMemberQuery.value.toLowerCase()
  return availableCandidates.value.filter(c =>
    c.name.toLowerCase().includes(q) || c.handle.toLowerCase().includes(q)
  )
})

// Subview navigation & actions
const openEditName = () => {
  tempName.value = props.conversation.name
  activeSubView.value = 'edit-name'
}

const saveName = () => {
  if (tempName.value.trim()) {
    props.conversation.name = tempName.value.trim()
  }
  activeSubView.value = 'main'
}

const openEditDesc = () => {
  tempDescription.value = groupDescription.value
  activeSubView.value = 'edit-desc'
}

const saveDescription = () => {
  groupDescription.value = tempDescription.value.trim()
  activeSubView.value = 'main'
}

const openAddMembers = () => {
  selectedMemberIds.value = []
  searchMemberQuery.value = ''
  activeSubView.value = 'add-members'
}

const toggleCandidate = (id: string) => {
  if (selectedMemberIds.value.includes(id)) {
    selectedMemberIds.value = selectedMemberIds.value.filter(i => i !== id)
  } else {
    selectedMemberIds.value.push(id)
  }
}

const saveAddMembers = () => {
  const toAdd = availableCandidates.value.filter(c => selectedMemberIds.value.includes(c.id))
  membersList.value.push(...toAdd)
  activeSubView.value = 'main'
}
</script>

<template>
  <div class="flex-1 flex flex-col h-full bg-black overflow-hidden select-none relative">
    <Transition name="subview-slide" mode="out-in">
      <!-- 1. VISTA PRINCIPAL: INFORMACIÓN DEL GRUPO -->
      <div
        v-if="activeSubView === 'main'"
        key="view-main"
        class="flex-1 flex flex-col h-full overflow-hidden"
      >
        <!-- Header -->
        <header class="h-16 px-4 sm:px-6 border-b border-[#1f212a] flex items-center justify-between shrink-0 bg-black/90 backdrop-blur-md z-10">
          <button
            type="button"
            @click="emit('back')"
            class="p-2 -ml-2 rounded-full text-gray-400 hover:text-white transition-colors cursor-pointer"
            title="Volver a la conversación"
          >
            <ChevronLeft class="w-6 h-6" />
          </button>

          <h2 class="text-base sm:text-lg font-semibold text-white tracking-wide">
            Información del grupo
          </h2>

          <div class="w-8" />
        </header>

        <!-- Contenido principal -->
        <div class="flex-1 overflow-y-auto no-scrollbar p-5 sm:p-6 space-y-6 select-text">
          <!-- Profile Hero Card -->
          <div class="flex flex-col items-center text-center pt-2 pb-1 select-none">
            <div class="w-24 h-24 sm:w-28 sm:h-28 rounded-full bg-[#79141B] flex items-center justify-center text-white shadow-lg mb-4">
              <Users class="w-12 h-12 sm:w-14 sm:h-14 text-white/95" />
            </div>

            <!-- Group Name with edit pencil -->
            <div class="flex items-center justify-center gap-2 max-w-full px-4">
              <h3 class="text-xl sm:text-2xl font-bold text-white tracking-tight truncate">
                {{ conversation.name }}
              </h3>
              <button
                type="button"
                @click="openEditName"
                class="p-1 text-gray-400 hover:text-white transition-colors cursor-pointer"
                title="Editar nombre"
              >
                <Pencil class="w-4 h-4" />
              </button>
            </div>

            <p class="text-xs sm:text-sm text-gray-400 mt-1">
              Grupo · {{ membersList.length }} miembros
            </p>
          </div>

          <!-- Add/View description card -->
          <div
            @click="openEditDesc"
            class="p-4 rounded-2xl bg-[#14151f] hover:bg-[#1a1c28] border border-[#232535] transition-all flex items-center justify-between cursor-pointer group select-none"
          >
            <div class="flex items-center gap-3.5 min-w-0 flex-1">
              <Info class="w-5 h-5 text-gray-400 shrink-0" />
              <span class="text-sm font-medium text-gray-200 truncate">
                {{ groupDescription || 'Añadir descripción del grupo' }}
              </span>
            </div>
            <ChevronRight class="w-5 h-5 text-gray-500 group-hover:text-gray-300 transition-colors shrink-0 ml-2" />
          </div>

          <!-- Members Section -->
          <div class="space-y-3">
            <div class="flex items-center justify-between px-1 select-none">
              <h4 class="text-lg font-bold text-white tracking-tight">
                Miembros
              </h4>
              <button
                type="button"
                @click="openAddMembers"
                class="p-1.5 rounded-lg text-gray-400 hover:text-white hover:bg-white/5 transition-colors cursor-pointer"
                title="Añadir miembro"
              >
                <UserPlus class="w-5 h-5" />
              </button>
            </div>

            <div class="space-y-2">
              <div
                v-for="member in membersList"
                :key="member.id"
                class="p-3 sm:p-3.5 rounded-2xl bg-[#14151f] border border-[#232535]/70 flex items-center justify-between select-text relative"
                :class="activeMemberMenuId === member.id ? 'z-30' : 'z-0'"
              >
                <div class="flex items-center min-w-0 flex-1 select-text">
                  <div class="w-10 h-10 rounded-full bg-[#3d1219] border border-[#79141b]/60 flex items-center justify-center shrink-0 select-none">
                    <User class="w-5 h-5 text-gray-200" />
                  </div>

                  <div class="ml-3.5 min-w-0 flex-1 select-text">
                    <h5 class="text-[14px] sm:text-[15px] font-semibold text-white truncate select-text">
                      {{ member.name }}
                    </h5>
                    <p class="text-xs text-gray-400 truncate mt-0.5 select-text">
                      {{ member.handle }}
                    </p>
                  </div>
                </div>

                <div class="flex items-center gap-2 shrink-0 ml-2 select-none">
                  <!-- Admin Badge -->
                  <span
                    v-if="member.isAdmin"
                    class="px-3 py-1 rounded-xl text-xs font-medium text-gray-300 bg-white/[0.04] border border-[#262838] select-none"
                  >
                    Admin
                  </span>

                  <!-- 3 Dots Options Menu when current user is Admin (for other members) -->
                  <div
                    v-if="isCurrentUserAdmin && member.id !== 'm-me'"
                    class="relative member-menu-container"
                  >
                    <button
                      type="button"
                      @click.stop="toggleMemberMenu(member.id)"
                      class="p-1.5 rounded-lg text-gray-400 hover:text-white hover:bg-white/5 transition-colors cursor-pointer"
                      :class="activeMemberMenuId === member.id ? 'text-white bg-white/10' : ''"
                      title="Opciones del miembro"
                    >
                      <MoreHorizontal class="w-5 h-5" />
                    </button>

                    <!-- Dropdown matching screenshot -->
                    <div
                      v-if="activeMemberMenuId === member.id"
                      class="absolute right-0 top-full mt-1.5 w-52 rounded-2xl bg-[#161722] border border-[#262838] py-2 shadow-2xl shadow-black/95 z-40 overflow-hidden"
                    >
                      <button
                        type="button"
                        @click.stop="handleToggleAdmin(member)"
                        class="w-full text-left px-5 py-3 text-[15px] font-normal text-white hover:bg-white/[0.06] transition-colors cursor-pointer"
                      >
                        {{ member.isAdmin ? 'Quitar como administrador' : 'Hacer administrador' }}
                      </button>

                      <button
                        type="button"
                        @click.stop="handleRemoveMember(member.id)"
                        class="w-full text-left px-5 py-3 text-[15px] font-normal text-white hover:bg-white/[0.06] transition-colors cursor-pointer"
                      >
                        Eliminar del grupo
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 2. VISTA: EDITAR NOMBRE DEL GRUPO -->
      <div
        v-else-if="activeSubView === 'edit-name'"
        key="view-edit-name"
        class="flex-1 flex flex-col h-full bg-black overflow-hidden"
      >
        <!-- Header -->
        <header class="h-16 px-4 sm:px-6 border-b border-[#1f212a] flex items-center justify-between shrink-0 bg-black/90 backdrop-blur-md z-10">
          <button
            type="button"
            @click="activeSubView = 'main'"
            class="p-2 -ml-2 rounded-full text-gray-400 hover:text-white transition-colors cursor-pointer"
            title="Cancelar"
          >
            <ChevronLeft class="w-6 h-6" />
          </button>

          <h2 class="text-base sm:text-lg font-semibold text-white tracking-wide">
            Nombre del grupo
          </h2>

          <div class="w-8" />
        </header>

        <!-- Body Input -->
        <div class="flex-1 p-5 sm:p-6 overflow-y-auto no-scrollbar">
          <div class="bg-[#14151f] border border-[#f0254c] rounded-2xl p-4 transition-colors">
            <input
              v-model="tempName"
              maxlength="160"
              type="text"
              placeholder="Nombre del grupo"
              autofocus
              class="w-full bg-transparent text-sm sm:text-base text-gray-100 placeholder:text-gray-500 focus:outline-none"
            />
          </div>
          <div class="text-right text-[11px] text-gray-500 mt-1.5 mr-1">
            {{ tempName.length }}/160
          </div>
        </div>

        <!-- Bottom Action Buttons -->
        <div class="p-5 border-t border-[#1f212a] flex items-center gap-3 bg-black shrink-0">
          <button
            type="button"
            @click="activeSubView = 'main'"
            class="flex-1 py-3 px-4 rounded-2xl border border-[#232535] bg-[#14151f] hover:bg-white/5 text-[#f0254c] font-semibold text-sm text-center transition-colors cursor-pointer"
          >
            Cancelar
          </button>

          <button
            type="button"
            :disabled="!tempName.trim()"
            @click="saveName"
            class="flex-1 py-3 px-4 rounded-2xl bg-[#1e202d] hover:bg-[#282a3c] text-white disabled:opacity-40 disabled:cursor-not-allowed font-semibold text-sm text-center transition-colors cursor-pointer"
          >
            Guardar
          </button>
        </div>
      </div>

      <!-- 3. VISTA: EDITAR DESCRIPCIÓN DEL GRUPO -->
      <div
        v-else-if="activeSubView === 'edit-desc'"
        key="view-edit-desc"
        class="flex-1 flex flex-col h-full bg-black overflow-hidden"
      >
        <!-- Header -->
        <header class="h-16 px-4 sm:px-6 border-b border-[#1f212a] flex items-center justify-between shrink-0 bg-black/90 backdrop-blur-md z-10">
          <button
            type="button"
            @click="activeSubView = 'main'"
            class="p-2 -ml-2 rounded-full text-gray-400 hover:text-white transition-colors cursor-pointer"
            title="Cancelar"
          >
            <ChevronLeft class="w-6 h-6" />
          </button>

          <h2 class="text-base sm:text-lg font-semibold text-white tracking-wide">
            Descripción del grupo
          </h2>

          <div class="w-8" />
        </header>

        <!-- Body Textarea -->
        <div class="flex-1 p-5 sm:p-6 overflow-y-auto no-scrollbar">
          <div class="bg-[#14151f] border border-[#f0254c] rounded-2xl p-4 transition-colors min-h-[160px]">
            <textarea
              v-model="tempDescription"
              maxlength="1000"
              rows="6"
              placeholder="Añade una descripción del grupo"
              autofocus
              class="w-full bg-transparent text-sm sm:text-base text-gray-100 placeholder:text-gray-500 focus:outline-none resize-none leading-relaxed"
            />
          </div>
          <div class="flex items-center justify-between text-[11px] text-gray-500 mt-2 px-1">
            <span>Visible para los miembros del grupo.</span>
            <span>{{ tempDescription.length }}/1000</span>
          </div>
        </div>

        <!-- Bottom Action Buttons -->
        <div class="p-5 border-t border-[#1f212a] flex items-center gap-3 bg-black shrink-0">
          <button
            type="button"
            @click="activeSubView = 'main'"
            class="flex-1 py-3 px-4 rounded-2xl border border-[#232535] bg-[#14151f] hover:bg-white/5 text-[#f0254c] font-semibold text-sm text-center transition-colors cursor-pointer"
          >
            Cancelar
          </button>

          <button
            type="button"
            @click="saveDescription"
            class="flex-1 py-3 px-4 rounded-2xl bg-[#1e202d] hover:bg-[#282a3c] text-white disabled:opacity-40 disabled:cursor-not-allowed font-semibold text-sm text-center transition-colors cursor-pointer"
          >
            Guardar
          </button>
        </div>
      </div>

      <!-- 4. VISTA: AÑADIR MIEMBROS -->
      <div
        v-else-if="activeSubView === 'add-members'"
        key="view-add-members"
        class="flex-1 flex flex-col h-full bg-black overflow-hidden"
      >
        <!-- Header -->
        <header class="h-16 px-4 sm:px-6 border-b border-[#1f212a] flex items-center justify-between shrink-0 bg-black/90 backdrop-blur-md z-10">
          <button
            type="button"
            @click="activeSubView = 'main'"
            class="p-2 -ml-2 rounded-full text-gray-400 hover:text-white transition-colors cursor-pointer"
            title="Volver"
          >
            <ChevronLeft class="w-6 h-6" />
          </button>

          <h2 class="text-base sm:text-lg font-semibold text-white tracking-wide">
            Añadir miembros
          </h2>

          <!-- Action button Añadir -->
          <button
            type="button"
            :disabled="selectedMemberIds.length === 0"
            @click="saveAddMembers"
            class="text-sm font-semibold transition-colors cursor-pointer"
            :class="selectedMemberIds.length > 0 ? 'text-[#f0254c] hover:text-[#ff3860]' : 'text-gray-500 cursor-not-allowed'"
          >
            Añadir
          </button>
        </header>

        <!-- Search Input -->
        <div class="px-5 pt-3 pb-2 shrink-0">
          <div class="relative flex items-center w-full rounded-2xl bg-[#14151f] border border-[#232535] px-4 py-2.5 focus-within:border-[#f0254c] transition-colors">
            <Search class="w-4.5 h-4.5 text-gray-400 mr-2.5 shrink-0" />
            <input
              v-model="searchMemberQuery"
              type="text"
              placeholder="Buscar amistades"
              class="w-full bg-transparent text-sm text-gray-100 placeholder:text-gray-500 focus:outline-none"
            />
          </div>
        </div>

        <!-- Available Candidates List -->
        <div class="flex-1 overflow-y-auto no-scrollbar px-5 py-2 space-y-2.5">
          <div
            v-for="candidate in filteredCandidates"
            :key="candidate.id"
            @click="toggleCandidate(candidate.id)"
            class="p-3.5 rounded-2xl transition-all flex items-center justify-between cursor-pointer group active:scale-[0.99]"
            :class="[
              selectedMemberIds.includes(candidate.id)
                ? 'bg-[#79141B] border border-[#9b1d26] shadow-sm'
                : 'bg-[#14151f] hover:bg-[#1b1d2a] border border-[#232535]/70 hover:border-[#32364c]'
            ]"
          >
            <div class="flex items-center min-w-0 flex-1">
              <div
                class="w-11 h-11 rounded-full flex items-center justify-center shrink-0"
                :class="selectedMemberIds.includes(candidate.id) ? 'bg-[#5a0f14] border border-white/20' : 'bg-[#3d1219] border border-[#79141b]/60'"
              >
                <User class="w-5 h-5 text-gray-200" />
              </div>

              <div class="ml-3.5 min-w-0 flex-1">
                <h4 class="text-[15px] font-semibold text-white truncate">
                  {{ candidate.name }}
                </h4>
                <p
                  class="text-xs truncate mt-0.5"
                  :class="selectedMemberIds.includes(candidate.id) ? 'text-gray-200' : 'text-gray-400'"
                >
                  {{ candidate.handle }}
                </p>
              </div>
            </div>

            <!-- Right check badge if selected, chevron if unselected -->
            <div
              v-if="selectedMemberIds.includes(candidate.id)"
              class="w-6 h-6 rounded-full bg-[#f0254c] flex items-center justify-center text-white shrink-0 ml-2 shadow-sm"
            >
              <Check class="w-3.5 h-3.5 stroke-[3]" />
            </div>
            <ChevronRight
              v-else
              class="w-5 h-5 text-gray-500 group-hover:text-gray-300 transition-colors shrink-0 ml-2"
            />
          </div>

          <div
            v-if="filteredCandidates.length === 0"
            class="text-center py-10 text-gray-500 text-sm"
          >
            No hay más amistades para añadir.
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.subview-slide-enter-active,
.subview-slide-leave-active {
  transition: opacity 240ms cubic-bezier(0.23, 1, 0.32, 1), transform 240ms cubic-bezier(0.23, 1, 0.32, 1);
  will-change: opacity, transform;
}

.subview-slide-leave-active {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 0;
}

.subview-slide-enter-active {
  z-index: 10;
}

.subview-slide-enter-from {
  opacity: 0;
  transform: translateY(8px) scale(0.995);
}

.subview-slide-leave-to {
  opacity: 0;
  transform: translateY(-8px) scale(0.995);
}

@media (prefers-reduced-motion: reduce) {
  .subview-slide-enter-active,
  .subview-slide-leave-active {
    transition: opacity 150ms ease;
    transform: none;
  }
}
</style>
