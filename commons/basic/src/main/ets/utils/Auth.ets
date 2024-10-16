import { User } from "../../../../Index"
import { router } from "@kit.ArkUI"

export const UserStoreKey = 'UserStoreKey'

class Auth {
  //声明用户
  initUser() {
    PersistentStorage.persistProp(UserStoreKey, {} as User)
  }

  //设置用户
  setUser(user: User) {
    AppStorage.setOrCreate(UserStoreKey, user)
  }

  //获取用户
  getUser() {
    return AppStorage.get<User>(UserStoreKey) || {} as User
  }

  /**
   * 检查用户是否已认证
   * @param opt 路由选项对象或一个函数,如果用户已认证，根据 opt 参数类型执行相应的跳转或回调
   * 如果用户未认证，根据 opt 参数类型跳转到登录页面，并可携带返回网址参数
   */
  checkAuth(opt: router.RouterOptions | Function) {
    // 获取当前用户信息
    const user = auth.getUser()

    // 判断用户是否已认证
    if (user.token) {
      // 用户已认证，根据 opt 参数类型执行相应的跳转或回调
      if (typeof opt === 'function') {
        opt()
      } else {
        router.pushUrl(opt)
      }
    } else {
      // 用户未认证，根据 opt 参数类型跳转到登录页面，并可携带返回网址参数
      if (typeof opt === 'function') {
        router.pushUrl({
          url: 'pages/LoginPage'
        })
      } else {
        const params = opt.params as Record<string, string>
        params.return_url = opt.url
        router.pushUrl({
          url: 'pages/LoginPage',
          params
        })
      }
    }
  }
}

export const auth = new Auth()