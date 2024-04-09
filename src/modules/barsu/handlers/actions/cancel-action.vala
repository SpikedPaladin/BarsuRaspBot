using DataStore;
using Telegram;

namespace Barsu {
    
    public async void cancel(CallbackQuery query) {
        if (query.message.chat.type == Chat.Type.PRIVATE) {
            yield bot.send(new DeleteMessage() {
                chat_id = query.message.chat.id,
                message_id = query.message.message_id
            });
            
            if (get_config(query.from.id).post == null)
                yield bot.send(new SendMessage() {
                    chat_id = query.message.chat.id,
                    reply_markup = new ReplyKeyboardRemove(),
                    text = "ℹ️ Выбор группы отменен!"
                });
            else
                yield bot.send(new SendMessage() {
                    chat_id = query.message.chat.id,
                    reply_markup = Keyboards.main_keyboard,
                    text = "⚙️ Смена группы отменена"
                });
            
            get_config(query.from.id).state = null;
            yield send_settings(query.message.chat.id, query.from.id);
            
            return;
        }
        
        var chat_member = yield bot.get_chat_member(query.message.chat.id, query.from.id);
        if (chat_member is ChatMemberOwner)
            if (get_chat_config(query.message.chat.id) == null)
                yield bot.send(new DeleteMessage() {
                    chat_id = query.message.chat.id,
                    message_id = query.message.message_id
                });
            else
                yield send_settings(query.message.chat.id, null, query.message.message_id);
        else
            send_alert(query.id, "Изменять настройки в общем чате может только владелец!");
    }
}