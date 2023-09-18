using Telegram;

namespace Start {
    
    public class StartModule {
        
        public StartModule() {
            add_handlers();
        }
        
        public void add_handlers() {
            var start_commands = new StartCommands();
            bot.add_handler(new CommandHandler("start", msg => start_commands.start.begin(msg), msg => msg.chat.type == Chat.Type.PRIVATE));
            bot.add_handler(new CommandHandler("restart", msg => start_commands.restart.begin(msg), msg => msg.chat.type == Chat.Type.PRIVATE));
        }
    }
}
