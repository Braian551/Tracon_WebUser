import type {
  NavItem,
  Post,
  SuggestedCommunity,
  Conversation,
  CommunityFeedItem,
  CommunityDetail,
  NotificationItem,
  MentionUser,
} from '../types'

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

export const myCommunitiesData: CommunityFeedItem[] = [
  {
    id: 'specimen-zero',
    name: 'Specimen zero',
    gameSubtitle: 'Specimen Zero',
    description: 'Un juego de terror',
    membersCount: '21 miembros',
    isVerified: true,
    avatarBg: '#181b24',
  },
]

export const suggestedFeedCommunitiesData: CommunityFeedItem[] = [
  {
    id: 'brawl-stars-feed',
    name: 'Brawl Stars',
    gameSubtitle: 'Brawl Stars',
    description: 'Comunidad para jugadores de Brawl Stars. Encuentra equipo, comparte jugadas...',
    membersCount: '5 miembros',
    isVerified: true,
    avatarBg: '#212433',
  },
  {
    id: 'granny-feed',
    name: 'Granny',
    gameSubtitle: 'Specimen Zero',
    description: 'Entren a los que les gusta Granny',
    membersCount: '3 miembros',
    isVerified: false,
    avatarBg: '#2a1a1f',
  },
]

export const communityDetailsData: Record<string, CommunityDetail> = {
  'specimen-zero': {
    id: 'specimen-zero',
    name: 'Specimen zero',
    handle: '@specimen-zero',
    gameSubtitle: 'Specimen Zero',
    membersCount: '23 miembros',
    activeChannel: 'general',
    isVerified: true,
    description: 'aquí encontraras personas de tu mismo nicho',
    rules: '1. no insulstar',
    tags: ['terror', 'survival'],
    country: 'Colombia',
    flag: '🇨🇴',
    language: 'Español',
    channels: [
      { id: 'general', name: 'General', subtitle: 'Participación de miembros', unreadBadge: 2 },
      { id: 'multimedia', name: 'Multimedia', subtitle: 'Participación de miembros' },
      { id: 'anuncios', name: 'Anuncios', subtitle: 'Publican moderadores' },
    ],
    messages: [
      {
        id: 'cm-1',
        dateHeader: '13 SEP 2026 · 7:46 a. m.',
        authorName: 'Braian Andrés Oquendo Durango',
        text: 'jjajjaja si aún está promocionada del todo por el canal',
        avatarBg: '#232634',
      },
      {
        id: 'cm-2',
        dateHeader: '13 SEP 2026 · 5:54 p. m.',
        authorName: 'Axel',
        text: 'hola',
        avatarBg: '#1f2832',
      },
      {
        id: 'cm-3',
        dateHeader: '20 SEP 2026 · 1:24 p. m.',
        authorName: 'Leogamer2010',
        text: 'hola gente como estáis',
        avatarBg: '#2a2233',
      },
      {
        id: 'cm-4',
        dateHeader: '9 OCT 2026 · 1:02 p. m.',
        authorName: 'Octavio',
        text: 'hola',
        avatarBg: '#252528',
      },
      {
        id: 'cm-5',
        dateHeader: 'JUEVES · 2:30 p. m.',
        authorName: 'Mr Meat',
        text: 'hola',
        avatarBg: '#1e2621',
      },
      {
        id: 'cm-6',
        authorName: 'Dayam',
        text: 'holaaa',
        avatarBg: '#2e2025',
      },
    ],
  },
}

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
    isGroup: true,
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

