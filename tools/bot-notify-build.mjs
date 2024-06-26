import esMain from "es-main"
import { sendMessageToQQGroup } from "./bot.mjs"

async function main() {
  const botUrl = process.env.BOT_URL
  const version = process.env.LATEST_VERSION
  const groupNumber = process.argv[2]
  const message = `最新测试版${version}已完成构建，请Android用户等待开发者上传.apk文件到群文件；请iOS用户等待发布TestFlight测试`
  const result = await sendMessageToQQGroup({ botUrl, groupNumber, message })
  console.log(result)
}

if (esMain(import.meta)) {
  main()
}
