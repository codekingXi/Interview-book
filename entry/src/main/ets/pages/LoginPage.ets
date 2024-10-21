import { auth, constants, httpClass, LoginParam, NavBar, tracking, User, UserStoreKey } from 'basic'
import { promptAction, router } from '@kit.ArkUI'

@Entry
@Component
struct LoginPage {
  @StorageProp(constants.TOP_AREA)
  topHeight: number = 0
  @State
  mobile: string = 'hmheima'
  @State
  code: string = 'Hmheima%123'
  @State
  isAgree: boolean = false
  @State
  loading: boolean = false

  async login() {
    if (this.loading) {
      return
    }
    if (!this.mobile) {
      return promptAction.showToast({ message: '请输入用户名' })
    }
    if (!this.code) {
      return promptAction.showToast({ message: '请输入密码' })
    }
    if (!this.isAgree) {
      return promptAction.showToast({ message: '请阅读并勾选用户协议' })
    }
    this.loading = true
    const user = await httpClass.request<User, LoginParam>({
      url: 'hm/login',
      method: 'post',
      data: {
        username: this.mobile,
        password: this.code
      }
    })
    this.loading = false
    auth.setUser(user)
    tracking.report(true)
    //发送事件
    getContext().eventHub.emit(UserStoreKey)
    const params = router.getParams() as Record<string, string>
    if (params) {
      router.replaceUrl({
        url: params.return_url,
        params
      })
    } else {
      router.back()
    }
  }

  build() {
    Column() {
      NavBar({ showRightIcon: false })
      Column() {
        Image($r('app.media.icon'))
          .width(120)
          .aspectRatio(1)
        Text('面试通')
          .fontSize(28)
          .margin({ bottom: 15 })
        Text('搞定企业面试真题，就用面试通')
          .fontSize(14)
          .fontColor($r('app.color.common_gray_01'))
      }
      .padding(16)

      Column({ space: 15 }) {
        TextInput({ placeholder: '请输入用户名', text: $$this.mobile })
          .customStyle()
        TextInput({ placeholder: '请输入密码', text: $$this.code })
          .type(InputType.Password)
          .showPasswordIcon(false)
          .customStyle()
        Row() {
          Checkbox()
            .shape(CheckBoxShape.ROUNDED_SQUARE)
            .selectedColor('#fa711d')
            .size({ width: 14, height: 14 })
            .select(this.isAgree)
            .onChange((val) => {
              this.isAgree = val
            })
          Text('已阅读并同意')
            .fontSize(14)
            .fontColor($r('app.color.common_gray_01'))
            .padding({ right: 4 })
          Text('用户协议')
            .fontSize(14)
            .padding({ right: 4 })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/WebPage',
                params: {
                  title: '用户协议',
                  src: 'http://110.41.143.89/user'
                }
              })
            })
          Text('和')
            .fontSize(14)
            .fontColor($r('app.color.common_gray_01'))
            .padding({ right: 4 })
          Text('隐私政策')
            .fontSize(14)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/WebPage',
                params: {
                  title: '隐私政策',
                  src: 'http://110.41.143.89/privacy'
                }
              })
            })
        }
        .width('100%')

        Button({ type: ButtonType.Normal }) {
          Row() {
            if (this.loading) {
              LoadingProgress()
                .color($r('app.color.white'))
                .width(24)
                .height(24)
                .margin({ right: 10 })
            }
            Text('立即登录')
              .fontColor($r('app.color.white'))
          }
        }
        .width('100%')
        .backgroundColor('none')
        .borderRadius(4)
        .height(44)
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [['#fc9c1c', 0], ['#fa711d', 1]]
        })
        .stateEffect(false)
        .onClick(() => {
          // TODO
          this.login()
        })
      }
      .padding({
        left: 36,
        right: 36,
        top: 30,
        bottom: 16
      })

      Column({ space: 6 }) {
        Text('其他登录方式')
          .fontSize(14)
          .fontColor($r('app.color.common_gray_01'))
        Image($r('sys.media.huawei_id_logo_red'))
          .width(32)
          .aspectRatio(1)
      }
      .width('100%')
      .height('100%')
    }
  }
}

@Extend(TextInput)
function customStyle() {
  .placeholderColor('#C3C3C5')
  .caretColor('#fa711d')
  .height(44)
  .borderRadius(0)
  .backgroundColor($r('app.color.white'))
  .border({ width: { bottom: 0.5 }, color: $r('app.color.common_gray_border') })
}
