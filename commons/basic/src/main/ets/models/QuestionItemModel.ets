export interface QuestionItemModel {
  /** 试题id*/
  id: string
  /** 题干 */
  stem: string;

  /** 难度 */
  difficulty: number;

  /** 点赞数 */
  likeCount: number;

  /** 浏览数 */
  views: number;

  /** 是否已看 0未读 1已读 */
  readFlag: 0 | 1;
}

export interface PageData<T> {
  total: number
  pageTotal: number
  rows: T[]
}

export interface QuestionListParams {
  type: number
  questionBankType: 9 | 10
  sort?: SortType
  page?: number
  pageSize?: number
}

export enum SortType {
  Default = 0,
  DifficultyLow = 10,
  DifficultyHigh = 11,
  ViewLow = 20,
  ViewHigh = 21,
  Commend = 30
}
