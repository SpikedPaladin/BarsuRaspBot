using DataStore;
using Telegram;

namespace Admin {
    
    public async void remove(Message msg) {
        var id = int64.parse(msg.get_command_arguments());
        
        if (data.get_config(id) != null) {
            data.remove_config(id, false);
            
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                text = "Ебнул дауна!"
            });
        } else
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                text = "Повезло додику его конфига нет!"
            });
    }
}