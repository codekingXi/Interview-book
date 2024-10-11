@Component
export struct QuestionDay {
  @Prop questionContent: string = 'ArkTS的特性是什么?'

  build() {
    Column({ space: 6 }) {
      Text('每日一题')
        .fontSize(12)
      Text(this.questionContent)
        .fontWeight(FontWeight.Bold)
        .fontSize(14)
    }.layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
    .margin({ left: 100 })
  }
}