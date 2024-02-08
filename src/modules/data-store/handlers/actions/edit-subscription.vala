using Telegram;

namespace DataStore {
    
    public async void enable_subscription(CallbackQuery query) {
        var chat_id = query.message.chat.id;
        
        if (query.message.chat.type == Chat.Type.PRIVATE) {
            yield send_settings_with_update(false, true, query.from.id, chat_id, query.message.message_id);
            return;
        }
        
        var chat_member = yield bot.get_chat_member(chat_id, query.from.id);
        
        if (chat_member is ChatMemberOwner)
            yield send_settings_with_update(true, true, chat_id.id, chat_id, query.message.message_id);
        else
            send_alert(query.id, "Изменять настройки уведомлений в общем чате может только владелец!");
    }
    
    public async void disable_subscription(CallbackQuery query) {
        var chat_id = query.message.chat.id;
        
        if (query.message.chat.type == Chat.Type.PRIVATE) {
            yield send_settings_with_update(false, false, query.from.id, chat_id, query.message.message_id);
            return;
        }
        
        var chat_member = yield bot.get_chat_member(chat_id, query.from.id);
        
        if (chat_member is ChatMemberOwner) {
            yield send_settings_with_update(true, false, chat_id.id, chat_id, query.message.message_id);
        } else {
            send_alert(query.id, "Изменять настройки уведомлений в общем чате может только владелец!");
        }
    }
    
    private async void send_settings_with_update(
        bool for_chat,
        bool enabled,
        int64 id,
        ChatId chat_id,
        int message_id
    ) {
        if (for_chat) get_chat_config(chat_id).subscribed = enabled;
        else          get_config(id).subscribed = enabled;
        
        yield bot.send(new EditMessageText() {
            chat_id = chat_id,
            message_id = message_id,
            text = for_chat ? get_chat_config(chat_id).to_string() : get_config(id).to_string(),
            parse_mode = ParseMode.MARKDOWN,
            reply_markup = enabled ? Keyboards.disable_sub_keyboard : Keyboards.enable_sub_keyboard
        });
    }
}