using Telegram;

namespace Barsu {
    
    public async void apk_command(Message msg) {
        yield bot.send(new SendMessage() {
            chat_id = msg.chat.id,
            text = "Приложение *Расписание БарГУ*\nТекущая версия: v1.0.9",
            reply_markup = Keyboards.apk_keyboard
        });
    }
}