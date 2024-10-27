import { InterviewAudioItem } from "basic"

@Component
export struct AudioItemComp {
  @Prop
  item: InterviewAudioItem = {} as InterviewAudioItem

  build() {
    Row({ space: 15 }) {
      Image($r('app.media.ic_mine_audio'))
        .width(50)
        .aspectRatio(1)
      Column({ space: 10 }) {
        Text(this.item.name)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row({ space: 20 }) {
          Text(`时长：${(this.item.duration / 1000).toFixed(0)} 秒`)
            .fontSize(14)
            .fontColor($r('app.color.common_gray_03'))
          Text(`大小：${(this.item.size / 1000).toFixed(0)} KB`)
            .fontSize(14)
            .fontColor($r('app.color.common_gray_03'))
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .alignSelf(ItemAlign.Start)
    }
    .padding(15)
    .height(80)
    .width('100%')
  }
}