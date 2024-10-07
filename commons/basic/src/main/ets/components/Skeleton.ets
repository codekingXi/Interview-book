/**
 * 骨架屏*/
@ComponentV2
export struct Skeleton {
  @LocalBuilder
  defaultBuilder() {
  }

  @BuilderParam
  defaultParm: () => void = this.defaultBuilder

  build() {
    Column() {
      this.defaultParm()
    }
  }
}