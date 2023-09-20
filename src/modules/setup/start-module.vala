using BarsuTimetable;
using Telegram;

namespace Setup {
    
    public class SetupModule {
        
        public SetupModule() {
            add_handlers();
        }
        
        public void add_handlers() {
            var setup_commands = new SetupCommands();
            bot.add_handler(new CommandHandler("start",
                msg => setup_commands.start.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && config_manager.find_user_config(msg.from.id) == null
            ));
            bot.add_handler(new CommandHandler("restart",
                msg => setup_commands.restart.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE
            ));
            
            var setup_messages = new SetupMessages();
            bot.add_handler(new MessageHandler(null,
                msg => setup_messages.post.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && config_manager.get_user_state(msg.from.id) == StartupState.POST
            ));
            bot.add_handler(new MessageHandler(null,
                msg => setup_messages.department.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && config_manager.get_user_state(msg.from.id) == StartupState.DEPARTMENT
            ));
            bot.add_handler(new MessageHandler(null,
                msg => setup_messages.name.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && config_manager.get_user_state(msg.from.id) == StartupState.NAME
            ));
            bot.add_handler(new MessageHandler(null,
                msg => setup_messages.faculty.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && config_manager.get_user_state(msg.from.id) == StartupState.FACULTY
            ));
            bot.add_handler(new MessageHandler(null,
                msg => setup_messages.speciality.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && config_manager.get_user_state(msg.from.id) == StartupState.SPECIALITY
            ));
            bot.add_handler(new MessageHandler(null,
                msg => setup_messages.group.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && config_manager.get_user_state(msg.from.id) == StartupState.GROUP
            ));
        }
    }
}
