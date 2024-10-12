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