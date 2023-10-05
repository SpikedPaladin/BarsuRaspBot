using Telegram;

namespace Bus {
    public BusManager bus_manager;
    
    public class BusModule {
        
        public async void load() {
            bus_manager = new BusManager();
            
            yield bus_manager.load();
            
            add_handlers();
        }
        
        public void add_handlers() {
            var chat_commands = new ChatCommands();
            bot.add_handler(new MessageHandler("🚍️ Автобусы", msg => chat_commands.send_bus.begin(msg)));
            bot.add_handler(new CommandHandler("bus", msg => chat_commands.send_bus.begin(msg)));
            
            var button_actions = new ButtonActions();
            bot.add_handler(new CallbackQueryHandler(null,
                query => button_actions.from_sweethome.begin(query),
                query => query.data.has_prefix("busfasttest") && query.data.split(":")[1] == "from_sweethome"));
            bot.add_handler(new CallbackQueryHandler(null,
                query => button_actions.to_sweethome.begin(query),
                query => query.data.has_prefix("busfasttest") && query.data.split(":")[1] == "to_sweethome"));
            bot.add_handler(new CallbackQueryHandler(null,
                query => send_bus_number_keyboard.begin(query.message.chat.id, query.message.message_id),
                query => query.data.has_prefix("busfasttest") && query.data.split(":")[1] == "choose"));
            bot.add_handler(new CallbackQueryHandler(null,
                query => button_actions.bus_selected.begin(query),
                query => query.data.has_prefix("bustest") && query.data.split(":").length == 2));
            bot.add_handler(new CallbackQueryHandler(null,
                query => button_actions.direction_selected.begin(query),
                query => query.data.has_prefix("bustest") && query.data.split(":").length == 3));
            bot.add_handler(new CallbackQueryHandler(null,
                query => button_actions.stop_selected.begin(query),
                query => query.data.has_prefix("bustest") && query.data.split(":").length == 4));
        }
    }
    
    public async void send_fast_keyboard(ChatId chat_id) {
        yield bot.send(new SendMessage() {
            chat_id = chat_id,
            text = "🚍️ Выбери маршрут или номер:",
            reply_markup = Keyboards.fast_bus_keyboard
        });
    }
    
    public async void send_bus_number_keyboard(ChatId chat_id, int message_id) {
        yield bot.send(new EditMessageText() {
            chat_id = chat_id,
            message_id = message_id,
            text = "🚍️ Выбери номер автобуса:",
            reply_markup = create_bus_number_keyboard()
        });
    }
    
    public InlineKeyboardMarkup create_bus_number_keyboard() {
        var markup = new InlineKeyboardMarkup();
        
        for (int i = 0; i < 32; i++) {
            if (i % 4 == 0)
                markup.new_row();
            
            markup.add_button(new InlineKeyboardButton() { text = @"$(i + 1)", callback_data = @"bustest:$(i + 1)" });
        }
        
        return markup;
    }
}
