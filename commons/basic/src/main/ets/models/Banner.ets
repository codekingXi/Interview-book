export interface Banner {
  src: ResourceStr
}

export const bannerArr: Banner[] = [
  { src: $r('app.media.banner_pj') },
  { src: $r('app.media.banner_ai') },
  { src: $r('app.media.banner_qa') }
]