using Telegram;

namespace DataStore {
    
    public async void change_theme(CallbackQuery query) {
        var chat_id = query.message.chat.id;
        
        if (query.message.chat.type == Chat.Type.PRIVATE) {
            var theme = get_config(query.from.id).selectedTheme;
            
            if (theme == SelectedTheme.CLASSIC)
                get_config(query.from.id).selectedTheme = SelectedTheme.DARK_BLUE;
            else
                get_config(query.from.id).selectedTheme = SelectedTheme.CLASSIC;
            
            yield bot.send(new EditMessageText() {
                chat_id = chat_id,
                message_id = query.message.message_id,
                text = get_config(query.from.id).to_string(),
                parse_mode = ParseMode.MARKDOWN,
                reply_markup = get_config(query.from.id).subscribed ? Keyboards.disable_sub_keyboard : Keyboards.enable_sub_keyboard
            });
        }
    }
}