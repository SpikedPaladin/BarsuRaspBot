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
        }
    }
}
