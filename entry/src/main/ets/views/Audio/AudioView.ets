import { audioDB, auth, constants, InterviewAudioItem, NavBar } from "basic"
import { AudioItemComp } from "./AudioItemComp"
import { AudioRecordComp } from "./AudioRecord"


@Component
export struct AudioView {
  @State list: InterviewAudioItem[] = []

  aboutToAppear(): void {
    getContext().eventHub.on(constants.UPDATE_RECORD_LIST, () => {
      //更新列表
      this.updateList()
    })
  }

  async updateList() {
    const userid = auth.getUser().id
    this.list = await audioDB.query(userid)
  }

  build() {
    Column() {
      NavBar({ title: '面试录音', showRightIcon: false })
      Column() {
        List() {
          ForEach(this.list, (item: InterviewAudioItem) => {
            ListItem() {
              AudioItemComp({
                item
              })
            }
          })
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .layoutWeight(1)

      AudioRecordComp()
    }
    .width('100%')
    .height('100%')
  }
}