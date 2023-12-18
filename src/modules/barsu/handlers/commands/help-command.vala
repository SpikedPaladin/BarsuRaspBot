using Telegram;

namespace Barsu {
    
    public async void help_command(Message msg) {
        yield bot.send(new SendMessage() {
            chat_id = msg.chat.id,
            text =
                "🛟️ Помощь по командам:\n\n" +
                "/day - 🗓️ Расписание на сегодня\n" +
                "/tomorrow - 🗓️ Расписание на завтра\n" +
                "/rasp - 🗓️ Показать расписание на текущую неделю\n" +
                "/raspnext - 🗓️ Показать расписание на след. неделю\n" +
                "/rasp <Группа> - 🗓️ Показать расписание для указанной группы\n" +
                "/next - ⏭️ Показать следующую пару\n" +
                "/bells - 🔔️ Расписание звонков\n" +
                "/bus - 🚍️ Ближайшие автобусы\n" +
                "/settings - ⚙️ Изменить настройки бота\n" +
                "/help - 🛟️ Показать помощь"
        });
    }
}