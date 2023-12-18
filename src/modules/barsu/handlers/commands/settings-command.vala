using DataStore;
using Telegram;

namespace Barsu {
    
    public async void settings_command(Message msg) {
        if (msg.chat.type != Chat.Type.PRIVATE) {
            var chat_member = yield bot.get_chat_member(msg.chat.id, msg.from.id);
            
            if (chat_member is ChatMemberOwner) {
                var group = data.get_chat_group(msg.chat.id);
                
                if (group != null)
                    yield send_settings(msg.chat.id);
                else
                    yield request_group(msg.from.id, msg.chat.id);
            } else {
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = "Изменять настройки уведомлений в общем чате может только владелец!"
                });
            }
            return;
        }
        
        if (data.get_post(msg.from.id) != null)
            yield send_settings(msg.chat.id, msg.from.id);
        else
            yield send_group_warning(msg.chat.id, msg.from.id);
    }
}