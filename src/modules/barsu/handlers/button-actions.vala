using DataStore;
using Telegram;

namespace Barsu {
    
    public class ButtonActions {
        
        public async void empty(CallbackQuery query) {
            yield bot.send(new AnswerCallbackQuery() {
                callback_query_id = query.id
            });
        }
        
        public async void get_app(CallbackQuery query) {
            yield bot.send(new SendMessage() {
                chat_id = query.message.chat.id,
                text = @"Приложение *Расписание БарГУ*\nТекущая версия: v$(data.get_apk_version())",
                reply_markup = Keyboards.apk_keyboard
            });
        }
        
        public async void get_apk(CallbackQuery query) {
            yield bot.send(new SendDocument() {
                chat_id = query.message.chat.id,
                document = data.get_apk_file_id(),
                caption = "⚠️ Не забывай переодически проверять обновления!"
            });
        }
        
        public async void cancel(CallbackQuery query) {
            if (query.message.chat.type == Chat.Type.PRIVATE) {
                yield bot.send(new DeleteMessage() {
                    chat_id = query.message.chat.id,
                    message_id = query.message.message_id
                });
                
                if (data.get_post(query.from.id) == null)
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
                
                data.set_state(query.from.id, null);
                yield send_settings(query.message.chat.id, query.from.id);
                
                return;
            }
            
            var chat_member = yield bot.get_chat_member(query.message.chat.id, query.from.id);
            if (chat_member is ChatMemberOwner)
                if (data.get_chat_config(query.message.chat.id) == null)
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
                var group = data.get_group(query.from.id);
                
                if (group != null) {
                    data.set_chat_group(query.message.chat.id, group);
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
        
        // TODO check for msg time
        public async void change_group(CallbackQuery query) {
            if (query.message.chat.type == Chat.Type.PRIVATE) {
                data.set_state(query.from.id, UserState.POST);
                
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
                var chat_group = data.get_chat_group(query.message.chat.id);
                var group = data.get_group(query.from.id);
                
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
        
        public async void send_teacher(CallbackQuery query) {
            var data = query.data.split(":");
            
            if (data.length == 3) {
                var image = yield image_manager.get_image(data[2], null, data[1]);
                
                if (image.file_id != null) {
                    yield bot.send(new EditMessageMedia() {
                        chat_id = query.message.chat.id,
                        message_id = query.message.message_id,
                        media = new InputMediaPhoto() {
                            media = image.file_id
                        }
                    });
                } else {
                    var response = yield bot.send(new EditMessageMedia() {
                        chat_id = query.message.chat.id,
                        message_id = query.message.message_id,
                        media = new InputMediaPhoto() {
                            media = "week-image.png",
                            bytes = image.bytes
                        }
                    });
                    
                    if (!response.ok)
                        return;
                    
                    var message = new Message(response.result.get_object());
                    image.bytes = null;
                    image.file_id = message.photo[0].file_id;
                    
                    // Manual put is required
                    image_manager.update_cache(image);
                }
                
                return;
            }
            
            yield send_teacher_date(data[1], data[2], data[3], query);
        }
        
        public async void send_timetable(CallbackQuery query) {
            var data = query.data.split(":");
            
            if (data.length == 3) {
                var image = yield image_manager.get_image(data[2], data[1]);
                
                if (image.file_id != null) {
                    yield bot.send(new EditMessageMedia() {
                        chat_id = query.message.chat.id,
                        message_id = query.message.message_id,
                        media = new InputMediaPhoto() {
                            media = image.file_id
                        }
                    });
                } else {
                    var response = yield bot.send(new EditMessageMedia() {
                        chat_id = query.message.chat.id,
                        message_id = query.message.message_id,
                        media = new InputMediaPhoto() {
                            media = "week-image.png",
                            bytes = image.bytes
                        }
                    });
                    
                    if (!response.ok)
                        return;
                    
                    var message = new Message(response.result.get_object());
                    image.bytes = null;
                    image.file_id = message.photo[0].file_id;
                    
                    // Manual put is required
                    image_manager.update_cache(image);
                }
                
                return;
            }
            
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
                        data.set_chat_subscription(chat_id, enabled) :
                        data.set_subscription(id, enabled)
                ),
                parse_mode = ParseMode.MARKDOWN,
                reply_markup = enabled ? Keyboards.disable_sub_keyboard : Keyboards.enable_sub_keyboard
            });
        }
    }
}
