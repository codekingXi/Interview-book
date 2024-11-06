import axios, { AxiosError, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from "@ohos/axios"
import { auth, logger, User } from "../../../../Index"
import { promptAction, router } from "@kit.ArkUI"

//实例
const instance = axios.create({
  baseURL: "https://api-harmony-teach.itheima.net/",
  timeout: 1000 * 10
})
//请求拦截器
instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  const user = auth.getUser()
  if (user.token) {
    config.headers.Authorization = `Bearer ${user.token}`
  }
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
}, (e: AxiosError) => {
  if (e.response?.status === 401) {
    //提示登录失败
    promptAction.showToast({
      message: '登录失败，请重新登录'
    })
    //重新登录 删除无效token
    auth.setUser({} as User)
    //使用单例模式跳转登录页
    router.pushUrl({
      url: 'pages/LoginPage'
    }, router.RouterMode.Single)
    return
  }
  promptAction.showToast({
    message: '响应错误' + e.message
  })
  logger.error('响应结果异常')
  return Promise.reject(e)
})

class HttpClass {
  request<ResponseData, RequestData = Object>(config: AxiosRequestConfig<RequestData>) {
    return instance<null, ResponseData, RequestData>(config)
  }
}

export const httpClass = new HttpClass()