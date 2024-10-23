import { util } from "@kit.ArkTS"

/**
 * 计算百分比*/
export const calePercent = (done: number, total: number) => {
  return Math.round((done / total * 100)) + '%'
}
/**
 * 获得json文件内容*/
export const getStrFromJson = (path: string) => {
  return new util.TextDecoder().decodeToString(getContext().resourceManager.getRawFileContentSync(path))
}