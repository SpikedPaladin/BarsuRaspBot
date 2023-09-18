using Telegram;

namespace Start {
    
    public class StartModule {
        
        public StartModule() {
            add_handlers();
        }
        
        public void add_handlers() {
            var start_commands = new StartCommands();
            bot.add_handler(new CommandHandler("start", msg => start_commands.start_command.begin(msg), msg => msg.chat.type == Chat.Type.PRIVATE));
        }
    }
}
