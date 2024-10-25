import { getStrFromJson, NavBar, WordItem, Words } from 'basic'
import { webview } from '@kit.ArkWeb'
import { WordDialog } from '../views/Word/WordDialog'

@Entry
@Component
struct WordPage {
  /**
   * json文件的所有单词*/
  words: Words = {}
  @State
  wordKey: string = ''
  @State showTypeSheet: boolean = false
  @State showCodeSheet: boolean = false
  @State
  currentCode: string = ''
  @State
  currentZh: string = ''
  @State
  currentEn: string = ''
  /**
   * 滚动条控制器*/
  scroller: Scroller = new Scroller()
  /**
   * 详情代码控制器*/
  webController: WebviewController = new webview.WebviewController()
  /**
   * 朗读弹层控制器*/
  wordController: CustomDialogController = new CustomDialogController({
    builder: WordDialog({
      en: this.currentEn,
      zh: this.currentZh,
    }),
    alignment: DialogAlignment.Center,
    customStyle: true
  })

  aboutToAppear(): void {
    this.initWords()
  }

  /**
   * 初始化单词*/
  initWords() {
    const str = getStrFromJson('word.json') //获得json文件返回后的值
    this.words = JSON.parse(str) as Words //转换为对象
    this.wordKey = Object.keys(this.words)[0] //默认选中第一个单词
  }

  @Builder
  TypeSheetBuilder() {
    Column() {
      Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
        ForEach(Object.keys(this.words), (key: string) => {
          Button() {
            Text(key)
              .fontSize(14)
              .fontColor(key === this.wordKey ? $r('app.color.common_green') : $r('app.color.common_gray_01'))
          }
          .backgroundColor($r('app.color.common_gray_bg'))
          .padding({
            top: 6,
            right: 12,
            bottom: 6,
            left: 12
          })
          .margin({ right: 12, bottom: 12 })
          .onClick(() => {
            this.wordKey = key
            this.showTypeSheet = false
            this.scroller.scrollEdge(Edge.Top)
          })
        })
      }
    }
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 34
    })
  }

  @Builder
  CodeSheetBuilder() {
    Column() {
      Web({ src: $rawfile('word.html'), controller: this.webController })
        .width('100%')
        .height(400)
        .backgroundColor($r('app.color.common_gray_bg'))
        .onPageEnd(() => {
          this.webController.runJavaScript(`writeHtml(\`${this.currentCode}\`)`)
        })
    }
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 34
    })
  }

  build() {
    Column() {
      NavBar({ title: '常用单词', showRightIcon: false })
      Row() {
        Column({ space: 4 }) {
          Text('开发常用词汇')
          Text(`共${this.words[this.wordKey].length}个单词`)
            .fontSize(12)
            .fontColor($r('app.color.common_gray_03'))
        }
        .alignItems(HorizontalAlign.Start)

        Row() {
          Text(this.wordKey)
            .fontSize(12)
            .fontColor($r('app.color.common_gray_01'))
            .bindSheet($$this.showTypeSheet, this.TypeSheetBuilder(), {
              title: { title: '选择技术分类' },
              backgroundColor: $r('app.color.white'),
              height: 400
            })
            .onClick(() => {
              this.showTypeSheet = true
            })
          Image($r('sys.media.ohos_ic_public_arrow_down'))
            .width(16)
            .aspectRatio(1)
            .fillColor($r('app.color.common_gray_01'))
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(16)
      .border({ width: { top: 0.5 }, color: $r('app.color.common_gray_bg') })

      Divider()
        .strokeWidth(8)
        .color($r('app.color.common_gray_bg'))

      List({ scroller: this.scroller }) {
        ForEach(this.words[this.wordKey], (item: WordItem) => {
          ListItem() {
            Row({ space: 6 }) {
              Image($r('sys.media.ohos_ic_public_sound'))
                .width(20)
                .aspectRatio(1)
                .alignSelf(ItemAlign.Start)
                .fillColor($r('app.color.common_gray_03'))
                .onClick(() => {
                  this.currentZh = item.zh
                  this.currentEn = item.en
                  this.wordController.open()
                })
              Column({ space: 10 }) {
                Text(item.en)
                  .fontWeight(FontWeight.Bold)
                Text(item.zh)
                  .fontSize(14)
                  .fontColor($r('app.color.common_gray_03'))
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Row() {
                Text('详细代码')
                  .fontSize(12)
                  .fontColor($r('app.color.common_gray_01'))
                Image($r('sys.media.ohos_ic_public_arrow_right'))
                  .width(16)
                  .aspectRatio(1)
                  .fillColor($r('app.color.common_gray_01'))
              }
              .visibility(item.code ? Visibility.Visible : Visibility.Hidden)
              .alignSelf(ItemAlign.End)
              .onClick(() => {
                this.currentCode = item.code
                this.showCodeSheet = true
              })
            }
            .padding(16)
          }
        })
      }
      .divider({
        strokeWidth: 0.5,
        color: $r('app.color.common_gray_bg')
      })
      .layoutWeight(1)
      .bindSheet($$this.showCodeSheet, this.CodeSheetBuilder(), {
        title: { title: '代码详情' },
        backgroundColor: $r('app.color.white'),
        detents: [SheetSize.FIT_CONTENT]  //自适应高度
      })
    }
    .width('100%')
    .height('100%')
  }
}