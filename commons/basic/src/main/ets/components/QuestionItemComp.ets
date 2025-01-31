import { QuestionItemModel } from '../models/QuestionItemModel'
import { Tag } from './TagComp'

@Component
export struct QuestionItemComp {
  @Prop
  item: QuestionItemModel = {} as QuestionItemModel

  build() {
    Column({ space: 10 }) {
      Row() {
        Tag({ difficulty: this.item.difficulty })
        Text(this.item.stem)
          .layoutWeight(1)
          .fontSize(14)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }

      RowSplit() {
        Text('点赞' + this.item.likeCount)
          .TextSty(true)
        Text('浏览' + this.item.views)
          .TextSty()
        if (this.item.readFlag === 1) {
          Text('已看过')
            .TextSty()
        }

      }
    }
    .width('100%').height(80)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
  }
}

@Extend(Text)
function TextSty(isStart: boolean = false) {
  .fontSize(12)
  .fontColor($r('app.color.common_gray_01'))
  .padding({ left: isStart ? 0 : 12, right: 12 })
}