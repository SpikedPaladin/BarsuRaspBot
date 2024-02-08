using Telegram;

namespace DataStore {
    
    public async void change_group(CallbackQuery query) {
            if (query.message.chat.type == Chat.Type.PRIVATE) {
                get_config(query.from.id).state = UserState.POST;
                
                if (query.message is Message && ((Message) query.message).text.has_prefix("👋️ Привет"))
                    yield bot.send(new SendMessage() {
                        chat_id = query.message.chat.id,
                        text = "ℹ️ Если твоей группы нет - нажми _Отменить_",
                        reply_markup = Keyboards.cancel_keyboard
                    });
                else
                    yield bot.send(new EditMessageText() {
                        chat_id = query.message.chat.id,
                        message_id = query.message.message_id,
                        text =
                        "⚠️ Ты выбрал изменить группу\n" +
                        "ℹ️ Если твоей группы нет - нажми _Отменить_",
                        reply_markup = Keyboards.cancel_keyboard
                    });
                
                yield bot.send(new SendMessage() {
                    chat_id = query.message.chat.id,
                    parse_mode = ParseMode.MARKDOWN,
                    reply_markup = Keyboards.post_keyboard,
                    text = "✍️ Ты студент или преподаватель?"
                });
                return;
            }
            
            var chat_member = yield bot.get_chat_member(query.message.chat.id, query.from.id);
            
            if (chat_member is ChatMemberOwner) {
                var chat_group = get_chat_config(query.message.chat.id).group;
                var group = get_config(query.from.id).group;
                
                if (chat_group == group) {
                    yield bot.send(new EditMessageText() {
                        chat_id = query.message.chat.id,
                        message_id = query.message.message_id,
                        text =
                        "⚠️ У тебя такая же группа как и установленная в чате!",
                        reply_markup = Keyboards.open_bot_keyboard
                    });
                } else if (group == null) {
                    yield bot.send(new EditMessageText() {
                        chat_id = query.message.chat.id,
                        message_id = query.message.message_id,
                        text =
                        "⚠️ Сначала выбери группу для себя, чтобы потом установить её для группы",
                        reply_markup = Keyboards.open_bot_keyboard
                    });
                } else {
                    yield bot.send(new EditMessageText() {
                        chat_id = query.message.chat.id,
                        message_id = query.message.message_id,
                        parse_mode = ParseMode.MARKDOWN,
                        text =
                        @"✍️ Твоя группа *$group*\nНажми чтобы установить её для группы",
                        reply_markup = Keyboards.owner_keyboard
                    });
                }
            } else {
                send_alert(query.id, "Изменять выбранную группу в общем чате может только владелец!");
            }
        }
}