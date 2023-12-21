using DataStore;
using Telegram;

namespace Admin {
    
    public async void stat(Message msg) {
        if (msg.get_command_arguments() == "teacher") {
            string text = "Преподы:\n";
            foreach (var config in data.get_users().to_array()) {
                if (config.post != UserPost.TEACHER)
                    continue;
                
                text += @"$(config.name) ";
                text += yield mention(config.id);
                text += "\n";
            }
            
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                parse_mode = ParseMode.HTML,
                text = text
            });
            
            return;
        }
        
        int sub_count = 0, registered = 0, changing = 0, start_selecting = 0, teachers = 0, retarded = 0;
        
        foreach (var config in data.get_users().to_array()) {
            if (config.subscribed)
                sub_count++;
            
            if (config.post == null && config.state == null)
                retarded++;
            
            if (config.post != null && config.state != null)
                changing++;
            
            if (config.post == null && config.state != null)
                start_selecting++;
            
            if (config.post != null && config.state == null)
                registered++;
            
            if (config.post == UserPost.TEACHER)
                teachers++;
        }
        
        string text = @"👥️ Чатиксы: *$(data.get_chats().size)*\n";
        
        text += "\n👤️ Юзеры:\n";
        text += @"Всего: $(data.get_users().size) (*$registered*/$changing/$start_selecting)\n";
        text += @"Додики: $retarded\n";
        text += @"Преподов: *$teachers*\n";
        text += @"Подсосы: $sub_count";
        
        yield bot.send(new SendMessage() {
            chat_id = msg.chat.id,
            text = text
        });
    }
}