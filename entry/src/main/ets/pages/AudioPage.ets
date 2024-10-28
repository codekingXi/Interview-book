import { abilityAccessCtrl } from '@kit.AbilityKit'
import { promptAction, router } from '@kit.ArkUI'
import { AudioView } from '../views/Audio/AudioView'
import { audioDB } from 'basic'

@Entry
@Component
struct AudioPage {
  async aboutToAppear() {
    this.checkMicroPhonePermission()
    await audioDB.initStore()
  }

  /**
   * 检查并请求麦克风权限
   */
  async checkMicroPhonePermission() {
    // 创建权限管理器实例
    const manager = abilityAccessCtrl.createAtManager()
    // 首次向用户请求权限
    const result = await manager.requestPermissionsFromUser(getContext(), ['ohos.permission.MICROPHONE'])
    // 检查是否所有请求的权限都已授权
    const isPass = result.authResults.every(result => {
      return result === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
    })
    // 首次申请没获得过权限 再申请
    if (!isPass) {
      // 提示用户未授权的风险，并提供前往设置页面的选项
      const confirm = await promptAction.showDialog({
        title: '温馨提示',
        message: '未授权使用麦克风将无法使用应用的面试录音功能,是否前往设置?',
        buttons: [
          { text: '离开', color: $r('app.color.common_gray_01') },
          { text: '去授权', color: $r('app.color.black') }
        ]
      })
      // 用户选择去授权
      if (confirm.index === 1) {
        // 在设置页面请求权限
        const finalResult = await manager.requestPermissionOnSetting(getContext(), ['ohos.permission.MICROPHONE'])
        // 检查最终的权限请求结果
        const finalPass = finalResult.every((result) => {
          return result === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
        })
        // 根据最终结果，显示相应的提示信息
        if (finalPass) {
          promptAction.showToast({
            message: '授权成功'
          })
        } else {
          promptAction.showToast({
            message: '未获得授权'
          })
        }
      } else {
        // 用户选择离开，返回上一页
        router.back()
      }
    }
  }

  // /**
  //  * 录音机*/
  // avRecorder?: media.AVRecorder
  // ///文件路径
  // filePath?: string
  // //文件的唯一标识
  // fd?: number
  // /**
  //  * 播放器*/
  // avPlayer?: media.AVPlayer
  //
  // /**
  //  * 开始录音
  //  */
  // async startRecord() {
  //   //录音文件路径
  //   const filePath = getContext().cacheDir + '/test.m4a'
  //   this.filePath = filePath
  //   //打开或创建录音文件
  //   const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE || fileIo.OpenMode.READ_WRITE)
  //   this.fd = file.fd
  //   //创建AVRecorder实例
  //   const avRecorder = await media.createAVRecorder()
  //   //准备录音
  //   avRecorder.prepare({
  //     audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
  //     url: `fd:${this.fd}`,
  //     profile: {
  //       audioBitrate: 100000, //音频比特率
  //       audioChannels: 1, //音频声道
  //       audioSampleRate: 48000, //音频采样率
  //       audioCodec: media.CodecMimeType.AUDIO_AAC, //录音格式
  //       fileFormat: media.ContainerFormatType.CFT_MPEG_4A //文件类型
  //     }
  //   })
  //   //开启录音
  //   avRecorder.start()
  //   this.avRecorder = avRecorder //同步挂载到对象上
  // }
  //
  // /**
  //  * 停止录音功能
  //  */
  // async stopRecord() {
  //   // 检查avRecorder是否存在，以确保有录音器实例
  //   if (this.avRecorder) {
  //     // 停止录音
  //     await this.avRecorder.stop()
  //     // 释放录音器资源
  //     await this.avRecorder.release()
  //     // 关闭文件描述符对应的文件
  //     fileIo.close(this.fd)
  //   }
  // }
  //
  // /**
  //  * 播放录音文件
  //  */
  // async playRecord() {
  //   // 以只读模式同步打开音频文件
  //   const file = fileIo.openSync(this.filePath, fileIo.OpenMode.READ_ONLY)
  //   // 异步创建一个AVPlayer实例
  //   const avPlayer = await media.createAVPlayer()
  //   // 设置AVPlayer的音频源为当前打开的文件描述符
  //   avPlayer.url = `fd://${file.fd}`
  //   // 监听AVPlayer的状态变化，以在初始化和准备时进行相应的操作
  //   avPlayer.on('stateChange', (state) => {
  //     // 当状态变为初始化时，调用prepare方法进行准备
  //     if (state === 'initialized') {
  //       avPlayer.prepare()
  //     }
  //     // 当状态变为准备时，调用play方法开始播放
  //     if (state === 'prepared') {
  //       avPlayer.play()
  //     }
  //   })
  //   this.avPlayer = avPlayer
  // }

  build() {
    Column() {
      AudioView()
    }
  }
}