export const notificationsData: NotificationItem[] = [
  // Hoy
  {
    id: 'notif-1',
    groupSection: 'Hoy',
    actor: {
      name: 'pasa pasa',
      avatarType: 'purple_mask',
    },
    actionText: '',
    timeAgo: '24 min',
  },
  {
    id: 'notif-2',
    groupSection: 'Hoy',
    actor: {
      name: 'tracon',
      avatarType: 'tracon',
    },
    actionText: 'respondió a tu comentario.',
    timeAgo: '4 h',
    thumbnailType: 'dark_scene',
  },
  {
    id: 'notif-3',
    groupSection: 'Hoy',
    actor: {
      name: 'tracon',
      avatarType: 'tracon',
    },
    actionText: 'reaccionó a tu comentario.',
    timeAgo: '4 h',
    thumbnailType: 'dark_scene',
  },

  // Ayer
  {
    id: 'notif-4',
    groupSection: 'Ayer',
    actor: {
      name: 'camilo828288',
      avatarType: 'minecraft',
    },
    actionText: 'indicó que le gusta tu publicación.',
    timeAgo: '15 h',
    thumbnailType: 'night_car',
  },
  {
    id: 'notif-5',
    groupSection: 'Ayer',
    actor: {
      name: 'octav20rpro',
      avatarType: 'red_user',
    },
    actionText: 'indicó que le gusta tu publicación.',
    timeAgo: '16 h',
    thumbnailType: 'profile_preview',
  },
  {
    id: 'notif-6',
    groupSection: 'Ayer',
    actor: {
      name: 'octav20rpro',
      avatarType: 'red_user',
    },
    actionText: 'comenzó a seguirte.',
    timeAgo: '16 h',
  },
  {
    id: 'notif-7',
    groupSection: 'Ayer',
    actor: {
      name: 'octav20rpro',
      avatarType: 'red_user',
    },
    actionText: 'indicó que le gusta tu publicación.',
    timeAgo: '16 h',
    thumbnailType: 'night_car',
  },
  {
    id: 'notif-8',
    groupSection: 'Ayer',
    actor: {
      name: 'beatrizcatano',
      avatarType: 'red_user',
    },
    actionText: 'comenzó a seguirte.',
    timeAgo: '21 h',
  },
  {
    id: 'notif-9',
    groupSection: 'Ayer',
    actor: {
      name: 'beatrizcatano',
      avatarType: 'red_user',
    },
    actionText: 'indicó que le gusta tu Trak.',
    timeAgo: '21 h',
    thumbnailType: 'night_car',
  },
  {
    id: 'notif-10',
    groupSection: 'Ayer',
    actor: {
      name: 'beatrizcatano',
      avatarType: 'red_user',
    },
    actionText: 'impulsó tu Trak.',
    timeAgo: '21 h',
    thumbnailType: 'night_car',
  },
  {
    id: 'notif-11',
    groupSection: 'Ayer',
    actor: {
      name: 'beatrizcatano',
      avatarType: 'red_user',
    },
    actionText: 'comentó tu publicación.',
    timeAgo: '21 h',
    thumbnailType: 'tracon_promo',
  },
]

export const mentionUsersData: MentionUser[] = [
  {
    id: 'tracon',
    name: 'Tracon',
    handle: 'tracon',
    relation: 'Mutuo',
    followingStatus: 'siguiendo',
    isTraconOfficial: true,
  },
  {
    id: 'braian',
    name: 'Braian Andrés Oquendo Durango',
    handle: 'braianoquendurango',
    relation: 'Mutuo',
    followingStatus: 'siguiendo',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop&crop=faces',
  },
  {
    id: 'sparky',
    name: 'Sparky67',
    handle: 'dusty',
    relation: 'Mutuo',
    followingStatus: 'siguiendo',
    avatarType: 'purple_mask',
  },
  {
    id: 'hector',
    name: 'Héctor Maya',
    handle: 'hmaya10',
    relation: 'Mutuo',
    followingStatus: 'siguiendo',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=faces',
  },
  {
    id: 'luis',
    name: 'Luis',
    handle: 'luis8288gg',
    relation: 'Mutuo',
    followingStatus: 'siguiendo',
    avatarUrl: 'https://images.unsplash.com/photo-1566492031773-4f4e44671857?w=100&h=100&fit=crop&crop=faces',
  },
  {
    id: 'octavio',
    name: 'Octavio',
    handle: 'octav20rpro',
    followingStatus: 'seguir-tambien',
    avatarType: 'red_user',
  },
  {
    id: 'braian-2',
    name: 'Braian Andrés Oquendo Durango',
    handle: 'braianoquen_52a1ae60',
    followingStatus: 'siguiendo',
    avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop&crop=faces',
  },
  {
    id: 'el-men',
    name: 'el men',
    handle: 'eliashurtado',
    avatarType: 'red_user',
  },
  {
    id: 'camilo',
    name: 'Camilo',
    handle: 'camilo828288',
    avatarType: 'minecraft_pink',
  },
  {
    id: 'alejandro',
    name: 'Alejandro',
    handle: 'oscardurango',
    avatarType: 'gamer_blue',
  },
  {
    id: 'mr-meat',
    name: 'Mr Meat',
    handle: 'mrmeat',
    avatarType: 'horror_meat',
  },
  {
    id: 'dayam',
    name: 'Dayam',
    handle: 'userdayis',
    avatarType: 'red_user',
  },
]



