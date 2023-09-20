using BarsuTimetable;
using Telegram;

namespace Start {
    
    public class StartModule {
        
        public StartModule() {
            add_handlers();
        }
        
        public void add_handlers() {
            var start_commands = new StartCommands();
            bot.add_handler(new CommandHandler("start",
                msg => start_commands.start.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && config_manager.find_user_config(msg.from.id) == null
            ));
            bot.add_handler(new CommandHandler("restart",
                msg => start_commands.restart.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE
            ));
            
            var start_messages = new StartMessages();
            bot.add_handler(new MessageHandler(null,
                msg => start_messages.post.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && config_manager.get_user_state(msg.from.id) == StartupState.POST
            ));
            bot.add_handler(new MessageHandler(null,
                msg => start_messages.department.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && config_manager.get_user_state(msg.from.id) == StartupState.DEPARTMENT
            ));
            bot.add_handler(new MessageHandler(null,
                msg => start_messages.name.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && config_manager.get_user_state(msg.from.id) == StartupState.NAME
            ));
            bot.add_handler(new MessageHandler(null,
                msg => start_messages.faculty.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && config_manager.get_user_state(msg.from.id) == StartupState.FACULTY
            ));
            bot.add_handler(new MessageHandler(null,
                msg => start_messages.speciality.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && config_manager.get_user_state(msg.from.id) == StartupState.SPECIALITY
            ));
            bot.add_handler(new MessageHandler(null,
                msg => start_messages.group.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && config_manager.get_user_state(msg.from.id) == StartupState.GROUP
            ));
        }
    }
}
