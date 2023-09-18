using Telegram;

namespace BarsuTimetable {
    
    public class GroupMessage {
        
        public async void chat_message(Message msg) {
            var group = group_manager.parse_group(msg.text);
            
            if (group != null) {
                bot.users_map.unset(@"$(msg.from.id)", null);
                config_manager.update_chat_group(msg.chat.id, group);
                
                yield send_settings(msg.chat.id);
            } else {
                Util.log(@"Group not found, request was '$(msg.text)' ($(msg.from.id))", Util.LogLevel.DEBUG);
                
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = @"Такой группы не найдено, попробуй заново"
                });
            }
        }
        
        public async void private_message(Message msg) {
            if (bot.users_map.keys.contains(@"$(msg.from.id)")) {
                var group = group_manager.parse_group(msg.text);
                
                if (group != null) {
                    string origin;
                    
                    bot.users_map.unset(@"$(msg.from.id)", out origin);
                    config_manager.update_user_group(msg.from.id, group);
                    
                    if (origin == "settings")
                        yield send_settings(msg.chat.id, msg.from.id);
                    else if (origin == "start")
                        yield send_start_finished(group, msg.chat.id);
                } else {
                    Util.log(@"Group not found, request was '$(msg.text)' ($(msg.from.id))", Util.LogLevel.DEBUG);
                    
                    yield bot.send(new SendMessage() {
                        chat_id = msg.chat.id,
                        text = @"Такой группы не найдено, попробуй заново.\n"
                    });
                }
            }
        }
    }
}
