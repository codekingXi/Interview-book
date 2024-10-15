import { http, webSocket } from '@kit.NetworkKit'
import { util } from '@kit.ArkTS'
import { router } from '@kit.ArkUI'
import { constants, logger } from 'basic'
import { BusinessError } from '@kit.BasicServicesKit'

@Entry
@Component
struct SocketAI {
  @StorageProp(constants.TOP_AREA)
  topHeight: number = 0
  @StorageProp(constants.BOTTOM_AREA)
  bottomHeight: number = 0
  @State
  contentStr: string = ""
  @State
  messList: MessageItem[] = []
  scroller: Scroller = new Scroller()
  @State
  sendIng: boolean = false
  token: string = ""
  //创建websocket
  ws: webSocket.WebSocket = webSocket.createWebSocket()

  aboutToAppear() {
    this.getToken()
  }

  createConnect() {
    this.ws.connect('ws://toutiao.itheima.net/socket.io/?EIO=4&transport=websocket&token=' + this.token,
      (err: BusinessError, value: boolean) => {
        if (!err) {
          logger.info('socket connect success')
        } else {
          logger.error('socket connect error')
        }
      })
    //消息处理
    this.ws.on('message', (err: BusinessError, value: string | ArrayBuffer) => {
      logger.info('socket get message' + value) //打印信息
      //协议1 0开头 不回消息会断连
      if ((value as string).startsWith('0')) { //0开头
        this.ws.send('40') //回复40
      } else if ((value as string).startsWith('2')) { //2开头
        this.ws.send('3') //回复3
      } else if ((value as string).startsWith('42')) { //协议3 42开头是信息
        logger.info(value as string);
        //消息追加到页面
        const message = JSON.parse((value as string).replace('42', '')) as [string, MessageStruct]
        if (message[0] === 'message') {
          this.messList.push(new MessageItem(message[1].msg, false))
          this.scroller.scrollEdge(Edge.Bottom)
        }
      }
    })
  }

  async getToken() {
    //通过后台服务获取实时通信的token信息
    const instance = http.createHttp()
    const res = await instance.request('https://toutiao.itheima.net/v1_0/authorizations', {
      header: {
        "Content-Type": "application/json",
      },
      method: http.RequestMethod.POST,
      extraData: { mobile: '13912345678', code: '246810' }
    })
    const tokenObj = JSON.parse(res.result as string) as ResponseResult<Token>
    this.token = tokenObj.data.token
    this.createConnect()
  }

  async sendMessage() {
    if (!this.contentStr) {
      return
    }
    this.sendIng = true
    try {
      //发送给socket
      const data: [string, MessageStruct] = ['message', {
        msg: this.contentStr,
        timeStamp: Date.now()
      }]
      this.ws.send('42' + JSON.stringify(data), (err: BusinessError, value: boolean) => {
        if (!err) {
          logger.info('socket send success')
        } else {
          logger.info('socket send error')
        }
      })
      //发送到页面
      this.messList.push(new MessageItem(this.contentStr))
      this.scroller.scrollEdge(Edge.Bottom)
      this.sendIng = false
      this.contentStr = ""
    } catch (error) {
      AlertDialog.show({ message: JSON.stringify(error) })
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Stack({ alignContent: Alignment.Start }) {
          Text("‍面通AI")
            .width('100%')
            .height(50)
            .textAlign(TextAlign.Center)
          Image($r('sys.media.ohos_ic_compnent_titlebar_back_filled'))
            .width(24)
            .aspectRatio(1)
            .onClick(() => {
              router.back()
            })
        }
        .padding({
          left: 16,
          right: 16
        })

        // 消息列表
        Column() {
          List({ space: 20, scroller: this.scroller }) {
            ForEach(this.messList, (item: MessageItem) => {
              ListItem() {
                // 一左一右
                ChatMessage({
                  item, delMessage: (id: string) => {
                    // 删除消息
                    const index = this.messList.findIndex(item => item.id === id)
                    this.messList.splice(index, 1)
                  }
                })
              }
            })
          }
          .width('100%')
          .height('100%')
        }
        .layoutWeight(1)

        Row({ space: 20 }) {
          TextInput({ text: this.contentStr })
            .layoutWeight(1)
            .backgroundColor(Color.White)
            .borderRadius(2)
            .height(40)
            .onChange((value) => {
              this.contentStr = value
            })
            .onSubmit((key, event) => {
              event.keepEditableState()
              if (this.contentStr) {
                this.sendMessage()
              }
            })
          Button() {
            Row() {
              if (this.sendIng) {
                LoadingProgress()
                  .width(20)
                  .height(20)
                  .color('#fff')
                  .margin({
                    right: 4
                  })
              } else {
                Text("发送")
                  .fontColor("#fff")
              }
            }
          }
          .onClick(async () => {
            if (!this.sendIng) {
              await this.sendMessage()
            }
          })
          .enabled(!!this.contentStr)
          .height(30)
          .width(60)
        }
        .width('100%')
        .backgroundColor('#f6f6f6')
        .height(70)
        .padding({
          left: 10,
          right: 10
        })
      }.height('100%')
    }
    .backgroundColor('#ededed')
    .height('100%')
    .padding({
      top: this.topHeight,
      bottom: this.bottomHeight
    })
  }
}

@Component
struct ChatMessage {
  @Prop
  item: MessageItem = new MessageItem('')
  @State
  showMenu: boolean = false
  delMessage: (id: string) => void = () => {
  }

  @Builder
  getDelContent() {
    Button("删除")
      .backgroundColor(Color.White)
      .fontColor("#0c2803")
      .height(30)
      .onClick(() => {
        this.delMessage(this.item.id!)
      })
  }

  build() {
    Row() {
      Image(this.item.avatar)
        .height(40)
        .width(40)
        .borderRadius(6)
      Row() {
        Text(this.item.content)
          .backgroundColor(this.item.self ? "#8bec73" : Color.White)
          .fontColor("#0c2803")
          .padding(10)
          .lineHeight(24)
          .margin({
            left: 10,
            right: 10
          })
          .borderRadius(5)
          .gesture(
            LongPressGesture()
              .onAction(() => {
                this.showMenu = true
              })
          )
          .bindPopup(this.showMenu, {
            builder: this.getDelContent,
            placement: Placement.Top,
            onStateChange: (event) => {
              this.showMenu = event.isVisible
            }
          })
      }.layoutWeight(5)
      .justifyContent(this.item.self ? FlexAlign.End : FlexAlign.Start)

      Text().layoutWeight(1)
    }
    .width('100%')
    .padding({
      left: 20,
      right: 20
    })
    .alignItems(VerticalAlign.Top)
    .direction(this.item.self ? Direction.Rtl : Direction.Ltr)
  }
}


export class MessageItem {
  content: string = "" // 消息内容
  avatar: ResourceStr = "" // 用户头像
  username: string = "" // 用户名称
  self: boolean = false // 是不是用户自己
  timestamp: number = Date.now() // 消息收到时的时间戳
  id: string = util.generateRandomUUID() // 唯一的id
  constructor(content: string, self: boolean = true) {
    this.content = content
    this.self = self
    this.avatar = self ? 'https://foruda.gitee.com/avatar/1705232317138324256/1759638_itcast_panpu_1705232317.png' :
      'http://toutiao.itheima.net/images/user_head.jpg'
  }
}

interface ResponseResult<T> {
  data: T
  message: string
}

interface Token {
  token: string
}

interface MessageStruct {
  msg: string
  timeStamp: number
}