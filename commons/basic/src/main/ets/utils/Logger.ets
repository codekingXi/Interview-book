import { hilog } from '@kit.PerformanceAnalysisKit'

//二次封装hilog
const Tag_Name: string = "appLog"

class Logger {
  private domain: number //域名
  private tag: string

  constructor(tag: string = 'Logger', domain: number = 0x0000) {
    this.domain = domain
    this.tag = tag
  }

  format(args: string[]) {
    let str = ''
    for (let i = 0; i < args.length; i++) {
      str += `${args}`
    }
    return str
  }

  info(...args: string[]) {
    hilog.info(this.domain, this.tag, this.format(args), args)
  }

  warn(...args: string[]) {
    hilog.warn(this.domain, this.tag, this.format(args), args)
  }

  error(...args: string[]) {
    hilog.error(this.domain, this.tag, this.format(args), args)
  }

  debug(...args: string[]) {
    hilog.debug(this.domain, this.tag, this.format(args), args)
  }

  fatal(...args: string[]) {
    hilog.fatal(this.domain, this.tag, this.format(args), args)
  }
}

export const logger = new Logger(Tag_Name)