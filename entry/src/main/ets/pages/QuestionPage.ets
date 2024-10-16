import { constants, httpClass, NavBar, QuestionDetail, QuestionPageParams, Tag } from 'basic'
import { promptAction, router } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'

@Entry
@Component
struct QuestionPage {
  @StorageProp(constants.BOTTOM_AREA) bottomHeight: number = 0
  // 问题的详细信息
  @State
  item: QuestionDetail = {} as QuestionDetail
  list: QuestionDetail[] = []
  @State
  activeIndex: number = 0

  async aboutToAppear() {
    // 更新页面获取的参数
    const params = router.getParams() as QuestionPageParams
    this.item = params.item as QuestionDetail
    this.list = params.list as QuestionDetail[]
    this.activeIndex = this.list.findIndex(obj => obj.id === this.item.id)
    // 获取完整信息
    this.item = await this.getQuestionDetail(this.item.id)
    //等拿到到数据之后再加载网页
    this.controller.loadUrl($rawfile('question.html'))
  }

  async toggleQuestion(step: number) {
    const index = this.activeIndex + step
    if (index < 0 || index > this.list.length) {
      promptAction.showToast({ message: '没有更多题目了~' })
    } else {
      this.activeIndex = index
      const item = this.list[index]
      this.item = await this.getQuestionDetail(item.id)
      this.controller.runJavaScript(`writeHtml(\`${this.item.answer}\`)`)
      
    }
  }

  // 获取问题详情接口的返回结果
  async getQuestionDetail(id: string) {
    // 通过HTTP请求获取问题的详细信息
    const result = await httpClass.request<QuestionDetail>({
      url: '/hm/question/' + id
    })
    // 返回获取到的问题详细信息
    return result
  }

  @Builder
  TitleBuilder(text: string) {
    Row() {
      Text()
        .width(2)
        .height(12)
        .backgroundColor($r('app.color.black'))
        .margin({ right: 13 })
      Text(text)
        .fontWeight(700)
    }
    .width('100%')
    .padding({ top: 10 })
    .height(32)
  }

  @Builder
  MenuBuilder() {
    Menu() {
      MenuItem({ content: '点赞' })
      MenuItem({ content: '收藏' })
      MenuItem({ content: '点我反馈' })
      MenuItem({ content: '试题分享' })
    }
    .width(108)
  }

  controller: WebviewController = new webview.WebviewController()

  build() {
    Column() {
      NavBar({ title: '试题详情', showRightIcon: false })
      // 题目
      this.TitleBuilder('题目：')
      Text(this.item.stem)
        .width('100%')
        .padding(16)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Row({ space: 12 }) {
        ForEach(this.item.stage, (item: string) => {
          Tag({ text: item, color: '#ff6600' })
        })
        Blank()
        Image($r("app.media.ic_home_more"))
          .width(20)
          .aspectRatio(1)
          .bindMenu(this.MenuBuilder())
      }
      .width('100%')
      .padding({ bottom: 16, left: 16, right: 16 })

      Divider()
        .strokeWidth(8)
        .color($r('app.color.common_gray_bg'))
      // 内容
      this.TitleBuilder('答案：')
      Web({
        src: $rawfile('question.html'),
        controller: this.controller
      })
        .width('100%')
        .layoutWeight(1)
        .onPageEnd(() => { // 用\ \ 转义才能正常显示内容
          this.controller.runJavaScript(`writeHtml(\`${this.item.answer}\`)`)
        })
      Row({ space: 80 }) {
        Row() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(20)
            .aspectRatio(1)
            .fillColor($r('app.color.common_gray_01'))
          Text(' 上一题')
            .fontColor($r('app.color.common_gray_01'))
        }.onClick(() => {
          this.toggleQuestion(-1)
        })

        Row() {
          Text('下一题 ')
            .fontColor($r('app.color.common_gray_03'))
          Image($r('sys.media.ohos_ic_public_arrow_right'))
            .width(20)
            .aspectRatio(1)
            .fillColor($r('app.color.common_gray_03'))
        }.onClick(() => {
          this.toggleQuestion(1)
        })
      }
      .height(44)
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: this.bottomHeight })
  }
}