export interface NavItem {
  id: string
  label: string
  icon: string
  active?: boolean
  badge?: number | string
}

export interface PollOption {
  id: string
  text: string
  votes: number
  percentage: number
  isLeading?: boolean
  imageUrl?: string
}

export interface PollData {
  question?: string
  responseType?: 'texto' | 'imagen'
  options: PollOption[]
  totalVotes: number
  userVotedId?: string
}

export interface Post {
  id: string
  author: {
    name: string
    handle: string
    avatar?: string
    isVerified?: boolean
    isTraconOfficial?: boolean
  }
  timeAgo: string
  content: string
  bannerType?: 'tracon-announcement' | 'image' | 'none'
  bannerData?: {
    title: string
    subtitle: string
    badgeText: string
  }
  mediaUrl?: string
  gameTag?: string
  locationTag?: string
  challengeTag?: string
  trakData?: {
    title: string
    game: string
    category: string
    record?: string
    difficulty?: string
  }
  poll?: PollData
  stats: {
    comments: number
    likes: number
    impulses: number
    isLiked?: boolean
    isImpulsed?: boolean
    isSaved?: boolean
  }
}

export interface SuggestedCommunity {
  id: string
  name: string
  membersCount?: string
  subtitle?: string
  avatarBg?: string
}

export interface CommunityFeedItem {
  id: string
  name: string
  gameSubtitle: string
  description: string
  membersCount: string
  isVerified?: boolean
  avatarBg?: string
}

export interface CommunityChannelMessage {
  id: string
  dateHeader?: string
  authorName: string
  avatarBg?: string
  text: string
  timestamp?: string
  isMine?: boolean
}

export interface CommunityDetail {
  id: string
  name: string
  handle?: string
  gameSubtitle: string
  membersCount: string
  activeChannel: string
  isVerified?: boolean
  description?: string
  rules?: string
  tags?: string[]
  country?: string
  flag?: string
  language?: string
  bannerUrl?: string
  avatarUrl?: string
  channels: { id: string; name: string; unreadBadge?: number; subtitle?: string }[]
  messages: CommunityChannelMessage[]
}

export interface ChatMessage {
  id: string
  text: string
  timestamp: string
  isMine: boolean
  status?: 'sending' | 'sent' | 'delivered' | 'read'
}

export interface Conversation {
  id: string
  name: string
  handle?: string
  avatar?: string
  lastMessage: string
  timeAgo: string
  statusText?: string
  unreadCount?: number
  isOnline?: boolean
  isTraconOfficial?: boolean
  isGroup?: boolean
  messages: ChatMessage[]
}

export interface NotificationItem {
  id: string
  groupSection: 'Hoy' | 'Ayer' | string
  actor: {
    name: string
    handle?: string
    avatarType: 'purple_mask' | 'tracon' | 'minecraft' | 'red_user'
  }
  actionText: string
  timeAgo: string
  thumbnailType?: 'dark_scene' | 'night_car' | 'profile_preview' | 'tracon_promo'
}



