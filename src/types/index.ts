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
}

export interface PollData {
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
  messages: ChatMessage[]
}


