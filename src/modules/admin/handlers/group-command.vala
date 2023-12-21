using DataStore;
using Telegram;

namespace Admin {
    
    public async void group(Message msg) {
        var group = data.parse_group(msg.get_command_arguments());
        int count = 0;
        if (group != null) {
            var text = @"Попались ебланчики из $(group):\n";
            foreach (var config in data.get_users().to_array()) {
                if (config.group != group)
                    continue;
                
                text += yield mention(config.id);
                text += "\n";
                count++;
            }
            
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                parse_mode = ParseMode.HTML,
                text = text + @"Всего пиздюков: $count"
            });
        } else
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                text = "Блять ну ты еблан пиздец"
            });
    }
}