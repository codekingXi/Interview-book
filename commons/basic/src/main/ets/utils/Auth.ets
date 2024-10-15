import { User } from "../../../../Index"

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
}

export const auth = new Auth()