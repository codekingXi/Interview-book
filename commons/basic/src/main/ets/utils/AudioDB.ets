import { relationalStore, ValuesBucket } from '@kit.ArkData'
import { constants } from '../../../../Index'

export interface InterviewAudioItem extends ValuesBucket {
  id: number | null
  user_id: string
  name: string
  path: string
  duration: number
  size: number
  create_time: number
}

class AudioDB {
  store?: relationalStore.RdbStore
  tableName = 'interview_audio'

  // 初始化数据库
  async initStore() {
    const ctx = AppStorage.get<Context>(constants.CONTEXT)
    if (ctx) {
      const store = await relationalStore.getRdbStore(ctx, {
        name: 'interview_audio.db',
        securityLevel: relationalStore.SecurityLevel.S1
      })
      const sql = `
        CREATE TABLE IF NOT EXISTS ${this.tableName} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          name TEXT NOT NULL,
          path TEXT NOT NULL,
          duration INTEGER NOT NULL,
          size INTEGER NOT NULL,
          create_time INTEGER NOT NULL
        )
      `
      await store.executeSql(sql)
      this.store = store
    }
  }

  // 添加
  async insert(item: InterviewAudioItem) {
    const rowId = await this.store?.insert(this.tableName, item)
    if (rowId === undefined || rowId === -1) {
      return Promise.reject('insert fail')
    } else {
      return Promise.resolve()
    }
  }

  // 删除
  async delete(id: number) {
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    const rowCount = await this.store?.delete(predicates)
    if (rowCount === undefined || rowCount <= 0) {
      return Promise.reject('delete fail')
    } else {
      return Promise.resolve()
    }
  }

  // 修改
  async update(item: InterviewAudioItem) {
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', item.id)
    const rowCount = await this.store?.update(item, predicates)
    if (rowCount === undefined || rowCount <= 0) {
      return Promise.reject('update fail')
    } else {
      return Promise.resolve()
    }
  }

  // 查询用户
  async query(userId: string) {
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('user_id', userId)
    const resultSet = await this.store?.query(predicates)
    if (!resultSet) {
      return Promise.reject('query fail')
    }
    const list: InterviewAudioItem[] = []
    while (resultSet.goToNextRow()) {
      list.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        user_id: resultSet.getString(resultSet.getColumnIndex('user_id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        path: resultSet.getString(resultSet.getColumnIndex('path')),
        duration: resultSet.getLong(resultSet.getColumnIndex('duration')),
        size: resultSet.getLong(resultSet.getColumnIndex('size')),
        create_time: resultSet.getLong(resultSet.getColumnIndex('create_time'))
      })
    }
    resultSet.close()
    return Promise.resolve(list)
  }
}

export const audioDB = new AudioDB()