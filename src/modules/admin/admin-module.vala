using Telegram;

namespace Admin {
    
    public class AdminModule {
        
        public async void load() {
            add_handlers();
        }
        
        public void add_handlers() {
            bot.add_handler(new CommandHandler("updateapk", msg => update_apk.begin(msg), msg => msg.from.id == BOSS_ID));
            bot.add_handler(new CommandHandler("find", msg => find.begin(msg),
                msg => msg.from.id == BOSS_ID || msg.from.id == SENSE_OF_LIFE
            ));
            bot.add_handler(new CommandHandler("remove", msg => remove.begin(msg), msg => msg.from.id == BOSS_ID && msg.text != null));
            bot.add_handler(new CommandHandler("group", msg => group.begin(msg),
                msg => msg.from.id == BOSS_ID || msg.from.id == SENSE_OF_LIFE
            ));
            bot.add_handler(new CommandHandler("stat", msg => stat.begin(msg),
                msg => msg.from.id == BOSS_ID || msg.from.id == SENSE_OF_LIFE
            ));
            bot.add_handler(new CommandHandler("msg", msg => msg_command.begin(msg),
                msg => msg.from.id == BOSS_ID || msg.from.id == SENSE_OF_LIFE
            ));
            bot.add_handler(new CommandHandler("sync", msg => sync.begin(msg), msg => msg.from.id == BOSS_ID));
            bot.add_handler(new CommandHandler("backup", msg => backup.begin(msg), msg => msg.from.id == BOSS_ID));
            bot.add_handler(new CommandHandler("broadcast", msg => broadcast.begin(msg), msg => msg.from.id == BOSS_ID));
            bot.add_handler(new CommandHandler("updatecommands", msg => cmds_command.begin(msg), msg => msg.from.id == BOSS_ID));
        }
    }
    
    private async string mention(int64 user_id) {
        var chat = yield bot.get_chat(new ChatId(user_id));
        string mention = null;
        
        if (user_id == BOSS_ID)
            mention = @"<a href=\"tg://user?id=$BOSS_ID\">Я тебя ❤️</a>";
        else if (user_id == SENSE_OF_LIFE)
            mention = @"<a href=\"tg://user?id=$SENSE_OF_LIFE\">❤️❤️❤️❤️❤️</a>";
        else if (chat.username != null)
            mention = @"@$(chat.username)";
        else if (chat != null)
            mention = @"<a href=\"tg://user?id=$(chat.id)\">$(chat.first_name)</a> <code>$(chat.id)</code>";
        else
            mention = @"Чмоня забанил ($user_id)";
        
        return mention;
    }
}
