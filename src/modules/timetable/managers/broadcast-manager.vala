using Telegram;

namespace BarsuTimetable {
    
    public class BroadcastManager {
        
        public async void broadcast_next_lesson() {
            foreach (var config in config_manager.get_users()) {
                if (!config.subscribed)
                    continue;
                
                if (config.type == ConfigType.TEACHER)
                    yield send_next_teacher(config.name, new ChatId(config.id), false);
                else
                    yield send_next_lesson(config.group, new ChatId(config.id), false);
            }
            foreach (var config in config_manager.get_chats()) {
                if (!config.subscribed)
                    continue;
                
                yield send_next_lesson(config.group, new ChatId(config.id), false);
            }
        }
        
        public async void send_broadcast(ChatId chat_id, int message_id, bool only_subscribed = false) {
            foreach (var config in config_manager.get_users()) {
                if (!config.subscribed && only_subscribed)
                    continue;
                
                yield bot.send(new CopyMessage() {
                    chat_id = new ChatId(config.id),
                    from_chat_id = chat_id,
                    message_id = message_id
                });
            }
            foreach (var config in config_manager.get_chats()) {
                if (!config.subscribed && only_subscribed)
                    continue;
                
                yield bot.send(new CopyMessage() {
                    chat_id = new ChatId(config.id),
                    from_chat_id = chat_id,
                    message_id = message_id
                });
            }
        }
    }
}
