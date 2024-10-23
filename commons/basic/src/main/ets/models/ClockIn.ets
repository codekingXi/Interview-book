//响应参数类型
export interface ClockInItem {
  id: string,
  createdAt: string
}
export interface ClockInfo {
  flag: boolean
  clockinNumbers: number
  totalClockinNumber: number
  clockins: ClockInItem[]
}
//请求参数类型
export interface ClockInfoParams {
  year: string,
  month: string
}