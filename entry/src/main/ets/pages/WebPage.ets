import { webview } from '@kit.ArkWeb'
import { constants, NavBar } from 'basic'
import { router } from '@kit.ArkUI'

interface RouterParams {
  title: string
  src: string
}

@Entry
@Component
struct WebPage {
  controller: WebviewController = new webview.WebviewController()
  @StorageProp(constants.BOTTOM_AREA)
  bottomHeight: number = 0
  @State
  title: string = ''
  @State
  src: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as RouterParams
    this.title = params.title
    this.src = params.src
  }

  build() {
    Column() {
      //头部
      NavBar({
        title: this.title,
        showRightIcon: false
      })
      //网页
      Web({
        src: this.src,
        controller: this.controller
      }).margin({
        bottom: 100
      })
    }
    .height('100%')
    .width('100%')
    .padding({
      bottom: this.bottomHeight
    })
  }
}