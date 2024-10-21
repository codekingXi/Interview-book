import { router } from '@kit.ArkUI'
import { constants, history, QuestionListComp } from 'basic'
import { SearchHistory } from '../views/Search/SearchHistory'

@Entry
@Component
struct SearchPage {
  @StorageProp(constants.TOP_AREA) topHeight: number = 0
  @State keyword: string = ''
  @State isSearch: boolean = false

  build() {
    Column() {
      Row({ space: 16 }) {
        Search({ placeholder: '请输入试题关键字', value: this.keyword })
          .placeholderFont({ size: 14 })
          .height(32)
          .layoutWeight(1)
          .defaultFocus(true)
          .onSubmit(value => {
            this.keyword = value
            this.isSearch = true //显示搜索结果
            history.setItemHistory(this.keyword) //写入一个记录
          })
          .onChange(value => {
            this.keyword = value
            if (!this.keyword) {
              this.isSearch = false
            }
          })
        Text('取消')
          .fontColor($r('app.color.black'))
          .fontSize(15)
          .fontWeight(500)
          .onClick(() => router.back())
      }
      .height(64)
      .padding({ left: 16, right: 16 })
      .border({ width: { bottom: 0.5 }, color: $r('app.color.common_gray_border') })

      Column() {
        if (this.isSearch) {
          // TODO 试题列表
          QuestionListComp({
            keyword: this.keyword
          })
            .padding({ left: 16, right: 16 })
        } else {
          SearchHistory({
            onSearch: keyword => {
              // TODO 进行搜索
              this.keyword = keyword
              this.isSearch = true
            }
          })
        }
      }
      .layoutWeight(1)
    }
    .padding({ top: this.topHeight })
    .width('100%')
    .height('100%')
  }
}