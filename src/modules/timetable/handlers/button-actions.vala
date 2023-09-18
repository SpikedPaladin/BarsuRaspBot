using Telegram;

namespace BarsuTimetable {
    
    public class ButtonActions {
        
        public async void cancel(CallbackQuery query) {
            if (bot.users_map.has_key(@"$(query.from.id)"))
                bot.users_map.unset(@"$(query.from.id)");
            
            int64? user_id = null;
            
            if (query.message.chat.type == Chat.Type.PRIVATE)
                user_id = query.from.id;
            else if (config_manager.find_chat_config(query.message.chat.id) == null) {
                yield bot.send(new EditMessageReplyMarkup() {
                    chat_id = query.message.chat.id,
                    message_id = query.message.message_id
                });
                
                return;
            }
            
            yield send_settings(query.message.chat.id, user_id, query.message.message_id);
        }
        
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
                yield send_alert(query.id, "Изменять настройки уведомлений в общем чате может только владелец!");
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
                yield send_alert(query.id, "Изменять настройки уведомлений в общем чате может только владелец!");
            }
        }
        
        public async void change_group(CallbackQuery query) {
            if (query.message.chat.type == Chat.Type.PRIVATE) {
                bot.users_map.set(@"$(query.from.id)", "settings");
                
                yield bot.send(new EditMessageText() {
                    chat_id = query.message.chat.id,
                    message_id = query.message.message_id,
                    text =
                    "✍️ Напиши название группы в формате:\n" +
                    @"$(group_manager.get_random_group())",
                    reply_markup = bot.cancel_keyboard
                });
                return;
            }
            
            var chat_member = yield bot.get_chat_member(query.message.chat.id, query.from.id);
            
            if (chat_member is ChatMemberOwner) {
                bot.users_map.set(@"$(query.from.id)", "owner");
                
                yield bot.send(new EditMessageText() {
                    chat_id = query.message.chat.id,
                    message_id = query.message.message_id,
                    parse_mode = ParseMode.MARKDOWN,
                    text =
                    "✍️ Напиши название группы в формате:\n" +
                    @"$(group_manager.get_random_group())" +
                    "\n\n*Если бот не админ, отправь название группы ответом на это сообщение*",
                    reply_markup = bot.cancel_keyboard
                });
            } else {
                yield send_alert(query.id, "Изменять выбранную группу в общем чате может только владелец!");
            }
        }
        
        public async void select_group(CallbackQuery query) {
            bot.users_map.set(@"$(query.from.id)", "start");
            
            yield bot.send(new EditMessageText() {
                chat_id = query.message.chat.id,
                message_id = query.message.message_id,
                text =
                "✍️ Теперь напиши название своей группы в формате:\n" +
                @"$(group_manager.get_random_group())",
                reply_markup = bot.cancel_keyboard
            });
        }
        
        public async void send_timetable(CallbackQuery query) {
            var data = query.data.split(":");
            
            yield send_timetable_date(data[1], data[2], data[3], query);
        }
        
        private async void send_alert(string id, string text) {
            yield bot.send(new AnswerCallbackQuery() {
                callback_query_id = id,
                show_alert = true,
                text = text
            });
        }
        
        private async void send_settings_with_update(
            bool for_chat,
            bool enabled,
            int64 id,
            ChatId chat_id,
            int message_id
        ) {
            yield bot.send(new EditMessageText() {
                chat_id = chat_id,
                message_id = message_id,
                text = settings_text(
                    for_chat ?
                        config_manager.update_chat_sub(chat_id, enabled) :
                        config_manager.update_user_sub(id, enabled)
                ),
                parse_mode = ParseMode.MARKDOWN,
                reply_markup = enabled ? bot.disable_sub_keyboard : bot.enable_sub_keyboard
            });
        }
    }
}
