/**
 * 骨架屏*/
@Component
export struct Skeleton {
  @Builder
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