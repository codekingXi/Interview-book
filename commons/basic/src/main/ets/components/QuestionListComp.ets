import {
  httpClass,
  QuestionItemComp,
  PageData,
  QuestionItemModel,
  QuestionListParams,
  SortType
} from "../../../../Index"
import { promptAction } from "@kit.ArkUI"

@Component
export struct QuestionListComp {
  @State
  isRefreshing: boolean = false //是否在下拉
  @State
  isLoading: boolean = false //是否在加载
  @State
  isFinished: boolean = false //是否加载完成
  @Prop
  activeIndex: number = 0
  @Prop
  index: number = 0
  @State
  list: QuestionItemModel[] = []
  //获取列表数据的参数
  @Prop
  @Watch('onChangeSort')
  sort: SortType = SortType.Default
  @Prop
  typeId: number
  @State
  page: number = 1

  onChangeSort() {
    if (this.activeIndex === this.index) {
      this.isRefreshing = true
    }
  }

  //下拉刷新数据
  async onRefresh() {
    this.page = 1
    const res = await this.getQuestionListItem()
    this.list = res.rows //直接覆盖
    this.isRefreshing = false
    if (this.page >= res.pageTotal) {
      this.isFinished = true
    } else {
      this.isFinished = false
      //让下一页数据加载同步
      this.page++
      promptAction.showToast({ message: '更新成功' })
    }
  }

  //上拉加载内容
  async onLoad() {
    const res = await this.getQuestionListItem()
    this.list.push(...res.rows)
    this.isLoading = false
    //是否最后一页
    if (this.page >= res.pageTotal) {
      this.isFinished = true
    } else {
      this.page++
    }
  }

  //list底部内容
  @Builder
  loadMoreContent() {
    if (this.isLoading) {
      Row({ space: 4 }) {
        LoadingProgress()
          .width(20)
        Text('正在努力加载中...')
          .fontColor($r('app.color.common_gray_01'))
      }
      .width('100%')
      .height(80)
      .justifyContent(FlexAlign.Center)

    } else if (this.isFinished) {
      Text('我是有底线的~')
        .width('100%')
        .height(80)
        .textAlign(TextAlign.Center)
        .fontColor($r('app.color.common_gray_01'))
        .margin({ bottom: 35 })
    }
  }

  getQuestionListItem(): Promise<PageData<QuestionItemModel>> {
    return httpClass.request({
      url: 'hm/question/list',
      params: {
        type: this.typeId,
        questionBankType: 10,
        sort: this.sort,
        page: this.page,
        pageSize: 10
      } as QuestionListParams
    })
  }

  build() {
    //下拉刷新
    Refresh({ refreshing: $$this.isRefreshing }) {
      //上拉加载
      List() {
        ForEach(this.list, (item: QuestionItemModel) => {
          ListItem() {
            QuestionItemComp({ item })
          }
        })
        this.loadMoreContent()
      }
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
      .divider({
        color: $r('app.color.common_gray_border'),
        strokeWidth: .5,
        startMargin: 16,
        endMargin: 16
      })
      .onScrollStart(() => {
        //开始滑动
      })
      .onReachEnd(() => {
        //状态处于刷新 加载中 完成 都不能加载数据
        if (this.isRefreshing || this.isLoading || this.isFinished) {
          return
        }
        this.isLoading = true
        //触底
        this.onLoad()
      })
      .onScrollStop(() => {
        //停止滑动
      })

    }
    .onRefreshing(() => {
      this.onRefresh()
    })
  }
}