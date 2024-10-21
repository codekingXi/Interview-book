import { constants, httpClass, logger } from '../../../../Index'
import { TimeItem } from '../models/TimeModel'
import { preferences } from '@kit.ArkData'

class Tracking {
  //缓存列表
  list: TimeItem[] = []
  //首选项仓库
  store: preferences.Preferences |null = null

  /**
   * 获取仓库信息
   * @returns {preferences} 返回首选项仓库数据
   */
  getStore() {
    // 检查当前实例是否已经有一个存储对象，如果没有，则进行初始化
    if (!this.store) {
      // 从AppStorage中获取当前应用上下文，这里指定类型为Context
      const ctx = AppStorage.get<Context>(constants.CONTEXT)
      // 使用获取的上下文和一个预定义的名字常量来初始化存储对象
      this.store = preferences.getPreferencesSync(ctx, {
        name: constants.TRACKING_STORY
      })
    }
    // 返回初始化或已存在的存储对象
    return this.store
  }

  /**
   * 记录埋点信息
   * @param QuestionId 问题项的唯一标识符
   * @param startTime 用户开始回答问题的时间戳
   * @param endTime 用户结束回答问题的时间戳
   */
  async record(QuestionId: string, startTime: number, endTime: number) {
    // 原来的数组
    const json = this.getStore().getSync(constants.TRACK_LIST, '[]')
    this.list = JSON.parse(json as string) as TimeItem[]

    // 新增的数组
    this.list.push({
      QuestionId,
      startTime,
      endTime
    })

    // 完整的数组
    // 将更新后的列表数据重新存入实例中
    this.getStore().putSync(constants.TRACK_LIST, JSON.stringify(this.list))
    await this.getStore().flush()

    // 记录日志，输出当前时间段列表的JSON字符串
    logger.info(JSON.stringify(this.list))
  }

  /**
   * 上报时间跟踪数据
   * 当跟踪数据积累到一定量时，或调用此函数时指定强制上报，则将数据上报到服务器
   * @param force 是否强制上报，即使数据未达到上报阈值，默认为 false
   */
  async report(force: boolean = false) {
    const json = this.getStore().getSync(constants.TRACK_LIST, '[]')
    const list = JSON.parse(json as string) as TimeItem[]
    // 当数据积累到 5 条或以上，或在强制上报模式下且数据不为空时，执行上报
    if (list.length >= 5 || (force && list.length)) {
      // 发起 HTTP 请求，将跟踪数据上报到服务器
      httpClass.request<null>({
        url: 'hm/time/tracking',
        method: 'post',
        data: {
          timeList: this.list
        }
        //data 是 body 参数，params 是 url 参数
      })
      // 上报后，重置本地实例中的数据
      this.getStore().putSync(constants.TRACK_LIST, '[]')
      await this.getStore().flush()
    }
  }
}

/**
 * 埋点上报*/
export const tracking = new Tracking()