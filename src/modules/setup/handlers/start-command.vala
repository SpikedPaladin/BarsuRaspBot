using DataStore;
using Telegram;

namespace Setup {
    
    public async void start_command(Message msg) {
        data.create_config(msg.from.id);
        
        yield bot.send(new SendMessage() {
            chat_id = msg.chat.id,
            parse_mode = ParseMode.HTML,
            reply_markup = Keyboards.start_keyboard,
            text = @"👋️ Привет, <b>$(msg.from.first_name)</b>\n\n" +
                   "🤖️ Я твой личный помощник по расписанию занятий. Я могу показать тебе расписание на сегодня, завтра " +
                   "или на любой другой день, а также расписание на неделю 🖼️\n\n" +
                   "🔍️ Я также могу выполнять <b>поиск по группам и преподавателям</b>. Для этого просто отправь " +
                   "мне первые буквы из имени преподавателя или названия группы.\n\n" +
                   "ℹ️ Не забудь выбрать свою группу, это позволит мне показывать тебе только расписание твоих занятий.\n\n" +
                   "Чтобы выбрать группу нажми кнопку \"Выбрать группу/преподавателя\"\n\n" +
                   "После того, как ты выберешь группу, ты сможешь подписаться на уведомления о следующем занятии командой - <b>/settings</b>\n\n" +
                   "<tg-spoiler>P.S. Если у тебя есть какие-либо вопросы или пожелания, можешь их отправить моему администратору, он всегда рад помочь.</tg-spoiler>\n"
        });
    }
}