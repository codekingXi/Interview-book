import {
  auth,
  Banner,
  bannerArr,
  CalendarComp,
  ClocKIn,
  constants,
  DataSource,
  HttpClass,
  ImgComp,
  QuestionDetail,
  requestClockIn,
  SearchNav,
  tracking,
  User,
  UserStoreKey
} from "basic"
import { Category } from "../views/Home"
import { scanBarcode } from "@kit.ScanKit"
import { promptAction, router } from "@kit.ArkUI"

@Component
export struct HomePage {
  @StorageProp(constants.TOP_AREA)
  topHeight: number = 0
  @StorageProp(UserStoreKey)
  User: User = {} as User

  /**
   * 扫码*/
  async scanCode() {
    //如果系统支持扫码
    if (canIUse('SystemCapability.Multimedia.Scan.ScanBarcode')) {
      //唤起扫码界面
      const res = await scanBarcode.startScanForResult(getContext())
      const item = await HttpClass.request<QuestionDetail>({
        url: '/hm/question/' + res.originalValue
      })
      if (item) {
        //跳转至问题详情页
        router.pushUrl({
          url: 'pages/QuestionPage',
          params: {
            item,
            list: [item]
          }
        })
      } else {
        promptAction.showToast({ message: '请扫描来自面试通分享的二维码' })
      }
    } else {
      promptAction.showToast({ message: '当前设备不支持扫码' })
    }
  }

  aboutToAppear(): void {
    tracking.report(true)
  }

  @Builder
  scan() {
    ImgComp({
      imgSrc: $r('app.media.ic_home_scan'),
      imgWidth: 20
    })
      .onClick(() => {
        auth.checkAuth(() => {
          this.scanCode()
        })
      })
  }

  @Builder
  Clock() {
    ClocKIn({ clockCount: this.User.clockinNumbers })
      .onClick(() => {
        requestClockIn()
      })
  }

  //懒加载数据源
  bannerData = new DataSource<Banner>(bannerArr)

  build() {
    Column() {
      //搜索栏
      SearchNav({
        leftContent: () => {
          this.scan()
        },
        rightContent: () => {
          this.Clock()
        },
        imgSrc: $r('app.media.ic_common_search'),
        imgWidth: 14,
        layoutWeightValue: 1
      })
      //轮播图
      Swiper() {
        LazyForEach(this.bannerData, (item: Banner) => {
          ImgComp({
            imgSrc: item.src,
            imgWidth: '100%',
            aspectRatioValue: 2.65
          })
        })
      }
      .margin({ top: 10, bottom: 10 })
      .interval(2000)
      .autoPlay(true)
      .loop(true)
      .indicator(DotIndicator.dot()
        .itemWidth(4)
        .bottom(4)
        .selectedColor($r('app.color.white'))
        .selectedItemHeight(6))

      //日历
      CalendarComp()
      //试题分类
      Column() {
        Category()
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor($r('app.color.white'))
    }
    .margin({ left: 16, top: this.topHeight, right: 16 })
    .height('100%')
  }
}