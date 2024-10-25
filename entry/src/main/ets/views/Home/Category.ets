import {
  ImgComp,
  QuestionListComp,
  QuestionType,
  httpClass,
  SortType,
  Skeleton,
  SkeletonItem,
  UserStoreKey
} from "basic"

@Component
export struct Category {
  @State
  activeIndex: number = 0
  @State
  sortType: SortType = SortType.Default
  @State
  filterIndex: number = 0
  @State
  filterSort: SortType = SortType.Default
  /**
   * 导航列表数据*/
  @State
  questionList: QuestionType[] = []
  @State
  showDialog: boolean = false
  tabController: TabsController = new TabsController()
  /**
   * 是否显示骨架屏*/
  @State
  loading: boolean = false

  //自定义tab结构
  @Builder
  tabBar(item: QuestionType, index: number) {
    Row() {
      Column({ space: 2 }) {
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
    .margin({ right: item.name === '性能优化' ? 22 : 0 })
  }

  async getQuestionList() {
    this.loading = true
    const res = await httpClass.request<QuestionType[]>({
      url: 'hm/question/type'
    })
    this.questionList = res
    this.loading = false
  }

  aboutToAppear() {
    //默认请求一次数据
    this.getQuestionList()
    // 线程内监听事件  保障数据更新
    getContext().eventHub.on(UserStoreKey, () => {
      //获取列表数据
      this.getQuestionList()
    })
  }

  @Builder
  fillterDialog() {
    Column() {
      Row() {
        Text('重置')
          .fontSize(16)
          .fontWeight(500)
          .fontColor($r('app.color.common_gray_03'))
          .onClick(() => {
            this.sortType = SortType.Default
            this.filterIndex = 0
          })
        Text('筛选题目')
          .layoutWeight(1)
          .fontSize(18)
          .fontWeight(500)
          .fontColor($r('app.color.black'))
          .textAlign(TextAlign.Center)
        Text('完成')
          .fontWeight(500)
          .fontSize(16)
          .fontColor($r('app.color.common_main_color'))
          .onClick(() => {
            this.showDialog = false
            this.activeIndex = this.filterIndex
            this.tabController.changeIndex(this.activeIndex)
            this.sortType = this.filterSort
          })
      }
      .margin({ bottom: 4, top: 4 })

      Text('题目排序')
        .textTitle()
      // TODO 筛选按钮
      Flex() {
        //默认
        fillterBtn({
          isSelected: this.filterSort === SortType.Default,
          Sort: this.filterSort
        })
          .onClick(() => {
            this.filterSort = SortType.Default
          })
        //浏览量
        fillterBtn({
          text: '浏览量',
          isSort: true,
          isSelected: this.filterSort === SortType.ViewLow || this.filterSort === SortType.ViewHigh,
          Sort: this.filterSort
        })
          .onClick(() => {
            if (this.filterSort === SortType.ViewLow) {
              this.filterSort = SortType.ViewHigh
            } else {
              this.filterSort = SortType.ViewLow
            }
          })
        //难度
        fillterBtn({
          text: '难度',
          isSort: true,
          isSelected: this.filterSort === SortType.DifficultyLow || this.filterSort === SortType.DifficultyHigh,
          Sort: this.filterSort
        }).onClick(() => {
          if (this.filterSort === SortType.DifficultyLow) {
            this.filterSort = SortType.DifficultyHigh
          } else {
            this.filterSort = SortType.DifficultyLow
          }
        })
        //推荐
        fillterBtn({
          text: '推荐',
          isSelected: this.filterSort === SortType.Commend,
          Sort: this.filterSort
        })
          .onClick(() => {
            this.filterSort = SortType.Commend
          })
      }

      Text('选择分类')
        .textTitle()
      // TODO 筛选按钮
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.questionList, (item: QuestionType, i: number) => {
          fillterBtn({
            text: item.name,
            isNew: item.displayNewestFlag === 1,
            isSelected: this.filterIndex === i  //相等为true
          })
            .onClick(() => {
              this.filterIndex = i //切换
            })
        })
      }
    }
    .padding(16)
    .backgroundColor($r('app.color.white'))
    .height('100%')
  }

