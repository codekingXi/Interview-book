import { QuestionDay } from "./Questionday"

@Component
export struct CalendarComp {
  @Provide monthArr: string[] = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC']
  @Provide month: number = 0 //月份 0-11
  @Provide date: number = 1 //号数 1--31
  @Provide day: number = 30 //默认30天
  @Provide offsetDay: number = 0 //偏移天数

  aboutToAppear(): void {
    const dateObj = new Date() //直接定义日期对象 后续方便实现复杂功能
    //获取 月 日
    this.month = dateObj.getMonth()
    this.date = dateObj.getDate()
    //下个月-这个月的时间戳  今年的    下个月 getMonth是0开头（0-11）(下个月+2) - (这个月的+1))
    const nextTemp =
      new Date(dateObj.getFullYear() + '-' + (dateObj.getMonth() + 2) + '-' + dateObj.getDate()).getTime()
    const currentTemp =
      new Date(dateObj.getFullYear() + '-' + (dateObj.getMonth() + 1) + '-' + dateObj.getDate()).getTime()
    //本月天数
    this.day = (nextTemp - currentTemp) / (1000 * 60 * 60 * 24)
    //0代表周日 1-6代表周一至周6
    this.offsetDay = new Date(dateObj.getFullYear() + '-' + (dateObj.getMonth() + 1)).getDay()
  }

  build() {
    Row() {
      //文字日历
      CalendarTextBox()
      //每日推荐文字
      QuestionDay()
      //日期
      DateComp()
    }
    .width('100%')
    .height(80)
    .borderRadius(6)
    .backgroundColor($r('app.color.common_gray_bg'))
  }
}

@Component
struct DateComp {
  @Consume offsetDay: number
  @Consume date: number
  @Consume day: number

  build() {
    Column() {
      GridRow({ columns: 7, gutter: 6 }) {
        //美化日期UI的结构 空圆点
        ForEach(//Array(6).fill(() => 1),
          Array(this.offsetDay === 0 ? 6 : this.offsetDay).fill(() => 1),
          () => {
            GridCol()
          })
        //当前日期 实色圆点
        ForEach(//Array(30).fill(() => 1),
          Array(this.day).fill(() => 1),
          (item: object, index: number) => {
            GridCol() {
              Row()
                .width(6)
                .aspectRatio(1)
                .borderRadius(3)
                .backgroundColor(this.date === (index + 1) ? Color.Green : '#ff989898')
            }
          })
      }
      .padding({ right: 5 })
    }.width(120)
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

@Component
export struct CalendarTextBox {
  @Consume monthArr: string[]
  @Consume month: number
  @Consume date: number

  build() {
    Column({ space: 6 }) {
      Text(this.monthArr[this.month])
        .fontColor(Color.Red)
      Text(this.date.toString().padStart(2, '0'))
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
    }
    .padding(12)
    .backgroundColor($r('app.color.white'))
    .borderRadius(12)
    .shadow({ radius: 20, color: '#ff4c4c4c' })
    .position({ x: 16, y: -16 })
  }
}