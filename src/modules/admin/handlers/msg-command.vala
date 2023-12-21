using Telegram;

namespace Admin {
    
    public async void msg_command(Message msg) {
        if (msg.get_command_arguments() != null) {
            var raw = msg.get_command_arguments().split(" ", 2);
            var response = yield bot.send(new SendMessage() {
                chat_id = new ChatId(int.parse(raw[0])),
                text = raw[1]
            });
            
            if (!response.ok) {
                yield bot.send(new SendMessage() {
                    chat_id = new ChatId(BOSS_ID),
                    text =
                        @"Пытался высрать пиздюку: `$(raw[0])`\n" +
                        @"Эту поеботу: $(raw[1])\n" +
                        "Нихуя не высралось, видимо еблан..."
                });
                return;
            }
            var message = new Message(response.result.get_object());
            
            yield bot.send(new SendMessage() {
                chat_id = new ChatId(BOSS_ID),
                text =
                    @"Высрал пиздюку: `$(raw[0])`\n" +
                    @"Айди хуйни: `$(message.message_id)`\n" +
                    @"Хуйня: $(raw[1])"
            });
        }
    }
}