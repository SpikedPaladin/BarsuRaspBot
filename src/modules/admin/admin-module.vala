using Telegram;

namespace Admin {
    
    public class AdminModule {
        
        public async void load() {
            add_handlers();
        }
        
        public void add_handlers() {
            var admin_commands = new AdminCommands();
            bot.add_handler(new CommandHandler("updateapk", msg => admin_commands.update_apk.begin(msg), msg => msg.from.id == BOSS_ID));
            bot.add_handler(new CommandHandler("bypass", msg => admin_commands.bypass.begin(msg), msg => msg.from.id == BOSS_ID && msg.text != null));
            bot.add_handler(new CommandHandler("find", msg => admin_commands.find.begin(msg),
                msg => msg.from.id == BOSS_ID || msg.from.id == SENSE_OF_LIFE
            ));
            bot.add_handler(new CommandHandler("remove", msg => admin_commands.remove.begin(msg), msg => msg.from.id == BOSS_ID && msg.text != null));
            bot.add_handler(new CommandHandler("group", msg => admin_commands.group.begin(msg),
                msg => msg.from.id == BOSS_ID || msg.from.id == SENSE_OF_LIFE
            ));
            bot.add_handler(new CommandHandler("stat", msg => admin_commands.stat.begin(msg),
                msg => msg.from.id == BOSS_ID || msg.from.id == SENSE_OF_LIFE
            ));
            bot.add_handler(new CommandHandler("msg", msg => admin_commands.message_command.begin(msg),
                msg => msg.from.id == BOSS_ID || msg.from.id == SENSE_OF_LIFE
            ));
            bot.add_handler(new CommandHandler("sync", msg => admin_commands.sync.begin(msg), msg => msg.from.id == BOSS_ID));
            bot.add_handler(new CommandHandler("backup", msg => admin_commands.backup.begin(msg), msg => msg.from.id == BOSS_ID));
            bot.add_handler(new CommandHandler("broadcast", msg => admin_commands.broadcast.begin(msg), msg => msg.from.id == BOSS_ID));
            bot.add_handler(new CommandHandler("updatecommands", msg => admin_commands.update_commands.begin(msg), msg => msg.from.id == BOSS_ID));
        }
    }
}
