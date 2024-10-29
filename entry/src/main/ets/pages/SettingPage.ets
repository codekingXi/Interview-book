import { promptAction, router } from '@kit.ArkUI';
import { auth, constants, NavBar, User } from 'basic';
import { SettingsThemeDialog } from '../views/Setting/SettingsThemeDialog';
import { bundleManager, ConfigurationConstant } from '@kit.AbilityKit';
import { fileIo, storageStatistics } from '@kit.CoreFileKit';


export interface Tool {
  icon?: ResourceStr
  name: string
  value?: string
  onClick?: () => void,
  radius?: 0 | 1 | 2
}

@Entry
@Component
struct SettingsPage {
  @Builder
  toolsBuilder(tool: Tool) {
    Row() {
      if (tool.icon) {
        Image(tool.icon)
          .width(16)
          .aspectRatio(1)
          .margin({ right: 12 })
      }
      Text(tool.name)
        .fontSize(16)
      Blank()
      if (tool.value) {
        Text(tool.value)
          .fontSize(14)
          .fontColor($r('app.color.common_gray_01'))
          .margin({ right: 10 })
      }
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(18)
        .aspectRatio(1)
        .fillColor($r('app.color.common_gray_01'))
    }
    .height(50)
    .width('100%')
    .backgroundColor($r('app.color.white'))
    .padding({ left: 16, right: 10 })
    .borderRadius({
      topLeft: tool.radius === 1 ? 8 : 0,
      topRight: tool.radius === 1 ? 8 : 0,
      bottomLeft: tool.radius === 2 ? 8 : 0,
      bottomRight: tool.radius === 2 ? 8 : 0
    })
    .onClick(() => {
      tool.onClick && tool.onClick()
    })
  }

  @StorageProp(constants.THEME_KEY)
  colorMode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
  dialog: CustomDialogController = new CustomDialogController({
    builder: SettingsThemeDialog(),
    alignment: DialogAlignment.Bottom,
    customStyle: true
  })
  @State
  cache: string = ''
  @State
  version: string = ''

  calcCache() {
    storageStatistics.getCurrentBundleStats()
      .then(res => {
        this.cache = (res.cacheSize / 1000 / 1000).toFixed(2) + 'MB'
      })
  }

  aboutToAppear(): void {
    this.gerVersion()
  }

  onPageShow(): void {
    this.calcCache()
  }

  //清除缓存
  clearCache() {
    //沙箱的缓存
    const cacheDirPath = getContext().cacheDir
    const ctxContent = fileIo.accessSync(cacheDirPath)
    if (ctxContent) {
      fileIo.rmdirSync(cacheDirPath)
    }
    //应用的缓存
    const appDirPath = getContext().getApplicationContext().cacheDir
    const appCtxContent = fileIo.accessSync(cacheDirPath)
    if (appCtxContent) {
      fileIo.rmdirSync(appDirPath)
    }
    promptAction.showToast({ message: '清除完毕~' })
    this.calcCache()
  }

  // 获取版本号
  gerVersion() {
    this.version =
      'v' + bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
        .versionName
  }

  build() {
    Column() {
      NavBar({ title: '设置', showRightIcon: false, showBorder: true })
      Column({ space: 0.5 }) {
        Blank()
          .height(15)
        this.toolsBuilder({
          name: '编辑资料', radius: 1, onClick: () => {
            auth.checkAuth({
              url: 'pages/ProfilePage'
            })
          }
        })
        this.toolsBuilder({ name: '账号设置', radius: 2 })
        Blank()
          .height(15)
        this.toolsBuilder({ name: '消息推送', radius: 1 })
        this.toolsBuilder({
          name: '深色模式',
          value: this.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT ? '已开启' : '已关闭',
          radius: 1,
          onClick: () => {
            // TODO 设置主题
            this.dialog.open()
          }
        })
        this.toolsBuilder({
          name: '清除应用缓存', value: this.cache, onClick: () => {
            // TODO 清除缓存
            this.clearCache()
          }
        })
        this.toolsBuilder({ name: '当前版本', value: this.version, radius: 2 })
        Blank()
          .height(15)
        Text('退出账号')
          .height(50)
          .fontColor($r('app.color.common_main_color'))
          .opacity(0.6)
          .onClick(async () => {
            auth.setUser({} as User)
            router.back()
          })
      }
      .layoutWeight(1)
      .padding({ right: 15, left: 15 })
      .backgroundColor($r('app.color.common_gray_bg'))
    }
  }
}