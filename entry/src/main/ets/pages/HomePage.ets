import { Banner, bannerArr, CalendarComp, ClocKIn, DataSource, ImgComp, SearchNav } from "basic"

@ComponentV2
export struct HomePage {
  @Builder
  scan() {
    ImgComp({
      imgSrc: $r('app.media.ic_home_scan'),
      imgWidth: 20
    })
  }

  @Builder
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
      .interval(2000)
      .autoPlay(true)
      .loop(true)
      .margin({ top: 16, bottom: 16 })
      .indicator(DotIndicator.dot()
        .itemWidth(4)
        .bottom(4)
        .selectedColor($r('app.color.white'))
        .selectedItemHeight(6))

      //日历
      CalendarComp()
    }
    .margin({ left: 16, right: 16 })
    .height('100%')
  }
}