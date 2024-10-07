export interface TagType {
  text: string
  color: ResourceColor
}

/**
 * 试题难度标签信息*/
export const TagInfoMap: Record<number, TagType> = {
  1: { text: "简单", color: $r('app.color.common_green') },
  2: { text: "简单", color: $r('app.color.common_green') },
  3: { text: "一般", color: $r('app.color.common_blue') },
  4: { text: "一般", color: $r('app.color.common_blue') },
  5: { text: "困难", color: $r('app.color.common_main_color') },
}