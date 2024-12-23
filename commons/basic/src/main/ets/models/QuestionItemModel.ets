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

export interface QuestionDetail extends QuestionItemModel {
  /* 答案 */
  answer: string
  /* 是否收藏 */
  collectFlag: 0 | 1
  /* 是否点赞 */
  likeFlag: 0 | 1
  /* 所属模块 */
  stage: string[]
}

export interface PageData<T> {
  total: number
  pageTotal: number
  rows: T[]
}

export interface QuestionPageParams {
  item: QuestionItemModel,
  list: QuestionItemModel[]
}

export interface QuestionListParams {
  type: number
  questionBankType: 9 | 10
  sort?: SortType
  page?: number
  pageSize?: number
  keyword?: string
}

/**
 * @param type 0试题 1面经
 * @param optType 1点赞 2收藏
 * */
export interface QuestionOptParams {
  id: string
  type: 0 | 1
  optType: 1 | 2
}

export enum SortType {
  Default = 0,
  DifficultyLow = 10,
  DifficultyHigh = 11,
  ViewLow = 20,
  ViewHigh = 21,
  Commend = 30
}
