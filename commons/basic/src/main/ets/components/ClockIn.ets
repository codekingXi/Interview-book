@Component
export struct ClocKIn {
  @Prop
  clockCount: number = 0 //0 代表未打卡

  build() {
    Row() {
      if (this.clockCount === 0) {
        Text('打卡')
          .fontSize(18)
          .fontColor($r('app.color.black'))
          .fontWeight(FontWeight.Bold)
      } else {
        Column() {
          Text('已连续打卡').fontSize(8)
          Text() {
            Span(this.clockCount > 999 ? '999' : this.clockCount.toString())
              .fontSize(12).fontColor($r('app.color.black'))
              .fontWeight(FontWeight.Bold)
            Span('天')
              .fontSize(10)
          }
        }
      }
    }
    .width(74)
    .height(28)
    .justifyContent(FlexAlign.Center)
    .padding({ left: 25, bottom: 4 })
    .backgroundImage(this.clockCount === 0 ? $r('app.media.ic_common_unclock') : $r('app.media.ic_common_clocked'))
    .backgroundImageSize(ImageSize.Contain)
  }
}