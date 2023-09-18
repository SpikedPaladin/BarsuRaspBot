using BarsuTimetable;
using Telegram;

namespace Start {
    
    public class StartCommands {
        
        public async void start_command(Message msg) {
            if (config_manager.find_user_group(msg.from.id) != null)
                return;
            
            bot.users_map.set(@"$(msg.from.id)", "start");
            
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                parse_mode = ParseMode.MARKDOWN,
                text = "*Добро пожаловать!*\n\n" + 
                       "✍️ Чтобы начать работу с ботом напиши название своей группы в формате:\n" +
                       @"*$(group_manager.get_random_group())*"
            });
        }
    }
}
