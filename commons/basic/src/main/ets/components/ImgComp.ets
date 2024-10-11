import { imgType } from '../type'

/**
 * 二次封装的图片组件
 * @param imgSrc 图片链接 必传
 * @param imgWidth 宽度 必传
 * @author ZhangYangXi
 * */
@Component
export struct ImgComp {

  @Prop
  imgSrc: imgType = '' //图片地址
  @Prop
  imgWidth: Length = 0 //宽度
  @Prop
  imgHeight: Length = 0 //高度
  @Prop
  isFillColor: boolean = false //是否填充颜色
  @Prop
  fillColor: ResourceColor = ''
  @Prop
  isDraggable: boolean = false //图片是否可拖拽
  @Prop
  ImageFitType: ImageFit = ImageFit.Contain //图片压缩类型
  @Prop
  color_1: ResourceColor = '' //外部色值1
  @Prop
  color_2: ResourceColor = '' //外部色值2
  @Prop
  bordWidth: number = 0 //边框宽度
  @Prop
  bordColor: ResourceColor = '' //边框颜色
  @Prop
  shadowValue: number | Resource = 0 //阴影值
  @Prop
  shadowColor: string | Color | Resource = '' //阴影颜色
  @Prop
  aspectRatioValue: number = 0 //宽高比
  @Prop
  marginLeft:number=0
  @Prop
  marginRight:number=0
  build() {
    Image(this.imgSrc)
      .draggable(this.isDraggable)
      .width(this.imgWidth)
      .height(this.imgHeight || null)
      .aspectRatio(this.aspectRatioValue)
      .objectFit(this.ImageFitType)
      .fillColor(this.isFillColor ? this.color_1 : this.color_2 || this.fillColor)
      .border({
        width: this.bordWidth,
        color: this.bordColor,
        radius: this.imgHeight as number / 2
      })
      .shadow({
        radius: this.shadowValue,
        color: this.shadowColor
      })
      .margin({ left: this.marginLeft, right: this.marginRight })
  }
}