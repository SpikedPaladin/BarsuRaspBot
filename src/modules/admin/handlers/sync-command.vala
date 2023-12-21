using DataStore;
using Telegram;

namespace Admin {
    
    public async void sync(Message msg) {
        var response = yield bot.send(new SendMessage() {
            chat_id = msg.chat.id,
            text = "*Группы синхронизируются...*"
        });
        var message_id = new Message(response.result.get_object()).message_id;
        
        yield data.sync();
        yield bot.send(new EditMessageText() {
            chat_id = msg.chat.id,
            message_id = message_id,
            text = "*Группы обновлены!*"
        });
    }
}