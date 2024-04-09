using Telegram;

namespace Barsu {
    
    public async void empty(CallbackQuery query) {
        yield bot.send(new AnswerCallbackQuery() {
            callback_query_id = query.id
        });
    }
}