using Telegram;

namespace Barsu {
    
    public async void send_group(CallbackQuery query) {
        var data = query.data.split(":");
        
        if (data.length == 3) {
            var image = yield image_manager.get_image(get_config(query.from.id).theme, data[2], data[1]);
            
            yield bot.send(new EditMessageMedia() {
                chat_id = query.message.chat.id,
                message_id = query.message.message_id,
                media = new InputMediaPhoto() {
                    media = "week-image.png",
                    bytes = image.bytes
                }
            });
            
            return;
        }
        
        yield send_timetable_date(data[1], data[2], data[3], query);
    }
}