using DataStore;
using Telegram;

namespace Admin {
    
    public async void find(Message msg) {
        int64 id;
        
        if (msg.reply_to_message?.forward_origin is MessageOriginUser) {
            id = ((MessageOriginUser) msg.reply_to_message.forward_origin).sender_user.id;
        } else if (msg.get_command_arguments() != null) {
            id = int64.parse(msg.get_command_arguments());
        } else {
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                text = "Бля буду, ты вообще ебобо. Нужен айди в аргумент или реплай на сообщения додика для взлома его жопы."
            });
            return;
        }
        var chat = yield bot.get_chat(new ChatId(id));
        
        if (chat != null) {
            string user_group = "Во еблан, без группы";
            foreach (var config in data.get_users().to_array()) {
                if (config.id == id)
                    if (config.group != null || config.name != null)
                        user_group = config.group ?? config.name;
            }
            
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                parse_mode = ParseMode.HTML,
                text = @"Попался гадёныш!\n$(yield mention(id))\nГруппа/Препод: $user_group"
            });
        } else
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                text = @"Пидор забанил!"
            });
    }
}