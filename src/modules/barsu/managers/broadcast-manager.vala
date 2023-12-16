using DataStore;
using Telegram;

namespace Barsu {
    
    public class BroadcastManager {
        
        public async void broadcast_next_lesson() {
            foreach (var config in data.get_users().to_array()) {
                if (!config.subscribed)
                    continue;
                
                if (config.post == UserPost.TEACHER)
                    yield send_next_teacher(config.name, new ChatId(config.id), false);
                else
                    yield send_next_lesson(config.group, new ChatId(config.id), false);
            }
            foreach (var config in data.get_chats().to_array()) {
                if (!config.subscribed)
                    continue;
                
                yield send_next_lesson(config.group, new ChatId(config.id), false);
            }
        }
        
        public async void send_broadcast(ChatId chat_id, int message_id, ReplyMarkup? reply_markup = null, bool only_subscribed = false) {
            foreach (var config in data.get_users().to_array()) {
                if (!config.subscribed && only_subscribed)
                    continue;
                
                yield bot.send(new CopyMessage() {
                    chat_id = new ChatId(config.id),
                    from_chat_id = chat_id,
                    message_id = message_id,
                    reply_markup = reply_markup
                });
            }
            foreach (var config in data.get_chats().to_array()) {
                if (!config.subscribed && only_subscribed)
                    continue;
                
                yield bot.send(new CopyMessage() {
                    chat_id = new ChatId(config.id),
                    from_chat_id = chat_id,
                    message_id = message_id,
                    reply_markup = reply_markup
                });
            }
        }
    }
}
