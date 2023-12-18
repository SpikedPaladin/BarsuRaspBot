using Telegram;

namespace Barsu {
    
    public async void bells_command(Message msg) {
        yield bot.send(new SendMessage() {
            chat_id = msg.chat.id,
            parse_mode = ParseMode.MARKDOWN,
            text =
            "🔔️ Расписание пар:\n\n" +
            "1️⃣️ Пара: *8.00-9.25*\n" +
            "Перерыв: *10* мин\n" +
            "2️⃣️ Пара: *9.35-11.00*\n" +
            "Перерыв: *30* мин\n" +
            "3️⃣️ Пара: *11.30-12.55*\n" +
            "Перерыв: *10* мин\n" +
            "4️⃣️ Пара: *13.05-14.30*\n" +
            "Перерыв: *10* мин\n" +
            "5️⃣️ Пара: *14.40-16.05*\n" +
            "Перерыв: *20* мин\n" +
            "6️⃣️ Пара: *16.25-17.50*\n" +
            "Перерыв: *10* мин\n" +
            "7️⃣️ Пара: *18.00-19.25*\n" +
            "Перерыв: *10* мин\n" +
            "8️⃣️ Пара: *19.35-21.00*\n"
        });
    }
}