using BarsuTimetable;
using Telegram;

namespace Start {
    
    public class StartCommands {
        
        public async void start(Message msg) {
            config_manager.set_user_state(msg.from.id, StartupState.FACULTY);
            
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                parse_mode = ParseMode.MARKDOWN,
                reply_markup = faculty_keyboard(),
                text = "*Добро пожаловать!*\n\n🕶️ Выбери свой факультет"
            });
            
            // config_manager.set_user_state(msg.from.id, StartupState.POST);
            
            // yield bot.send(new SendMessage() {
            //     chat_id = msg.chat.id,
            //     parse_mode = ParseMode.MARKDOWN,
            //     reply_markup = Keyboards.post_keyboard,
            //     text = "*Добро пожаловать!*\n\n" +
            //            "✍️ Ты студент или преподаватель?\n"
            // });
        }
        public ReplyKeyboardMarkup faculty_keyboard() {
            var keyboard = new ReplyKeyboardMarkup() { is_persistent = true, resize_keyboard = true };
            
            foreach (var faculty in group_manager.get_faculties()) {
                keyboard.add_button(new KeyboardButton() { text = faculty.name }).new_row();
            }
            
            return keyboard;
        }
        
        public async void restart(Message msg) {
            config_manager.remove_config(msg.from.id, false);
            
            yield start(msg);
        }
    }
}
