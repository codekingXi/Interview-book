export interface Nav {
  icon: ResourceStr
  name: string
  onClick?: () => void
  other?: string
}

export interface Tool {
  icon: ResourceStr
  name: string
  value?: string
  onClick?: () => void
}
