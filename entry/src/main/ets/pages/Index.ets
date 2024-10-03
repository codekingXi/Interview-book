import { Tab, fullScreen, TabItems, ImgComp } from 'basic'
import { HomePage } from './HomePage'
import { InterviewPage } from './InterviewPage'
import { MinePage } from './MinePage'
import { ProjectPage } from './ProjectPage'

@Entry
@ComponentV2
struct Index {
  aboutToAppear(): void {
    fullScreen.enable()
  }

  @Local activeIndex: number = 0 //索引

  @Builder
  TabBar(item: Tab, index: number) {
    Column({ space: 5 }) {
      ImgComp({
        imgSrc:this.activeIndex === index ? item.activeIcon : item.icon,
        imgWidth:24
      })
      Text(item.name)
        .fontSize(12)
        .fontColor(this.activeIndex === index ? $r('app.color.black') : $r('app.color.common_gray_01'))
    }
  }
  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End }) {
        ForEach(TabItems, (item: Tab, index: number) => {
          TabContent() {
            if (index === 0) {
              HomePage()
            } else if (index === 1) {
              ProjectPage()
            } else if (index === 2) {
              InterviewPage()
            } else {
              MinePage()
            }
          }.tabBar(this.TabBar(item, index))
        })
      }
      .divider({ strokeWidth: .5, color: $r('app.color.common_gray_border') })
      .animationDuration(0)
      .scrollable(false)
      .onChange((i: number) => {
        this.activeIndex = i
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.white'))
    .padding({
      top: fullScreen.topHeight,
      bottom: fullScreen.bottomHeight
    })
  }
}