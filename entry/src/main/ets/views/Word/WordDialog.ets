import { media } from "@kit.MediaKit"

@CustomDialog
export struct WordDialog {
  controller: CustomDialogController
  @Prop en: string = ''
  @Prop zh: string = ''
  avPlayer?: media.AVPlayer

  async aboutToAppear() {
    //创建播放器
    const avPlay = await media.createAVPlayer()
    //设置媒体资源地址  使用有道翻译的API
    avPlay.url = `https://dict.youdao.com/dictvoice?type=1&audio=${this.en}`
    //监听状态变化
    avPlay.on('stateChange', state => {
      if (state === 'initialized') {
        //准备
        avPlay.prepare()
      }
      if (state === 'prepared') {
        //播放
        avPlay.play()
      }
      //挂载到播放对象上
      this.avPlayer = avPlay
    })
  }

  aboutToDisappear(): void {
    //销毁播放器 否则会出现内存泄露的现象
    if (this.avPlayer) {
      this.avPlayer.stop() //停止播放
      this.avPlayer.release() //释放资源
    }
  }

  build() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        Text(this.en)
          .fontSize(20)
          .fontColor($r('app.color.white'))
          .fontWeight(500)
        WordSoundComp()
      }

      Text(this.zh)
        .fontColor($r('app.color.white'))
    }
    .constraintSize({ minWidth: 175 })
    .padding({ left: 16, right: 16 })
    .height(90)
    .borderRadius(45)
    .backgroundColor('#8f000000')
    .justifyContent(FlexAlign.Center)
  }
}

@Component
struct WordSoundComp {
  @State flag: boolean = false
  timerId?: number

  aboutToAppear(): void {
    this.timerId = setInterval(() => {
      this.flag = !this.flag
    }, 500)
  }

  aboutToDisappear(): void {
    clearInterval(this.timerId)
  }

  build() {
    Image($r('sys.media.ohos_ic_public_sound'))
      .width(20)
      .aspectRatio(1)
      .fillColor(this.flag ? $r('app.color.common_green') : $r('app.color.white'))
  }
}