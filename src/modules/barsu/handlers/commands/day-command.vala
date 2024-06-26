using DataStore;
using Telegram;

namespace Barsu {
    
    public async void day_command(Message msg) {
            var args = msg.get_command_arguments();
            
            var date = (msg.text == "▶️ Сегодня" || msg?.get_command_name() == "day") ? new DateTime.now() : new DateTime.now().add_days(1);
            string? group = null;
            
            if (msg.chat.type != Chat.Type.PRIVATE)
                group = get_chat_config(msg.chat.id).group ?? get_config(msg.from.id).group;
            else
                group = get_config(msg.from.id).group;
            
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
                else {
                    var day_name = "Завтра";
                    if (msg.get_command_name() == "day" || msg.text == "▶️ Сегодня")
                        day_name = "Сегодня";
                    
                    yield bot.send(new SendMessage() {
                        chat_id = msg.chat.id,
                        text = @"🎉️ $day_name пар нет!"
                    });
                }
            } else if (get_config(msg.from.id).post == UserPost.TEACHER) {
                var name = get_config(msg.from.id).name;
                var timetable = yield timetable_manager.get_teacher(name, get_current_week().format("%F"));
                var day = timetable?.get_day_schedule(date);
                
                if (day != null)
                    yield bot.send(new SendMessage() {
                        chat_id = msg.chat.id,
                        parse_mode = ParseMode.MARKDOWN,
                        text = @"🧑‍🏫️ Преподаватель: *$(name)*\n" + day.to_string()
                    });
                else {
                    var day_name = "Завтра";
                    if (msg.get_command_name() == "day" || msg.text == "▶️ Сегодня")
                        day_name = "Сегодня";
                    
                    yield bot.send(new SendMessage() {
                        chat_id = msg.chat.id,
                        text = @"🎉️ $day_name занятий нет!"
                    });
                }
            } else if (msg.chat.type == Chat.Type.PRIVATE)
                yield send_group_warning(msg.chat.id, msg.from.id);
            else
                yield send_group_error("rasp", msg.chat.id);
        }
}