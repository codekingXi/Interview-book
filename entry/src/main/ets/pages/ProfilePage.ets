import { auth, httpClass, LoadingDialogComp, NavBar, User, UserStoreKey } from 'basic'
import { promptAction } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { fileIo } from '@kit.CoreFileKit'
import { FormData } from '@ohos/axios'

@Entry
@Component
struct ProfilePage {
  @StorageProp(UserStoreKey) user: User = {} as User
  dialog: CustomDialogController = new CustomDialogController({
    builder: LoadingDialogComp({ msg: '更新中...' }),
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  //修改昵称
  async UpdateNickUser() {
    await httpClass.request<null, User>({
      url: 'hm/userInfo/profile',
      method: 'post',
      data: { nickName: this.user.nickName } as User
    })
    promptAction.showToast({ message: '昵称修改成功' })
    auth.setUser(this.user)
  }

  //修改头像
  async UpdateAvatar() {
    //1. 调起相册选择图片
    const picker = new photoAccessHelper.PhotoViewPicker()
    const result = await picker.select({
      MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
      maxSelectNumber: 1
    })
    //图片路径
    const uri = result.photoUris[0]
    this.dialog.open()
    const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
    fileIo.copyFileSync(file.fd, getContext().cacheDir + '/' + file.name)
    fileIo.closeSync(file.fd)
    const formData = new FormData()
    formData.append('file', 'internal://cache/' + file.name)
    await httpClass.request<string>({
      url: 'hm/userInfo/avatar',
      method: 'post',
      data: formData,
      context: getContext(),
      headers: {
        "Content-Type": "multipart/form-data"
      }
    })
    //更新头像
    const user = await httpClass.request<User, User>({ url: 'hm/userInfo' })
    //当前展示的更新
    this.user.avatar = user.avatar
    //本地更新
    auth.setUser(this.user)
    promptAction.showToast({ message: '头像修改成功' })
    this.dialog.close()

  }

  build() {
    Column() {
      NavBar({ title: '编辑资料', showRightIcon: false })
      List() {
        ListItem() {
          Row() {
            Text('头像')
            Image(this.user.avatar || $r('app.media.ic_mine_avatar'))
              .alt($r('app.media.ic_mine_avatar'))
              .width(40)
              .aspectRatio(1)
              .borderRadius(20)
              .border({ width: 0.5, color: $r('app.color.common_gray_border') })
              .onClick(() => {
                // TODO 更新头像
                this.UpdateAvatar()
              })
          }
          .width('100%')
          .height(60)
          .justifyContent(FlexAlign.SpaceBetween)
        }

        ListItem() {
          Row() {
            Text('昵称')
            TextInput({ text: this.user.username })
              .fontColor($r('app.color.common_gray_03'))
              .textAlign(TextAlign.End)
              .layoutWeight(1)
              .padding(0)
              .height(60)
              .backgroundColor($r('app.color.white'))
              .borderRadius(0)
              .onChange((value) => this.user.username = value)
              .onSubmit(() => {
                // TODO 更新昵称
                this.UpdateNickUser()
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 35,
        right: 35,
        top: 15,
        bottom: 15
      })
      .divider({ strokeWidth: 0.5, color: $r('app.color.common_gray_bg') })
    }
  }
}