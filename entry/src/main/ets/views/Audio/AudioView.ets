import { audioDB, auth, constants, InterviewAudioItem, NavBar } from "basic"
import { AudioItemComp } from "./AudioItemComp"
import { AudioRecordComp } from "./AudioRecord"


@Component
export struct AudioView {
  @State list: InterviewAudioItem[] = []
  @State currentItem: InterviewAudioItem = {} as InterviewAudioItem

  aboutToAppear(): void {
    this.updateList()
    getContext().eventHub.on(constants.UPDATE_RECORD_LIST, () => {
      //更新列表
      this.updateList()
    })
  }

  async updateList() {
    const userid = auth.getUser().id
    this.list = await audioDB.query(userid)
  }

  dialog: CustomDialogController = new CustomDialogController({
    builder: InputDialog({
      name: this.currentItem.name,
      onSubmit: async (name) => {
        // TODO 实现修改
        const item = this.currentItem //通过第一层数据才能修改成功
        item.name = name
        await audioDB.update(item)
        this.updateList()
        this.dialog.close()
      }
    }),
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  @Builder
  ListItemSwiperBuilder(item: InterviewAudioItem) {
    Row() {
      Text('编辑')
        .actionButton($r('app.color.common_blue'))
        .onClick(() => {
          this.currentItem = item
          this.dialog.open()
        })
      Text('删除')
        .actionButton('#FF0033')
        .onClick(async () => {
          await audioDB.delete(item.id!)
          this.updateList()
        })
    }
    .height('100%')
  }

  build() {
    Column() {
      NavBar({ title: '面试录音', showRightIcon: false })
      //录音文件区
      Column() {
        List() {
          ForEach(this.list, (item: InterviewAudioItem) => {
            ListItem() {
              AudioItemComp({
                item
              })
            }
            .swipeAction({
              end: this.ListItemSwiperBuilder(item)
            })
          })
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .layoutWeight(1)

      //录音区
      AudioRecordComp()
    }
    .width('100%')
    .height('100%')
  }
}

@Extend(Text)
function actionButton(color: ResourceColor) {
  .width(80)
  .aspectRatio(1)
  .backgroundColor(color)
  .textAlign(TextAlign.Center)
  .fontColor($r('app.color.white'))
}

@CustomDialog
struct InputDialog {
  controller: CustomDialogController
  @Prop name: string = ''
  onSubmit: (name: string) => void = () => {
  }

  build() {
    Column({ space: 12 }) {
      Text('修改文件名：')
        .height(40)
        .fontWeight(500)
      TextInput({ text: $$this.name })
      Row({ space: 120 }) {
        Text('取消')
          .fontWeight(500)
          .fontColor($r('app.color.common_gray_02'))
          .onClick(() => {
            this.controller.close()
          })
        Text('确认')
          .fontWeight(500)
          .fontColor($r('app.color.common_blue'))
          .onClick(() => {
            this.onSubmit(this.name)
          })
      }
      .height(40)
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .borderRadius(12)
    .width('80%')
    .backgroundColor($r('app.color.white'))
  }
}