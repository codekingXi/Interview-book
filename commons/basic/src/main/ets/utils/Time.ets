import { promptAction, router } from "@kit.ArkUI"
import { auth, httpClass } from "../../../../Index"

const min = 60
const hour = 60 * 60
const day = 60 * 60 * 24

export function formatTime(second: number = 0) {
  if (second > day) {
    return (second / day).toFixed(1) + '天'
  } else
    if (second > hour) {
      return (second / hour).toFixed(1) + '小时'
    } else
    if (second > min) {
      return (second / min).toFixed(1) + '分'
    } else {
    return '暂无数据'
  }
}

interface ClockRes {
  clockinNumbers: number
}

export const requestClockIn = async () => {
  const user = auth.getUser()
  if (user.token) {
    //登录了
    if (user.clockinNumbers === 0) {
      //没打卡 就打卡
      const res = await httpClass.request<ClockRes>({
        url: '/hm/clockin',
        method: 'post'
      })
      user.clockinNumbers = res.clockinNumbers
      promptAction.showToast({ message: '打卡成功' })
      auth.setUser(user)
    }
    //跳转
    router.pushUrl({
      url: 'pages/ClockInPage'
    })
  } else {
    router.pushUrl({
      url: 'pages/LoginPage'
    })
  }
}
/**
 * 计算百分比*/
export const calePercent = (done: number, total: number) => {
  return Math.round((done / total * 100)).toString() + '%'
}