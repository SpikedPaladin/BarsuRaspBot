using Telegram;
using Barsu;

namespace Admin {
    
    public async void broadcast(Message msg) {
        if (msg.reply_to_message == null) {
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                text = "⚠️ Додик ебаный... Нужно отправлять ответом на сообщение"
            });
            
            return;
        }
        
        ReplyMarkup? reply_markup = null;
        if (msg.get_command_arguments() == "apk")
            reply_markup = Keyboards.apk_keyboard;
        
        yield broadcast_manager.send_broadcast(msg.chat.id, msg.reply_to_message.message_id, reply_markup);
    }
}