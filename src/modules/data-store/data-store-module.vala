using Telegram;

namespace DataStore {
    public DataManager data;
    
    public class DataStoreModule {
        
        public async void load() {
            data = new DataManager();
            
            yield data.load();
            
            add_handlers();
        }
        
        public void add_handlers() {
            bot.add_handler(new CommandHandler("settings", msg => settings_command.begin(msg)));
            bot.add_handler(new MessageHandler("⚙️ Настройки", msg => settings_command.begin(msg)));
            
            bot.add_handler(new CallbackQueryHandler("enable_sub", query => enable_subscription.begin(query)));
            bot.add_handler(new CallbackQueryHandler("disable_sub", query => disable_subscription.begin(query)));
            bot.add_handler(new CallbackQueryHandler("change_group", query => change_group.begin(query)));
            bot.add_handler(new CallbackQueryHandler("change_theme", query => change_theme.begin(query)));
        }
    }
}
