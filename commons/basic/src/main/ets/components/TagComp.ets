import { TagInfoMap } from "../models/TagModel"

@ComponentV2
export struct Tag {
  //试题难度 1-2星是简单，3-4星是一般，5星是困难
  @Param
  difficulty: number = 1
  //接受自定义文本或颜色
  @Param
  text: string = ''
  @Param
  color: ResourceColor = ''

  build() {
    Text(this.text || TagInfoMap[this.difficulty].text)
      .fontSize(10)
      .padding({ left: 6, right: 6 })
      .height(18)
      .borderRadius(2)
      .textAlign(TextAlign.Center)
      .constraintSize({
        //最小值设置
        minWidth: 34
      })
      .fontColor(this.color || TagInfoMap[this.difficulty].color)
      .backgroundColor($r('app.color.common_gray_bg'))
  }
}