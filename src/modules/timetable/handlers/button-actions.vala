using Telegram;

namespace BarsuTimetable {
    
    public class ButtonActions {
        
        public async void empty(CallbackQuery query) {
            yield bot.send(new AnswerCallbackQuery() {
                callback_query_id = query.id
            });
        }
        
        public async void cancel(CallbackQuery query) {
            if (query.message.chat.type == Chat.Type.PRIVATE) {
                yield bot.send(new DeleteMessage() {
                    chat_id = query.message.chat.id,
                    message_id = query.message.message_id
                });
                
                yield bot.send(new SendMessage() {
                    chat_id = query.message.chat.id,
                    reply_markup = new ReplyKeyboardRemove(),
                    text = "⚙️ Смена группы отменена"
                });
                
                config_manager.set_user_state(query.from.id, null);
                yield send_settings(query.message.chat.id, query.from.id);
                
                return;
            }
            
            var chat_member = yield bot.get_chat_member(query.message.chat.id, query.from.id);
            if (chat_member is ChatMemberOwner)
                if (config_manager.find_chat_config(query.message.chat.id) == null)
                    yield bot.send(new DeleteMessage() {
                        chat_id = query.message.chat.id,
                        message_id = query.message.message_id
                    });
                else
                    yield send_settings(query.message.chat.id, null, query.message.message_id);
            else
                yield send_alert(query.id, "Изменять настройки в общем чате может только владелец!");
        }
        
        public async void install(CallbackQuery query) {
            var chat_member = yield bot.get_chat_member(query.message.chat.id, query.from.id);
            
            if (chat_member is ChatMemberOwner) {
                var group = config_manager.find_user_group(query.from.id);
                
                if (group != null) {
                    config_manager.update_chat_group(query.message.chat.id, group);
                    yield send_settings(query.message.chat.id, null, query.message.message_id);
                } else
                    yield send_alert(query.id, "Выбери сначала группу для себя");
            } else
                yield send_alert(query.id, "Изменять группу в общем чате может только владелец!");
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
                config_manager.set_user_state(query.from.id, SetupState.FACULTY);
                
                yield bot.send(new EditMessageText() {
                    chat_id = query.message.chat.id,
                    message_id = query.message.message_id,
                    text =
                    "⚠️ Ты выбрал сменить группу\n",
                    reply_markup = Keyboards.cancel_keyboard
                });
                
                yield bot.send(new SendMessage() {
                    chat_id = query.message.chat.id,
                    parse_mode = ParseMode.MARKDOWN,
                    reply_markup = Setup.faculty_keyboard(),
                    text = "🕶️ Выбери факультет"
                });
                return;
            }
            
            var chat_member = yield bot.get_chat_member(query.message.chat.id, query.from.id);
            
            if (chat_member is ChatMemberOwner) {
                var chat_group = config_manager.find_chat_group(query.message.chat.id);
                var group = config_manager.find_user_group(query.from.id);
                
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
                yield send_alert(query.id, "Изменять выбранную группу в общем чате может только владелец!");
            }
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
                reply_markup = enabled ? Keyboards.disable_sub_keyboard : Keyboards.enable_sub_keyboard
            });
        }
    }
}
