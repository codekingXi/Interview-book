/**
 * 骨架屏内容*/
@ComponentV2
export struct SkeletonItem {
  @Param
  widthValue: Length = 100
  @Local
  bgColor: ResourceColor = Color.Gray
  @Local
  opacityValue: number = 1

  build() {
    Row()
      .width(this.widthValue)
      .height(24)
      .borderRadius(2)
      .backgroundColor(this.bgColor)
      .opacity(this.opacityValue)
      .animation({
        duration: 600,
        iterations: -1
      })
      .onAppear(() => {
        this.bgColor = '#ffc4c4c4'
        this.opacityValue = .5
      })
  }
}