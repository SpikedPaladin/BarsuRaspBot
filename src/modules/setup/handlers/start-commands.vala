using BarsuTimetable;
using DataStore;
using Telegram;

namespace Setup {
    
    public ReplyKeyboardMarkup faculty_keyboard() {
        var keyboard = new ReplyKeyboardMarkup() { is_persistent = true, resize_keyboard = true };
        
        foreach (var faculty in group_manager.get_faculties()) {
            keyboard.add_button(new KeyboardButton() { text = faculty.name }).new_row();
        }
        
        return keyboard;
    }
    
    public class SetupCommands {
        
        public async void start(Message msg) {
            data.set_state(msg.from.id, UserState.POST);
            
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                parse_mode = ParseMode.MARKDOWN,
                reply_markup = Keyboards.post_keyboard,
                text = "*Добро пожаловать!*\n\n" +
                       "✍️ Ты студент или преподаватель?\n"
            });
        }
        
        public async void restart(Message msg) {
            data.remove_config(msg.from.id);
            
            yield start(msg);
        }
    }
}
