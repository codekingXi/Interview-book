import { Banner, bannerArr, CalendarComp, ClocKIn, DataSource, ImgComp, SearchNav } from "basic"
import { Category } from "../views/Home"

@ComponentV2
export struct HomePage {
  @LocalBuilder
  scan() {
    ImgComp({
      imgSrc: $r('app.media.ic_home_scan'),
      imgWidth: 20
    })
  }

  @LocalBuilder
  Clock() {
    ClocKIn({ clockCount: 1 })
      .onClick(() => {

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
    .margin({ left: 16, right: 16 })
    .height('100%')
  }
}