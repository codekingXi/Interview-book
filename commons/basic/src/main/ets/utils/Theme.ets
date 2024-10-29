import { constants } from "../../../../Index"
import { common, ConfigurationConstant } from "@kit.AbilityKit"

class Theme {
  //1.持久化
  initTheme() {
    PersistentStorage.persistProp(constants.THEME_KEY, ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
    const theme = AppStorage.get<ConfigurationConstant.ColorMode>(constants.THEME_KEY)
    this.setTheme(theme!)
  }

  //2.主题设置
  setTheme(theme: ConfigurationConstant.ColorMode) {
    //页面点击设置
    AppStorage.set(constants.THEME_KEY, theme)
    //应用设置
    getContext().getApplicationContext().setColorMode(theme)
    //拿到上下文
    const ctx = AppStorage.get<Context>(constants.CONTEXT);
    //标记
    const isDark = (ctx as common.UIAbilityContext).config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK
    AppStorage.setOrCreate(constants.IS_DARK, isDark)
    //遗留问题 系统切换颜色模式的时候 暂时检测不到 公共事件订阅 没有API支持
  }

  //3.跟随系统
  notSetTheme() {
    this.setTheme(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
  }

  //4.深色模式
  darkTheme() {
    this.setTheme(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
  }

  //5.浅色模式
  lightTheme() {
    this.setTheme(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
  }
}

export const theme = new Theme()