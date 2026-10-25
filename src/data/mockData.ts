import type { NavItem, Post, SuggestedCommunity, Conversation } from '../types'

export const navItemsData: NavItem[] = [
  { id: 'inicio', label: 'Inicio', icon: 'Zap', active: true },
  { id: 'chats', label: 'Chats', icon: 'MessageCircle' },
  { id: 'crear', label: 'Crear', icon: 'PlusCircle' },
  { id: 'traks', label: 'Traks', icon: 'PlayCircle' },
  { id: 'perfil', label: 'Perfil', icon: 'User' },
  { id: 'ajustes', label: 'Ajustes', icon: 'Disc' },
]

export const initialPostsData: Post[] = [
  {
    id: 'post-1',
    author: {
      name: 'Tracon',
      handle: 'tracon',
      isTraconOfficial: true,
    },
    timeAgo: 'jueves',
    content: 'Próximamente',
    bannerType: 'tracon-announcement',
    bannerData: {
      title: 'TRACON',
      subtitle: 'COMUNIDAD DE VIDEOJUEGOS',
      badgeText: 'Próximamente en App Store',
    },
    stats: {
      comments: 4,
      likes: 5,
      impulses: 2,
      isImpulsed: true,
      isLiked: false,
      isSaved: false,
    },
  },
  {
    id: 'post-2',
    author: {
      name: 'Mr Meat',
      handle: 'mrmeat',
    },
    timeAgo: 'martes',
    content: 'Cuál juego quieren que me pase en modo pesadilla',
    poll: {
      totalVotes: 6,
      options: [
        { id: 'opt-1', text: 'Ice Scream', votes: 1, percentage: 17 },
        { id: 'opt-2', text: 'Granny', votes: 1, percentage: 17 },
        { id: 'opt-3', text: 'Granny Chapter 2', votes: 4, percentage: 66, isLeading: true },
      ],
    },
    stats: {
      comments: 2,
      likes: 8,
      impulses: 1,
      isImpulsed: false,
      isLiked: false,
      isSaved: false,
    },
  },
]

export const suggestedCommunitiesData: SuggestedCommunity[] = [
  {
    id: 'brawl-stars',
    name: 'Brawl Stars',
    membersCount: '5 miembros',
    avatarBg: '#212433',
  },
  {
    id: 'granny',
    name: 'Granny',
    membersCount: '3 miembros',
    avatarBg: '#2a1a1f',
  },
  {
    id: 'mr-meat-2',
    name: 'Mr Meat 2: Prison Break',
    subtitle: 'Mr Meat',
    avatarBg: '#1f2622',
  },
]

export const conversationsData: Conversation[] = [
  {
    id: 'hector-maya',
    name: 'Héctor Maya',
    handle: 'hectormaya',
    lastMessage: 'Activo hace 3 h',
    statusText: 'Activo hace 3 h',
    timeAgo: 'Hace 4 h',
    isOnline: true,
    messages: [
      {
        id: 'm1',
        text: '¿Vamos a jugar unas partidas de Granny modo pesadilla hoy?',
        timestamp: '16:20',
        isMine: false,
      },
      {
        id: 'm2',
        text: '¡De una! Ya tengo el Discord listo y las configuraciones de stream.',
        timestamp: '16:22',
        isMine: true,
        status: 'read',
      },
      {
        id: 'm3',
        text: 'Perfecto, te aviso apenas termine de cenar.',
        timestamp: '16:25',
        isMine: false,
      },
    ],
  },
  {
    id: 'tracon',
    name: 'Tracon',
    handle: 'tracon',
    isTraconOfficial: true,
    lastMessage: 'voy',
    timeAgo: 'Ayer',
    messages: [
      {
        id: 't1',
        text: 'Bienvenido al canal oficial de Tracon.',
        timestamp: 'Ayer 12:00',
        isMine: false,
      },
      {
        id: 't2',
        text: 'voy',
        timestamp: 'Ayer 12:05',
        isMine: false,
      },
    ],
  },
  {
    id: 'braian-andres',
    name: 'Braian Andrés Oquendo Durango',
    handle: 'braian',
    lastMessage: 'hola',
    timeAgo: 'Ayer',
    messages: [
      {
        id: 'b1',
        text: 'hola',
        timestamp: 'Ayer 19:40',
        isMine: false,
      },
    ],
  },
  {
    id: 'equipo-encontrado',
    name: 'Equipo encontrado',
    handle: 'squad_match',
    lastMessage: 'Braian Andrés Oquendo Durango salió del...',
    timeAgo: 'domingo',
    messages: [
      {
        id: 'e1',
        text: 'Sala de juego sincronizada.',
        timestamp: 'domingo 15:00',
        isMine: false,
      },
      {
        id: 'e2',
        text: 'Braian Andrés Oquendo Durango salió del equipo.',
        timestamp: 'domingo 15:32',
        isMine: false,
      },
    ],
  },
  {
    id: 'luis',
    name: 'Luis',
    handle: 'luis_gamer',
    lastMessage: 'Envía el primer mensaje',
    timeAgo: 'hace 3 d',
    messages: [],
  },
]


