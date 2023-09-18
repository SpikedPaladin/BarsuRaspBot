using Telegram;

namespace BarsuTimetable {
    
    public class BroadcastManager {
        
        public async void broadcast_next_lesson() {
            foreach (var config in config_manager.get_users()) {
                if (!config.subscribed)
                    continue;
                
                yield send_next_lesson(config.group, new ChatId(config.id), false);
            }
            foreach (var config in config_manager.get_chats()) {
                if (!config.subscribed)
                    continue;
                
                yield send_next_lesson(config.group, new ChatId(config.id), false);
            }
        }
        
        public async void send_broadcast(string msg, bool only_subscribed = false) {
            foreach (var config in config_manager.get_users()) {
                if (!config.subscribed && only_subscribed)
                    continue;
                
                yield bot.send(new SendMessage() {
                    chat_id = new ChatId(config.id),
                    parse_mode = ParseMode.MARKDOWN,
                    text = msg
                });
            }
            foreach (var config in config_manager.get_chats()) {
                if (!config.subscribed && only_subscribed)
                    continue;
                
                yield bot.send(new SendMessage() {
                    chat_id = new ChatId(config.id),
                    parse_mode = ParseMode.MARKDOWN,
                    text = msg
                });
            }
        }
    }
}
