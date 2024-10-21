import { preferences } from "@kit.ArkData"
import { constants } from "../../../../Index"

class History {
  story: preferences.Preferences | null = null

  getStory() {
    if (!this.story) {
      const ctx = AppStorage.get<Context>(constants.CONTEXT)
      this.story = preferences.getPreferencesSync(ctx, {
        name: constants.HISTORY_KEY
      })
    }
    return this.story
  }

  //设置一条记录  参数都传value防止出现重复记录
  async setItemHistory(value: string) {
    this.getStory().putSync(value, value)
    await this.getStory().flush()
  }

  //删一条
  async delItemHistory(value: string) {
    this.getStory().deleteSync(value)
    await this.getStory().flush()
  }

  //删全部
  async clearAllHistory() {
    this.getStory().clearSync()
    await this.getStory().flush()
  }

  //拿全部
  getAllHistory() {
    const obj = this.getStory().getAllSync()
    return Object.keys(obj)
  }
}

export const history = new History()