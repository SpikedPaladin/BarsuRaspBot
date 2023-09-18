using Telegram;

namespace Bus {
    
    public class ButtonActions {
        
        public async void bus_selected(CallbackQuery query) {
            var num = int.parse(query.data.split(":")[1]);
            var bus = bus_manager.get_bus_info(num);
            
            yield bot.send(new EditMessageText() {
                chat_id = query.message.chat.id,
                message_id = query.message.message_id,
                text = "🚍️ Выбери направление:",
                reply_markup = create_bus_direction_keyboard(bus)
            });
        }
        
        public async void direction_selected(CallbackQuery query) {
            var num = int.parse(query.data.split(":")[1]);
            var forward = query.data.split(":")[2] == "forward";
            var bus = bus_manager.get_bus_info(num);
            
            yield bot.send(new EditMessageText() {
                chat_id = query.message.chat.id,
                message_id = query.message.message_id,
                text = "🚍️ Выбери остановку:",
                reply_markup = create_bus_stops_keyboard(bus, forward)
            });
        }
        
        public async void stop_selected(CallbackQuery query) {
            var num = int.parse(query.data.split(":")[1]);
            var forward = query.data.split(":")[2] == "forward";
            var index = int.parse(query.data.split(":")[3]);
            var bus = bus_manager.get_bus_info(num);
            BusStop stop;
            
            if (forward)
                stop = bus.stops[index];
            else
                stop = bus.backward_stops[index];
            
            var times = stop.get_nearest_time(3);
            var msg = @"🚍️ $(bus.number) $(bus.get_name(forward))\n" +
                      @"🪧️ $(stop.name)\n";
            
            if (times != null) for (var i = 0; i < times.length; i++) {
                var time = times[i];
                msg += @"🕓️ *$(time.hour):$(time.minute < 10 ? "0" : "")$(time.minute)*\n";
            } else
                msg += @"По $(new DateTime.now().get_day_of_week() > 5 ? "выходным" : "будням") автобус не ездит.";
            
            if (times != null && times.length == 0)
                msg += @"Сегодня автобус больше не ездит.";
            
            yield bot.send(new EditMessageReplyMarkup() {
                chat_id = query.message.chat.id,
                message_id = query.message.message_id
            });
            
            yield bot.send(new EditMessageText() {
                chat_id = query.message.chat.id,
                message_id = query.message.message_id,
                parse_mode = ParseMode.MARKDOWN,
                text = msg
            });
        }
        
        public InlineKeyboardMarkup create_bus_stops_keyboard(BusInfo bus, bool forward = true) {
            var markup = new InlineKeyboardMarkup();
            BusStop[] stops = null;
            
            if (forward)
                stops = bus.stops;
            else
                stops = bus.backward_stops;
            
            for (int i = 0; i < stops.length; i++) {
                var stop = stops[i];
                markup.add_button(new InlineKeyboardButton() { text = stop.name, callback_data = @"bustest:$(bus.number):$(forward ? "forward" : "backward"):$i" });
                markup.new_row();
            }
            
            return markup;
        }
        
        public InlineKeyboardMarkup create_bus_direction_keyboard(BusInfo bus) {
            var markup = new InlineKeyboardMarkup();
            
            markup.add_button(new InlineKeyboardButton() { text = bus.name, callback_data = @"bustest:$(bus.number):forward" });
            
            if (bus.has_backward)
                markup.new_row().add_button(new InlineKeyboardButton() { text = bus.backward_name, callback_data = @"bustest:$(bus.number):backward" });
            
            return markup;
        }
    }
}
