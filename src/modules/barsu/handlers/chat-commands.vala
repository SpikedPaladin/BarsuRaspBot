using DataStore;
using Telegram;

namespace Barsu {
    
    private async void send_group_error(string command, ChatId chat_id) {
        yield bot.send(new SendMessage() {
            chat_id = chat_id,
            parse_mode = ParseMode.MARKDOWN,
            text =
            "⚠️ *Группа чата не выбрана!*\n\n" +
            "Владелец чата не выбрал группу, попроси его сделать это.\n" +
            "Либо выберери группу для себя написав мне в личные сообщения @BarsuRaspBot\n" +
            "Или можешь указать группу для команды, например:\n" +
            @"`/$command $(data.get_random_group())`"
        });
    }
    
    private async void send_group_warning(ChatId chat_id, int64 user_id) {
        if (get_config(user_id).post != null) {
            yield bot.send(new SendMessage() {
                chat_id = chat_id,
                parse_mode = ParseMode.MARKDOWN,
                text = "❌️ *Такая группа не найдена!*\n\nВозможно её нет на официальном сайте расписания, если она там есть - пни админа пусть синхронизирует."
            });
            
            return;
        }
        
        if (get_config(user_id).post == null) {
            yield bot.send(new SendMessage() {
                chat_id = chat_id,
                parse_mode = ParseMode.MARKDOWN,
                text = "⚠️ *Сначала выбери группу/преподавателя!*",
                reply_markup = Keyboards.start_keyboard
            });
            
            return;
        }
        
        if (get_config(user_id).post == UserPost.TEACHER) {
            yield bot.send(new SendMessage() {
                chat_id = chat_id,
                parse_mode = ParseMode.MARKDOWN,
                text = "⚠️ *Это команда временно недоступна для преподавателей*\nКогда будет готово вы получите сообщение"
            });
        }
    }
    
    private async void request_group(int64 user_id, ChatId chat_id) {
        var group = get_config(user_id).group;
        
        if (group == null)
            yield bot.send(new SendMessage() {
                chat_id = chat_id,
                text = "⚠️ Сначала выбери группу для себя, чтобы потом установить её для группы",
                reply_markup = Keyboards.open_bot_keyboard
            });
        else
            yield bot.send(new SendMessage() {
                chat_id = chat_id,
                parse_mode = ParseMode.MARKDOWN,
                text =
                @"✍️ Твоя группа *$group*\nНажми чтобы установить ее для группы",
                reply_markup = Keyboards.owner_keyboard
            });
    }
}
