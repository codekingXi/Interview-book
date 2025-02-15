import {
  constants,
  HttpClass,
  LoadingDialogComp,
  NavBar,
  QuestionDetail,
  QuestionOptParams,
  QuestionPageParams,
  Tag,
  tracking
} from 'basic'
import { promptAction, router } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'
import { QuestionShareDialog } from '../views/Question/QuestionShareDialog'

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
  controller: WebviewController = new webview.WebviewController()
  /**
   * 加载中弹窗
   */
  dialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialogComp(),
    customStyle: true,
    alignment: DialogAlignment.Center
  })
  /**
   * 分享弹窗
   */
  shareController: CustomDialogController = new CustomDialogController({
    builder: QuestionShareDialog({
      item: this.item
    }),
    customStyle: true,
    alignment: DialogAlignment.Center
  })
  startTime: number = Date.now()

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

  onPageShow(): void {
    //记录开始时间
    this.startTime = Date.now()
  }

  onPageHide(): void {
    //记录点
    tracking.record(this.item.id, this.startTime, Date.now())
    //每次埋点都是最新的记录
    this.startTime = Date.now()
    //上报
    tracking.report()
  }

  /**
   * 切换题目
   * @param step 切换题目的步数，可以是正数（向下切换）或负数（向上切换）
   */
  async toggleQuestion(step: number) {
    // 索引
    const index = this.activeIndex + step
    // 检查索引是否超出列表范围
    if (index <= 0 || index >= this.list.length) {
      return promptAction.showToast({ message: '没有更多题目了~' })
    }
    // 索引有效,切换题目
    this.activeIndex = index
    const item = this.list[index]
    // 如果请求过答案就缓存
    if (item.answer) {
      this.item = item
    } else {
      // 获取题目的详细信息
      this.item = await this.getQuestionDetail(item.id)
      // 更新列表
      this.list[index] = this.item
    }
    // 重新渲染内容
    this.controller.runJavaScript(`writeHtml(\`${this.item.answer}\`)`)
    tracking.record(this.item.id, this.startTime, Date.now())
    this.startTime = Date.now()
  }

  // 获取问题详情接口的返回结果
  async getQuestionDetail(id: string) {
    this.dialogController.open()
    // 通过HTTP请求获取问题的详细信息
    const result = await HttpClass.request<QuestionDetail>({
      url: '/hm/question/' + id
    })
    this.dialogController.close()
    // 返回获取到的问题详细信息
    return result
  }

  //点赞+收藏
  async questionOpt(optType: 1 | 2, flag: 0 | 1) {
    //确定参数
    const data: QuestionOptParams = {
      id: this.item.id,
      optType,
      type: 0
    }
    //发请求
    await HttpClass.request<null, QuestionOptParams>({
      url: flag === 1 ? '/hm/question/opt' : '/hm/question/unOpt',
      method: 'post',
      data
    })
    //点赞操作
    if (optType === 1) {
      promptAction.showToast({ message: this.item.likeFlag === 0 ? '点赞成功' : '取消点赞' })
      //更新数据
      this.item.likeFlag = this.item.likeFlag === 0 ? 1 : 0
    }
    //收藏操作
    if (optType === 2) {
      promptAction.showToast({ message: this.item.collectFlag === 0 ? '收藏成功' : '取消收藏' })
      //更新数据
      this.item.collectFlag = this.item.collectFlag === 0 ? 1 : 0
    }
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
        .onClick(() => {
          this.questionOpt(1, this.item.likeFlag === 0 ? 1 : 0)
        })
      MenuItem({ content: '收藏' })
        .onClick(() => {
          this.questionOpt(2, this.item.collectFlag === 0 ? 1 : 0)
        })
      MenuItem({ content: '点我反馈' })
      MenuItem({ content: '试题分享' })
        .onClick(() => {
          this.shareController.open()
        })
    }
    .width(108)
  }

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
            .fillColor(this.activeIndex <= 0 ? $r('app.color.common_gray_01') : $r('app.color.common_gray_03'))
          Text(' 上一题')
            .fontColor(this.activeIndex <= 0 ? $r('app.color.common_gray_01') : $r('app.color.common_gray_03'))
        }.onClick(() => {
          this.toggleQuestion(-1)
        })

        Row() {
          Text('下一题 ')
            .fontColor(this.activeIndex >= this.list.length - 1 ? $r('app.color.common_gray_01') :
            $r('app.color.common_gray_03'))
          Image($r('sys.media.ohos_ic_public_arrow_right'))
            .width(20)
            .aspectRatio(1)
            .fillColor(this.activeIndex >= this.list.length - 1 ? $r('app.color.common_gray_01') :
            $r('app.color.common_gray_03'))
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