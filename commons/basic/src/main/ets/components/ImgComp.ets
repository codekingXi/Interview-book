import { imgType } from '../type'

/**
 * 二次封装的图片组件
 * @param imgSrc 图片链接 必传
 * @param imgWidth 宽度 必传
 * @author ZhangYangXi
 * */
@ComponentV2
export struct ImgComp {
  @Require
  @Param
  imgSrc: imgType = '' //图片地址
  @Require
  @Param
  imgWidth: Length = 0 //宽度
  @Param
  imgHeight: Length = 0 //高度
  @Param
  isFillColor: boolean = false //是否填充颜色
  @Param
  fillColor:ResourceColor = ''
  @Param
  isDraggable: boolean = false //图片是否可拖拽
  @Param
  ImageFitType: ImageFit = ImageFit.Contain //图片压缩类型
  @Param
  color_1: ResourceColor = '' //外部色值1
  @Param
  color_2: ResourceColor = '' //外部色值2
  @Param
  bordWidth: number = 0 //边框宽度
  @Param
  bordColor: ResourceColor = '' //边框颜色
  @Param
  shadowValue: number | Resource = 0 //阴影值
  @Param
  shadowColor: string | Color | Resource | undefined = '' //阴影颜色
  @Param
  aspectRatioValue: number = 0  //宽高比
  build() {
    Image(this.imgSrc)
      .draggable(this.isDraggable)
      .width(this.imgWidth)
      .height(this.imgHeight || null)
      .aspectRatio(this.aspectRatioValue)
      .objectFit(this.ImageFitType)
      .fillColor(this.isFillColor ? this.color_1 : this.color_2||this.fillColor)
      .border({
        width: this.bordWidth,
        color: this.bordColor,
        radius: this.imgHeight as number / 2
      })
      .shadow({
        radius: this.shadowValue,
        color: this.shadowColor
      })
  }
}