  @Builder
  SkeletonBuilder() {
    Skeleton() {
      Column() {
        //骨架屏顶部内容
        Row({ space: 8 }) {
          SkeletonItem({ widthValue: 50 })
          SkeletonItem({ widthValue: 90 })
          SkeletonItem({ widthValue: 60 })
          SkeletonItem({ widthValue: 110 })
        }.height(44)
        .width('100%')
        .padding(10)

        //骨架屏中心内容
        ForEach(Array.from(Array(5)), () => {
          Column({ space: 20 }) {
            SkeletonItem({ widthValue: '85%' })
            SkeletonItem({ widthValue: '50%' })
          }
          .height(80)
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Start)
          .padding(10)
        })
      }
    }
  }

  build() {
    if (this.loading) {
      this.SkeletonBuilder()
    } else {
      Stack({ alignContent: Alignment.TopEnd }) {
        Tabs({ barPosition: BarPosition.Start, controller: this.tabController }) {
          ForEach(this.questionList, (item: QuestionType, index: number) => {
            TabContent() {
              QuestionListComp({
                typeId: item.id,
                sort: this.sortType,
                activeIndex: this.activeIndex,
                index: index
              })
                .layoutWeight(1)
            }.tabBar(this.tabBar(item, index))
          })
        }
        .barHeight(44)
        .barMode(BarMode.Scrollable)
        .divider({ strokeWidth: .5, color: $r('app.color.common_gray_border') })
        .onChange((i: number) => {
          this.activeIndex = i
        })

        //右侧筛选按钮
        Row() {
          ImgComp({
            imgSrc: $r('app.media.ic_home_filter'),
            imgWidth: 24,
            aspectRatioValue: 1
          })
        }
        .width(40)
        .aspectRatio(1)
        .justifyContent(FlexAlign.Center)
        .margin({ right: -10 })
        .linearGradient({ angle: 90, colors: [['#00ffffff', 0], ['#ffffffff', 0.285]] })
        .bindSheet($$this.showDialog, this.fillterDialog(), {
          showClose: false,
          height: 400
        })
        .onClick(() => {
          this.showDialog = true
        })
      }
    }
  }
}

@Extend(Text)
function textTitle() {
  .fontSize(14)
  .fontWeight(500)
  .fontColor($r('app.color.black'))
  .width('100%')
  .margin({ top: 20 })
}

@Component
struct fillterBtn {
  @Prop
  text: string = '默认'
  @Prop
  isSort: boolean = false
  @Prop
  isNew: boolean = false
  @Prop
  isSelected: boolean = false
  @Prop
  Sort: SortType = SortType.Default

  build() {
    Row() {
      Text(this.text)//文本
        .fontSize(12)
        .fontColor(this.isSelected ? $r('app.color.common_main_color') : $r('app.color.black'))
      if (this.isNew) { //new 图标
        ImgComp({
          imgSrc: $r('app.media.ic_home_new'),
          imgWidth: 32,
          imgHeight: 14
        })
          .position({ right: -26, top: -7 })
      }
      if (this.isSort) { //排序
        Column() {
          ImgComp({
            imgSrc: $r('sys.media.ohos_ic_public_arrow_up'),
            imgWidth: 12,
            imgHeight: 6,
            fillColor: this.isSelected && this.Sort % 2 === 0 ? $r('app.color.common_main_color') :
            $r('app.color.black')
          })
          ImgComp({
            imgSrc: $r('sys.media.ohos_ic_public_arrow_down'),
            imgWidth: 12,
            imgHeight: 6,
            fillColor: this.isSelected && this.Sort % 2 === 1 ? $r('app.color.common_main_color') :
            $r('app.color.black')
          })
        }
        .margin({ top: -0.5, left: 2 })
      }
    }
    .height(30)
    .padding({ left: 10, right: 10 })
    .backgroundColor($r('app.color.common_gray_bg'))
    .borderRadius(4)
    .margin({ top: 12, right: this.isNew ? 26 : 10 })
  }
}