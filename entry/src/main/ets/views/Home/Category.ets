import { ImgComp, QuestionListComp, QuestionType, httpClass } from "basic"

@ComponentV2
export struct Category {
  @Local
  activeIndex: number = 0
  /**
   * 导航列表数据*/
  @Local
  questionList: QuestionType[] | null = null

  //自定义tab结构
  @LocalBuilder
  tabBar(item: QuestionType, index: number) {
    Row() {
      Column() {
        //文字
        Text(item.name)
          .height(40)
          .fontSize(14)
          .fontColor(this.activeIndex === index ? $r('app.color.black') : $r('app.color.common_gray_01'))
        //下划线
        Row()
          .height(2)
          .width(this.activeIndex === index ? 20 : 0)
          .backgroundColor(this.activeIndex === index ? $r('app.color.black') : $r('app.color.common_gray_01'))
          .animation({ duration: this.activeIndex === index ? 300 : 0 })
      }

      //如果类型=1 显示 右侧 new 图标
      if (item.displayNewestFlag === 1) {
        ImgComp({
          imgSrc: $r('app.media.ic_home_new'),
          imgWidth: 32,
          imgHeight: 14,
          marginLeft: 4
        })
      }
    }.padding({ left: 8, right: 8 })
  }

  async getQuestionList() {
    const res = await httpClass.request<QuestionType[]>({
      url: 'hm/question/type'
    })
    this.questionList = res
  }

  aboutToAppear() {
    this.getQuestionList()
  }

  build() {
    Tabs({ barPosition: BarPosition.Start }) {
      ForEach(this.questionList, (item: QuestionType, index: number) => {
        TabContent() {
          QuestionListComp({
            typeId:item.id
          })
            .layoutWeight(1)
        }.tabBar(this.tabBar(item, index))
      })
    }
    .onTabBarClick((i) => {
      this.activeIndex = i
    })
    .barMode(BarMode.Scrollable)
    .scrollable(false)
  }
}