using DataStore;
using Telegram;

namespace DataStore {
    
    public async void settings_command(Message msg) {
        if (msg.chat.type != Chat.Type.PRIVATE) {
            var chat_member = yield bot.get_chat_member(msg.chat.id, msg.from.id);
            
            if (chat_member is ChatMemberOwner) {
                var group = get_chat_config(msg.chat.id).group;
                
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
        
        if (get_config(msg.from.id).post != null)
            yield send_settings(msg.chat.id, msg.from.id);
        else
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                parse_mode = ParseMode.MARKDOWN,
                text = "⚠️ *Сначала выбери группу/преподавателя!*",
                reply_markup = Keyboards.start_keyboard
            });
    }
    
    public async void send_settings(ChatId chat_id, int64? user_id = null, int? message_id = null) {
        var config = user_id != null ? get_config(user_id) : get_chat_config(chat_id);
        
        if (config.post == null)
            return;
        
        if (message_id != null)
            yield bot.send(new EditMessageText() {
                chat_id = chat_id,
                message_id = message_id,
                parse_mode = ParseMode.MARKDOWN,
                text = settings_text(config),
                reply_markup = config.subscribed ? Keyboards.disable_sub_keyboard : Keyboards.enable_sub_keyboard
            });
        else
            yield bot.send(new SendMessage() {
                chat_id = chat_id,
                parse_mode = ParseMode.MARKDOWN,
                text = settings_text(config),
                reply_markup = config.subscribed ? Keyboards.disable_sub_keyboard : Keyboards.enable_sub_keyboard
            });
    }
    
    private async void request_group(int64 user_id, ChatId chat_id) {
        var group = get_config(user_id).group;
        
        if (group == null)
            yield bot.send(new SendMessage() {
                chat_id = chat_id,
                text = "⚠️ Сначала выбери группу для себя, чтобы потом установить её для группы",
                reply_markup = Keyboards.open_bot_keyboard
            });
        else
            yield bot.send(new SendMessage() {
                chat_id = chat_id,
                parse_mode = ParseMode.MARKDOWN,
                text =
                @"✍️ Твоя группа *$group*\nНажми чтобы установить ее для группы",
                reply_markup = Keyboards.owner_keyboard
            });
    }
    
    public string settings_text(Config config) {
        var str = "Настройки бота:\n\n";
        str += @"🔔️ Уведомления: *$(config.subscribed ? "ВКЛ" : "ОТКЛ")*\n";
        
        if (config.post == UserPost.TEACHER) {
            str += @"🧑‍🏫️ Преподаватель: *$(config.name)*";
        } else
            str += @"👥️ Группа: *$(config.group)*";
        
        return str;
    }
}