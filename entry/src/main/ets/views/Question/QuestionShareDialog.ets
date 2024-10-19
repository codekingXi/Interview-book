import { logger, QuestionDetail, User, UserStoreKey } from "basic"
import { componentSnapshot, promptAction } from "@kit.ArkUI"
import { photoAccessHelper } from "@kit.MediaLibraryKit"
import { image } from "@kit.ImageKit"
import { fileIo } from "@kit.CoreFileKit"

const share = 'share'

@CustomDialog
export struct QuestionShareDialog {
  @Prop item: QuestionDetail = {} as QuestionDetail
  @StorageProp(UserStoreKey) user: User = {} as User
  controller: CustomDialogController

  /**
   * 保存图片*/
  async saveImage() {
    ///截图
    const pixelMap = await componentSnapshot.get(share)
    //图片数据处理
    //创建图片压缩器
    const packer = image.createImagePacker()
    //压缩图片
    const buffer = await packer.packing(pixelMap, { format: 'image/jpeg', quality: 98 })
    //获取上下文,在沙箱中创建文件
    const ctx = getContext()
    //定义存放文件的路径
    const filePath = ctx.cacheDir + '/' + Date.now() + '.jpg' //放在缓存目录
    //文件创建
    const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
    //给文件写入压缩后的图片数据
    fileIo.writeSync(file.fd, buffer)
    //必须关闭文件 否则会一直处于打开的状态
    fileIo.closeSync(file)
    //创建工具 保存到相册
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(ctx)
    //储存请求发起
    const assetChangeRequest: photoAccessHelper.MediaAssetChangeRequest =
      photoAccessHelper.MediaAssetChangeRequest.createImageAssetRequest(ctx, filePath)
    //开启保存
    await phAccessHelper.applyChanges(assetChangeRequest)
    //提示
    promptAction.showToast({ message: '图片保存成功' })
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column({ space: 20 }) {
        Image($r('app.media.ic_interview_logo'))
          .width(40)
          .height(40)
        Text('面试通，搞定企业面试题')
        Divider()
          .strokeWidth(0.5)
          .color($r('app.color.common_gray_border'))
        Text('大厂面试题：' + this.item.stem)
          .fontSize(12)
          .maxLines(2)
          .fontWeight(600)
          .width('100%')
          .lineHeight(24)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row() {
          QRCode(this.item.id)
            .width(160)
            .height(160)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Text('扫码查看答案')
          .fontSize(12)
          .alignSelf(ItemAlign.Center)
        Blank()
        Text('分享来自：' + this.user.username || this.user.nickName)
          .fontSize(12)
      }
      .id(share)
      .padding(20)
      .alignItems(HorizontalAlign.Start)
      .width(300)
      .height(500)
      .backgroundColor($r('app.color.white'))

      Row() {
        SaveButton()
          .fontColor($r('app.color.white'))
          .fontSize(14)
          .padding(12)
          .backgroundColor($r('app.color.common_main_color'))
          .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
            if (result === SaveButtonOnClickResult.SUCCESS) {
              try {
                this.saveImage()
              } catch (error) {
                promptAction.showToast({ message: '图片保存失败\n' + 'error is' + JSON.stringify(error) })
                logger.error('error is ' + JSON.stringify(error))
              }
            }
          })
      }.margin({ right: 10, bottom: 10 })

    }
    .borderRadius(8)
    .clip(true)
  }
}