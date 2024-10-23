export interface WordItem {
  en: string
  zh: string
  code: string
}

export type Words = Record<string, WordItem[]>