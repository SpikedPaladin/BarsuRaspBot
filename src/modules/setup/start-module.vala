using DataStore;
using Telegram;
using Barsu;

namespace Setup {
    
    public class SetupModule {
        
        public async void load() {
            add_handlers();
        }
        
        public void add_handlers() {
            bot.add_handler(new CommandHandler("start",
                msg => start_command.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && data.get_config(msg.from.id, false) == null
            ));
            bot.add_handler(new CommandHandler("restart",
                msg => restart_command.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE
            ));
            bot.add_handler(new CommandHandler("stop",
                msg => stop_command.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE
            ));
            
            var setup_messages = new SetupMessages();
            bot.add_handler(new MessageHandler(null,
                msg => setup_messages.post.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && get_config(msg.from.id).state == UserState.POST
            ));
            bot.add_handler(new MessageHandler(null,
                msg => setup_messages.department.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && get_config(msg.from.id).state == UserState.DEPARTMENT
            ));
            bot.add_handler(new MessageHandler(null,
                msg => setup_messages.name.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && get_config(msg.from.id).state == UserState.NAME
            ));
            bot.add_handler(new MessageHandler(null,
                msg => setup_messages.faculty.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && get_config(msg.from.id).state == UserState.FACULTY
            ));
            bot.add_handler(new MessageHandler(null,
                msg => setup_messages.speciality.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && get_config(msg.from.id).state == UserState.SPECIALITY
            ));
            bot.add_handler(new MessageHandler(null,
                msg => setup_messages.group.begin(msg),
                msg => msg.chat.type == Chat.Type.PRIVATE && get_config(msg.from.id).state == UserState.GROUP
            ));
        }
    }
}
