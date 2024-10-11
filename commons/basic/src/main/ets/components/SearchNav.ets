import { imgType } from '../type'
import { ImgComp } from './ImgComp'

/**
 * 搜索栏
 * @param imgSrc 图片链接 必传
 * @param imgWidth 图片宽度 必传
 * @param leftContent 左侧内容 可不传
 * @param rightContent 右侧内容 可不传
 * */
@Component
export struct SearchNav {
  @Prop imgSrc: imgType = ''
  @Prop imgWidth: Length = 0
  @Prop placeHolderText: string = '输入关键字~'
  @Prop placeHolderColor: ResourceColor = '#ffa7a7a7'
  @Prop SearchWidth: Length = 100
  @Prop SearchHeight: Length = 32
  @Prop SearchBgColor: ResourceColor = '#ffeaeaea'
  @Prop layoutWeightValue: number = 0
  @Prop space: number = 16
  @Prop SearchNavBgColor: ResourceColor = ''
  @BuilderParam
  leftContent: () => void = this.default
  @BuilderParam
  rightContent: () => void = this.default
  @Builder default(){}
  build() {
    Row({ space: this.space }) {
      //左侧内容
      if (this.leftContent) {
        this.leftContent()
      }
      //搜索条
      Row({ space: 4 }) {
        ImgComp({
          imgSrc: this.imgSrc,
          imgWidth: this.imgWidth,
          fillColor: this.placeHolderColor
        })
        Text(this.placeHolderText)
          .fontSize(14)
          .fontColor(this.placeHolderColor)
      }
      .width(this.SearchWidth)
      .height(this.SearchHeight)
      .justifyContent(FlexAlign.Center)
      .borderRadius(this.SearchHeight as number / 2)
      .layoutWeight(this.layoutWeightValue)
      .backgroundColor(this.SearchBgColor)

      //右侧内容
      if (this.rightContent) {
        this.rightContent()
      }
    }
    .width('100%')
    .backgroundColor(this.SearchNavBgColor || null)
  }
}