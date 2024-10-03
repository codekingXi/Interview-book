import { constants } from '../constants/Constants'
import { window } from '@kit.ArkUI'
import { logger } from '..'

/**
 * StatusBar 状态栏设置
 * @function setDart 深色模式
 * @function setLight 浅色模式
 * */
class StatusBar {

  setDarkBar() {
    this.setBar({statusBarContentColor:"#000000"})
  }

  setLightBar() {
    this.setBar({statusBarContentColor:"#ffffff"})
  }

  async setBar(systemBar: window.SystemBarProperties) {
    try {
      const Context = AppStorage.get<Context>(constants.CONTEXT)
      if (Context) {
        const win = await window.getLastWindow(Context)
        win.setWindowSystemBarProperties(systemBar)
      }
    } catch (e) {
      logger.error("status bar:",JSON.stringify(e))
    }

  }
}

export const statusBar = new StatusBar()