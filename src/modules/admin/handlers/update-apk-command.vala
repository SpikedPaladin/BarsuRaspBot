using DataStore;
using Telegram;

namespace Admin {
    
    public async void update_apk(Message msg) {
        if (msg.reply_to_message != null) {
            var file_id = msg.reply_to_message.document.file_id;
            var version = msg.reply_to_message.document.file_name.split("v")[1].substring(0, 5);
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                text = @"Бля новый айди: $version `$file_id`"
            });
            
            data.set_apk(file_id, version);
        }
    }
}