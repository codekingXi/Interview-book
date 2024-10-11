import { window } from '@kit.ArkUI'
import { constants } from '../constants/Constants'
import { logger } from '..'


export class FullScreen {
  topHeight: number = 0 //顶部高度
  bottomHeight: number = 0 //底部高度
  /**
   * 开启沉浸式*/
  async enable() {
    try {
      //获取上下文
      const Context = AppStorage.get<Context>(constants.CONTEXT)
      if (Context) {
        const win = await window.getLastWindow(Context) //传入上下文
        await win.setWindowLayoutFullScreen(true) //开启沉浸式
        //顶部安全区域高度
        this.topHeight = px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height)
        AppStorage.setOrCreate(constants.TOP_AREA,this.topHeight)
        //底部安全区域高度
        this.bottomHeight =
          px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height)
        AppStorage.setOrCreate(constants.BOTTOM_AREA,this.bottomHeight)
        logger.info('Full screen, success')
      }
    } catch (e) {
      logger.error('Full screen, error', JSON.stringify(e))
    }
  }

  /**
   * 关闭沉浸式*/
  async disable() {
    try {
      //获取上下文
      const Context = AppStorage.get<Context>(constants.CONTEXT)
      if (Context) {
        const win = await window.getLastWindow(Context) //传入上下文
        win.setWindowLayoutFullScreen(false) //关闭沉浸式
        //关闭安全区避让
        AppStorage.set(constants.TOP_AREA,0)
        AppStorage.set(constants.BOTTOM_AREA,0)
        logger.info('Full screen disable, success')
      }
    } catch (e) {
      logger.error('Full screen, error', JSON.stringify(e))
    }
  }
}

/**
 * 全屏沉浸式类
 * @function enable 开启全局沉浸式
 * @function disable 关闭全局沉浸式
 * */
export const fullScreen = new FullScreen()