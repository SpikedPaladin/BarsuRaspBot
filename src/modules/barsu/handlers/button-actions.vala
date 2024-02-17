using DataStore;
using Telegram;

namespace Barsu {
    
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
        
        public async void send_teacher(CallbackQuery query) {
            var data = query.data.split(":");
            
            if (data.length == 3) {
                var image = yield image_manager.get_image(get_config(query.from.id).theme, data[2], null, data[1]);
                
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
                var image = yield image_manager.get_image(get_config(query.from.id).theme, data[2], data[1]);
                
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
    }
}
