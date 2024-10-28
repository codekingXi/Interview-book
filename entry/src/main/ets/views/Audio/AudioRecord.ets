import { audioDB, auth, constants } from 'basic'
import { fileIo } from '@kit.CoreFileKit'
import { media } from '@kit.MediaKit'
import dayjs from '@hview/dayjs'
import { promptAction } from '@kit.ArkUI'

@Component
export struct AudioRecordComp {
  @StorageProp(constants.BOTTOM_AREA) bottomHeight: number = 0
  @State
  isRecording: boolean = false
  @State
  startTime: number = 0
  //录音文件标识
  fd?: number
  //录音文件路径
  filePath?: string
  timer?: number
  avRecorder?: media.AVRecorder
  @State
  maxAmplitude: number = 0

  /**
   * 异步开始录音
   *
   * 此方法用于初始化和开始录音过程它执行以下操作：
   * 1. 创建一个文件以接收录音数据
   * 2. 准备AVRecorder配置对象，包括音频源类型、音频配置参数和文件路径
   * 3. 创建并准备AVRecorder实例，然后开始录音
   * 4. 设置定时器以定期获取和更新最大振幅
   */
  async startRecord() {
    // 记录开始录音的时间
    this.startTime = Date.now()
    // 1. 准备一个文件接收录音
    const ctx = getContext(this)
    const filePath = ctx.filesDir + '/' + Date.now() + '.m4a'
    this.filePath = filePath
    const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
    this.fd = file.fd
    // 2. 准备路由配置对象
    const config: media.AVRecorderConfig = {
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
      profile: {
        audioBitrate: 100000, // 音频比特率
        audioChannels: 1, // 音频声道数
        audioCodec: media.CodecMimeType.AUDIO_AAC, // 音频编码格式，当前只支持aac
        audioSampleRate: 48000, // 音频采样率
        fileFormat: media.ContainerFormatType.CFT_MPEG_4A, // 封装格式，当前只支持m4a
      },
      url: `fd://${file.fd}`
    }
    // 3. 开始录制
    const avRecorder = await media.createAVRecorder()
    await avRecorder.prepare(config)
    await avRecorder.start()
    this.avRecorder = avRecorder
    // 4. 每100ms获取一下声音振幅
    this.timer = setInterval(async () => {
      this.maxAmplitude = await avRecorder.getAudioCapturerMaxAmplitude()
    }, 100)
  }

  /**
   * 停止录音功能
   */
  async stopRecord() {
    // 检查avRecorder实例是否存在
    if (this.avRecorder) {
      try {
        // 清除定时器，停止记录音频信息
        clearInterval(this.timer)
        // 停止录音操作
        await this.avRecorder.stop()
        // 释放录音资源
        await this.avRecorder.release()
        // 同步关闭文件描述符，完成录音文件的写入
        fileIo.closeSync(this.fd)
        // 重置最大振幅值
        this.maxAmplitude = 0
        //写入数据库
        await audioDB.insert({
          id: null,
          user_id: auth.getUser().id,
          name: dayjs().format('YYYY年MM月DD日_HH时mm分'),
          path: this.filePath || '',
          duration: Date.now() - this.startTime,
          size: fileIo.statSync(this.filePath).size,
          create_time: Date.now()
        })
        //更新列表
        getContext().eventHub.emit(constants.UPDATE_RECORD_LIST)
      } catch (e) {
        promptAction.showToast({
          message: 'error' + JSON.stringify(e)
        })
      }
    }
  }

  build() {
    Column() {
      AudioBoComp({ maxAmplitude: this.maxAmplitude })
      Row() {
        Image($r('sys.media.ohos_ic_public_voice'))
          .width(24)
          .aspectRatio(1)
          .fillColor(this.isRecording ? $r('app.color.common_green') : $r('app.color.white'))
          .onClick(async () => {
            // TODO 开始和停止录音
            if (this.isRecording) {
              await this.stopRecord()
              this.isRecording = false
            } else {
              await this.startRecord()
              this.isRecording = true
            }
          })
      }
      .justifyContent(FlexAlign.Center)
      .height(50)
      .width(50)
      .borderRadius(25)
      .margin({ top: 20 })
      .backgroundColor($r('app.color.black'))
    }
    .width('100%')
    .height(240)
    .backgroundColor($r('app.color.common_gray_bg'))
    .padding({
      bottom: this.bottomHeight,
      left: 80,
      right: 80,
      top: 20
    })
  }
}

@Component
export struct AudioBoComp {
  @Prop @Watch('onChange') maxAmplitude: number
  @State per: number = 0

  onChange() {
    animateTo({ duration: 100 }, () => {
      if (this.maxAmplitude < 500) {
        this.per = 0
      } else if (this.maxAmplitude > 30000) {
        this.per = 1
      } else {
        this.per = this.maxAmplitude / 30000
      }
    })
  }

  build() {
    Row({ space: 5 }) {
      ForEach(Array.from({ length: 30 }), () => {
        Column()
          .layoutWeight(1)
          .height(this.per * 100 * Math.random())
          .backgroundColor($r('app.color.common_blue'))
      })
    }
    .width('100%')
    .height(100)
    .backgroundColor($r('app.color.common_gray_bg'))
  }
}
