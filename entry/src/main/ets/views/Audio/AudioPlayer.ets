import { media } from '@kit.MediaKit'
import { fileIo } from '@kit.CoreFileKit'
import { InterviewAudioItem, logger } from 'basic'

@Component
export struct AudioPlayer {
  @State
  playing: boolean = false
  //当前播放的音频
  @Prop currentItem: InterviewAudioItem = {} as InterviewAudioItem
  avPlayer?: media.AVPlayer
  @State total: number = 0
  @State value: number = 0
  @Link
  isShow: boolean

  async startPlay() {
    try {
      const file = fileIo.openSync(this.currentItem.path, fileIo.OpenMode.READ_ONLY)
      const avPlayer = await media.createAVPlayer()
      avPlayer.on('stateChange', state => {
        if (state === 'initialized') {
          avPlayer.prepare()
        } else if (state === 'prepared') {
          avPlayer.loop = true
          this.total = avPlayer.duration
          avPlayer.play()
        }
      })
      // 当前播放时间改变
      avPlayer.on('timeUpdate', (time) => {
        this.value = time
      })
      avPlayer.url = `fd://${file.fd}`
      this.avPlayer = avPlayer
      this.playing = true
    } catch (e) {
      logger.error('startPlay', JSON.stringify(e))
    }
  }

  stopPlay() {
    if (this.avPlayer) {
      this.avPlayer.stop()
      this.avPlayer.release()
      this.playing = false
    }
  }

  aboutToAppear(): void {
    if (this.playing) {
      this.stopPlay()
    }
  }

  build() {
    Column({ space: 20 }) {
      Image($r('app.media.ic_mine_audio'))
        .width(100)
        .aspectRatio(1)
      Text(this.currentItem.name)
        .fontSize(18)

      Row({ space: 20 }) {
        Image(!this.playing ? $r('sys.media.ohos_ic_public_play') : $r('sys.media.ohos_ic_public_pause'))
          .width(24)
          .aspectRatio(1)
          .onClick(() => {
            if (!this.playing) {
              this.startPlay()
            } else {
              this.stopPlay()
            }
          })
        Progress({ value: this.value, total: this.total })
          .layoutWeight(1)
          .margin({ top: 20, bottom: 20 })
      }
      .width('80%')

      Button('返回')
        .onClick(() => {
          this.isShow = false
        })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.white'))
    .onDisAppear(() => {
      this.stopPlay()
    })
  }
}