import logging, threading, asyncio, os, json
from flask import Flask, request
from telegram import Update
from telegram.ext import ApplicationBuilder, ContextTypes, CommandHandler, MessageHandler, filters

# 启用日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')

BOT_TOKEN = os.getenv("BOT_TOKEN")
ADMIN_IDS = set(int(x.strip()) for x in os.getenv("ADMIN_IDS", "").split(",") if x.strip())
PROXY_URL = os.getenv("TG_BOT_PROXY_URL") # 环境变量名需与 .env 一致
CONFIG_FILE = "/etc/v2ray/config.json"

app = Flask(__name__)
tg_bot = None

def restricted(func):
    async def wrapped(update: Update, context: ContextTypes.DEFAULT_TYPE):
        if not update.effective_chat or update.effective_chat.id not in ADMIN_IDS:
            logging.warning(f"未授权访问: {update.effective_chat.id if update.effective_chat else '未知'}")
            return
        return await func(update, context)
    return wrapped

@restricted
async def start(update, context):
    await update.message.reply_text("🤖 机器人已上线！\n输入 'hello' 或 '查询' 试试。")

@restricted
async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    text = update.message.text.strip().lower()
    if text == "hello":
        await update.message.reply_text("Hi")
    elif "查询" in text:
        if os.path.exists(CONFIG_FILE):
            try:
                with open(CONFIG_FILE, 'r') as f:
                    conf = json.load(f)
                    node = conf['outbounds'][0]['settings']['vnext'][0]
                    await update.message.reply_text(f"📍 当前节点：`{node['address']}`\n端口：`{node['port']}`", parse_mode='Markdown')
            except Exception as e:
                await update.message.reply_text(f"❌ 读取配置失败: {e}")
        else:
            await update.message.reply_text("❌ 尚未生成配置文件。")

@app.route('/notify', methods=['POST'])
def notify():
    msg = request.form.get('msg', '通知')
    if tg_bot:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        try:
            for admin_id in ADMIN_IDS:
                loop.run_until_complete(tg_bot.bot.send_message(chat_id=admin_id, text=msg))
        finally:
            loop.close()
    return "OK"

if __name__ == '__main__':
    # --- 修复代理配置逻辑 ---
    # 在 PTB V20+ 中，代理通过 proxy_url 参数传入 build()
    tg_bot = ApplicationBuilder().token(BOT_TOKEN).proxy(PROXY_URL).get_updates_proxy(PROXY_URL).build()
    
    tg_bot.add_handler(CommandHandler('start', start))
    tg_bot.add_handler(MessageHandler(filters.TEXT & (~filters.COMMAND), handle_message))
    
    # 启动 Flask 接收 通知
    threading.Thread(target=lambda: app.run(host='0.0.0.0', port=xxxxx), daemon=True).start()
    
    logging.info("机器人开始运行...")
    tg_bot.run_polling()