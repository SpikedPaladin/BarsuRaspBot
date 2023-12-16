using DataStore;
using Telegram;

namespace Barsu {
    
    public class ChatCommands {
        
        public async void apk(Message msg) {
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                text = "Приложение *Расписание БарГУ*\nТекущая версия: v1.0.8",
                reply_markup = Keyboards.apk_keyboard
            });
        }
        
        public async void day_command(Message msg) {
            var args = msg.get_command_arguments();
            
            var date = (msg.text == "▶️ Сегодня" || msg?.get_command_name() == "day") ? new DateTime.now() : new DateTime.now().add_days(1);
            string? group = null;
            
            if (msg.chat.type != Chat.Type.PRIVATE)
                group = data.get_chat_group(msg.chat.id) ?? data.get_group(msg.from.id);
            else
                group = data.get_group(msg.from.id);
            
            if (args != null)
                group = data.parse_group(args);
            
            if (group != null) {
                var timetable = yield timetable_manager.get_timetable(group, get_current_week().format("%F"));
                var day = timetable?.get_day_schedule(date);
                
                if (day != null)
                    yield bot.send(new SendMessage() {
                        chat_id = msg.chat.id,
                        parse_mode = ParseMode.MARKDOWN,
                        text = @"👥️ Группа: *$(group)*\n" + day.to_string()
                    });
                else
                    yield bot.send(new SendMessage() {
                        chat_id = msg.chat.id,
                        text = @"🎉️ $(msg.get_command_name() == "day" ? "Сегодня" : "Завтра") пар нет!"
                    });
            } else if (data.get_post(msg.from.id) == UserPost.TEACHER) {
                var timetable = yield timetable_manager.get_teacher(data.get_config(msg.from.id).name, get_current_week().format("%F"));
                var day = timetable?.get_day_schedule(date);
                var name = data.get_config(msg.from.id).name;
                
                if (day != null)
                    yield bot.send(new SendMessage() {
                        chat_id = msg.chat.id,
                        parse_mode = ParseMode.MARKDOWN,
                        text = @"🧑‍🏫️ Преподаватель: *$(name)*\n" + day.to_string()
                    });
                else
                    yield bot.send(new SendMessage() {
                        chat_id = msg.chat.id,
                        text = @"🎉️ $(msg.get_command_name() == "day" ? "Сегодня" : "Завтра") занятий нет!"
                    });
            } else if (msg.chat.type == Chat.Type.PRIVATE)
                yield send_group_warning(msg.chat.id, msg.from.id);
            else
                yield send_group_error("rasp", msg.chat.id);
        }
        
        public async void rasp_command(Message msg) {
            var args = msg.get_command_arguments();
            
            var date = (msg.is_command() && msg.get_command_name().has_suffix("next") || msg.text == "🗓️ След. неделя") ? get_next_week() : get_current_week();
            string? group = null;
            
            if (msg.chat.type != Chat.Type.PRIVATE)
                group = data.get_chat_group(msg.chat.id) ?? data.get_group(msg.from.id);
            else
                group = data.get_group(msg.from.id);
            
            if (args != null)
                group = data.parse_group(args);
            
            var str_date = date.format("%F");
            
            if (group != null)
                yield send_timetable_keyboard(group, str_date, msg.chat.id);
            else if (data.get_post(msg.from.id) == UserPost.TEACHER)
                yield send_teacher_keyboard(data.get_config(msg.from.id).name, str_date, msg.chat.id);
            else if (msg.chat.type == Chat.Type.PRIVATE)
                yield send_group_warning(msg.chat.id, msg.from.id);
            else
                yield send_group_error("rasp", msg.chat.id);
        }
        
        public async void next_command(Message msg) {
            var args = msg.get_command_arguments();
            
            string? group = null;
            
            if (msg.chat.type != Chat.Type.PRIVATE)
                group = data.get_chat_group(msg.chat.id) ?? data.get_group(msg.from.id);
            else
                group = data.get_group(msg.from.id);
            
            if (args != null)
                group = data.parse_group(args);
            
            if (group != null)
                yield send_next_lesson(group, msg.chat.id);
            else if (data.get_post(msg.from.id) == UserPost.TEACHER)
                yield send_next_teacher(data.get_config(msg.from.id).name, msg.chat.id);
            else if (msg.chat.type == Chat.Type.PRIVATE)
                yield send_group_warning(msg.chat.id, msg.from.id);
            else
                yield send_group_error("next", msg.chat.id);
        }
        
        public async void bells_command(Message msg) {
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                parse_mode = ParseMode.MARKDOWN,
                text =
                "🔔️ Расписание пар:\n\n" +
                "1️⃣️ Пара: *8.00-9.25*\n" +
                "Перерыв: *10* мин\n" +
                "2️⃣️ Пара: *9.35-11.00*\n" +
                "Перерыв: *30* мин\n" +
                "3️⃣️ Пара: *11.30-12.55*\n" +
                "Перерыв: *10* мин\n" +
                "4️⃣️ Пара: *13.05-14.30*\n" +
                "Перерыв: *10* мин\n" +
                "5️⃣️ Пара: *14.40-16.05*\n" +
                "Перерыв: *20* мин\n" +
                "6️⃣️ Пара: *16.25-17.50*\n" +
                "Перерыв: *10* мин\n" +
                "7️⃣️ Пара: *18.00-19.25*\n" +
                "Перерыв: *10* мин\n" +
                "8️⃣️ Пара: *19.35-21.00*\n"
            });
        }
        
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
        
        public async void help_command(Message msg) {
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                text =
                "🛟️ Помощь по командам:\n\n" +
                "/day - 🗓️ Расписание на сегодня\n" +
                "/tomorrow - 🗓️ Расписание на завтра\n" +
                "/rasp - 🗓️ Показать расписание на текущую неделю\n" +
                "/raspnext - 🗓️ Показать расписание на след. неделю\n" +
                "/rasp <Группа> - 🗓️ Показать расписание для указанной группы\n" +
                "/next - ⏭️ Показать следующую пару\n" +
                "/bells - 🔔️ Расписание звонков\n" +
                "/bus - 🚍️ Ближайшие автобусы\n" +
                "/settings - ⚙️ Изменить настройки бота\n" +
                "/help - 🛟️ Показать помощь"
            });
        }
        
        private async void send_group_error(string command, ChatId chat_id) {
            yield bot.send(new SendMessage() {
                chat_id = chat_id,
                parse_mode = ParseMode.MARKDOWN,
                text =
                "⚠️ *Группа чата не выбрана!*\n\n" +
                "Владелец чата не выбрал группу, попроси его сделать это.\n" +
                "Либо выберери группу для себя написав мне в личные сообщения @BarsuRaspBot\n" +
                "Или можешь указать группу для команды, например:\n" +
                @"`/$command $(data.get_random_group())`"
            });
        }
        
        private async void send_group_warning(ChatId chat_id, int64 user_id) {
            if (data.get_group(user_id) != null) {
                yield bot.send(new SendMessage() {
                    chat_id = chat_id,
                    parse_mode = ParseMode.MARKDOWN,
                    text = "❌️ *Такая группа не найдена!*\n\nВозможно её нет на официальном сайте расписания, если она там есть - пни админа пусть синхронизирует."
                });
                
                return;
            }
            
            if (data.get_config(user_id) == null)
                data.create_config(user_id);
            
            if (data.get_post(user_id) == null) {
                yield bot.send(new SendMessage() {
                    chat_id = chat_id,
                    parse_mode = ParseMode.MARKDOWN,
                    text = "⚠️ *Сначала выбери группу/преподавателя!*",
                    reply_markup = Keyboards.start_keyboard
                });
                
                return;
            }
            
            if (data.get_post(user_id) == UserPost.TEACHER) {
                yield bot.send(new SendMessage() {
                    chat_id = chat_id,
                    parse_mode = ParseMode.MARKDOWN,
                    text = "⚠️ *Это команда временно недоступна для преподавателей*\nКогда будет готово вы получите сообщение"
                });
            }
        }
        
        private async void request_group(int64 user_id, ChatId chat_id) {
            var group = data.get_group(user_id);
            
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
    }
}
