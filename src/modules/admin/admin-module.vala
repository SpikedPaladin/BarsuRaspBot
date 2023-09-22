using Telegram;

namespace Admin {
    
    public class AdminModule {
        
        public async void load() {
            add_handlers();
        }
        
        public void add_handlers() {
            var admin_commands = new AdminCommands();
            bot.add_handler(new CommandHandler("clearconfig", msg => {
                BarsuTimetable.config_manager.remove_config(msg.from.id, false);
            }, msg => msg.from.id == BOSS_ID));
            bot.add_handler(new CommandHandler("stat", msg => admin_commands.stat_command.begin(msg), msg => msg.from.id == BOSS_ID));
            bot.add_handler(new CommandHandler("sync", msg => admin_commands.sync_command.begin(msg), msg => msg.from.id == BOSS_ID));
            bot.add_handler(new CommandHandler("broadcast", msg => admin_commands.broadcast_command.begin(msg), msg => msg.from.id == BOSS_ID));
            bot.add_handler(new CommandHandler("updatecommands", msg => admin_commands.update_commands.begin(msg), msg => msg.from.id == BOSS_ID));
        }
    }
}
