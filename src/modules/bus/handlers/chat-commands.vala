using Telegram;

namespace Bus {
    
    public class ChatCommands {
        
        public async void sync(Message msg) {
            var response = yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                text = "Обновляю автобусы:\nПрогрес: (0/32)"
            });
            
            var message_id = new Message(response.result.get_object()).message_id;
            
            yield bus_manager.sync(number => {
                bot.send.begin(new EditMessageText() {
                    chat_id = msg.chat.id,
                    message_id = message_id,
                    text = @"Обновляю автобусы:\nПрогрес: ($number/32)"
                });
            });
            
            yield bot.send(new EditMessageText() {
                chat_id = msg.chat.id,
                message_id = message_id,
                text = "*Автобусы обновлены*"
            });
        }
        
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
