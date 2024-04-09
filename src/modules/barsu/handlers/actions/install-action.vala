using DataStore;
using Telegram;

namespace Barsu {
    
    public async void install(CallbackQuery query) {
        var chat_member = yield bot.get_chat_member(query.message.chat.id, query.from.id);
        
        if (chat_member is ChatMemberOwner) {
            var group = get_config(query.from.id).group;
            
            if (group != null) {
                get_chat_config(query.message.chat.id).group = group;
                yield send_settings(query.message.chat.id, null, query.message.message_id);
            } else
                send_alert(query.id, "Выбери сначала группу для себя");
        } else
            send_alert(query.id, "Изменять группу в общем чате может только владелец!");
    }
}