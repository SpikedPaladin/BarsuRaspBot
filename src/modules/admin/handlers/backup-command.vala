using Telegram;

namespace Admin {
    
    public async void backup(Message msg) {
        var file = File.new_for_path(@".cache/TelegramBots/BarsuRaspBot/$(msg.get_command_arguments()).json");
        
        if (file.query_exists()) {
            yield bot.send(new SendChatAction() {
                chat_id = msg.chat.id,
                action = ChatAction.UPLOAD_DOCUMENT
            });
            yield bot.send(new SendDocument() {
                chat_id = msg.chat.id,
                document = @"file://$(file.get_path())"
            });
        } else
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                text = "Ты/я балбес!"
            });
    }
}