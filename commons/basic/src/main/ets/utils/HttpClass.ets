import axios, { AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from "@ohos/axios"
import { logger } from "../../../../Index"

interface Res<T> {
  //成功表示 true 成功 可选
  success: boolean
  //10000 正常 可选
  code: number
  //消息 可选
  message: string
  //响应结构 Object
  data: T
}


//实例
const instance = axios.create({
  baseURL: "https://api-harmony-teach.itheima.net/",
  timeout: 1000 * 10
})
//请求拦截器
instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  return config
}, (e: Error) => {
  logger.error('请求参数异常')
  return Promise.reject(e)
})
//响应拦截器
instance.interceptors.response.use((res: AxiosResponse) => {
  //处理响应的数据
  //如果状态码正确 返回data
  if (res.data.code === 10000) {
    return res.data.data
  }
  return Promise.reject(new Error(JSON.stringify(res.data)))
}, (e: Error) => {
  logger.error('响应结果异常')
  return Promise.reject(e)
})

class HttpClass {
  request<ResponseData, RequestData = Object>(config: AxiosRequestConfig<RequestData>) {
    return instance<null, ResponseData, RequestData>(config)
  }
}

export const httpClass = new HttpClass()