import { HmCalendar, HmCalendarSelectedDay } from '@ohmos/calendar'
import { ClockInfo, ClockInfoParams, httpClass, NavBar } from 'basic'

interface DayBuilderParams {
  day: number
  text: string
}

@Entry
@Component
struct ClockInPage {
  //签到信息
  @State
  clockInfo: ClockInfo = {
    flag: false,
    clockinNumbers: 0,
    totalClockinNumber: 0,
    clockins: []
  } as ClockInfo
  //签到的时间
  @State
  selectedDays: HmCalendarSelectedDay[] = []

  async getClockInInfo(params: ClockInfoParams) {
    const res = await httpClass.request<ClockInfo>({
      url: 'hm/clockinInfo',
      params
    })
    this.clockInfo = res
    this.selectedDays = res.clockins.map(item => {
      return { date: item.createdAt } as HmCalendarSelectedDay
    })
  }

  aboutToAppear(): void {
    this.getClockInInfo({
      year: (new Date().getFullYear()).toString(),
      month: (new Date().getMonth() + 1).toString()
    })
  }

  @Builder
  dayBuilder(params: DayBuilderParams) {
    Column() {
      Row() {
        Text(params.day.toString())
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
        Text('天')
          .fontSize(10)
          .fontColor($r('app.color.common_gray_01'))
          .margin({ bottom: 8, left: 10 })
      }
      .alignItems(VerticalAlign.Bottom)

      Text(params.text)
        .fontSize(10)
        .fontColor($r('app.color.common_gray_01'))
    }.margin({ right: 36 })
  }

  build() {
    Column({ space: 16 }) {
      NavBar({ title: '每日打卡', showRightIcon: false })
      Row() {
        this.dayBuilder({ day: 100, text: '累计打卡' })
        this.dayBuilder({ day: 10, text: '连续打卡' })
      }
      .padding({
        top: 10,
        bottom: 25,
        left: 16,
        right: 16
      })
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Row() {
        HmCalendar({
          selectedDays: this.selectedDays,
          onChangeMonth: (month: string) => {
            const arr = month.split('-')
            this.getClockInInfo({
              year: arr[0],
              month: arr[1]
            })
          }
        })
          .borderRadius(8)
          .border({ width: 0.5, color: '#ededed' })
          .shadow({ color: '#ededed', radius: 16 })
          .backgroundColor($r('app.color.white'))
      }
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.clocked_bg'))
    .backgroundImageSize({ width: '100%' })
  }
}