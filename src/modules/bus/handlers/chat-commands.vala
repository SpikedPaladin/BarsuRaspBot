using Telegram;

namespace Bus {
    
    public class ChatCommands {
        
        public async void send_bus(Message msg) {
            if (bus_manager.loaded) {
                yield send_fast_keyboard(msg.chat.id);
            } else {
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = "Информация об расписании автобусов загружается повторите позже."
                });
            }
        }
    }
}
