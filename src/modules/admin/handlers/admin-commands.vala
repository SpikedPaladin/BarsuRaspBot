using BarsuTimetable;
using DataStore;
using Telegram;
using Gee;

namespace Admin {
    
    public class AdminCommands {
        
        public async void stat(Message msg) {
            if (msg.get_command_arguments() == "teacher") {
                string text = "Преподаватели:\n";
                foreach (var config in data.get_users()) {
                    if (config.post != UserPost.TEACHER)
                        continue;
                    
                    text += @"[$(config.name)](tg://user?id=$(config.id))\n";
                }
                
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    parse_mode = ParseMode.MARKDOWN,
                    text = text
                });
                
                return;
            }
            
            int sub_count = 0, registered = 0, in_setup = 0, teachers = 0;
            
            HashMap<string, int> chats = new HashMap<string, int>();
            foreach (var config in data.get_chats()) {
                if (chats.has_key(config.group))
                    chats.set(config.group, chats.get(config.group) + 1);
                else
                    chats.set(config.group, 1);
            }
            
            foreach (var config in data.get_users()) {
                if (config.subscribed)
                    sub_count++;
                
                if (config.state != null)
                    in_setup++;
                
                if (config.post != null)
                    registered++;
                
                if (config.post == UserPost.TEACHER)
                    teachers++;
            }
            
            int count = 0;
            string text = "👥️ Группы:\n";
            foreach (var chat in chats) {
                text += @"$(chat.key) - $(chat.value)\n";
                count += chat.value;
            }
            text += @"Всего: *$count*\n";
            
            text += "\n👤️ Пользователи:\n";
            text += @"Всего: $(data.get_users().size) (*$registered*/$in_setup)\n";
            text += @"Преподаватели: *$teachers*\n";
            text += @"Подписано: $sub_count";
            
            yield bot.send(new SendMessage() {
                parse_mode = ParseMode.MARKDOWN,
                chat_id = msg.chat.id,
                text = text
            });
        }
        
        public async void broadcast(Message msg) {
            if (msg.reply_to_message == null) {
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = "⚠️ Нужно отправлять ответом на сообщение"
                });
                
                return;
            }
            
            yield broadcast_manager.send_broadcast(msg.chat.id, msg.reply_to_message.message_id, false);
        }
        
        public async void sync(Message msg) {
            var last_fetch = group_manager.get_last_fetch();
            var response = yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                parse_mode = ParseMode.MARKDOWN,
                text = "*Группы синхронизируются...*\n\n" +
                       @"Последнее обновление: $last_fetch"
            });
            var message_id = new Message(response.result.get_object()).message_id;
            
            yield group_manager.sync();
            yield bot.send(new EditMessageText() {
                chat_id = msg.chat.id,
                message_id = message_id,
                parse_mode = ParseMode.MARKDOWN,
                text = "*Группы обновлены!*\n\n" +
                      @"Последнее обновление: $last_fetch"
            });
        }
        
        public async void update_commands(Message msg) {
            var day = new BotCommand() {
                command = "day",
                description = "На сегодня"
            };
            var tomorrow = new BotCommand() {
                command = "tomorrow",
                description = "На завтра"
            };
            var rasp = new BotCommand() {
                command = "rasp",
                description = "На эту неделю"
            };
            var raspnext = new BotCommand() {
                command = "raspnext",
                description = "На след. неделю"
            };
            var next = new BotCommand() {
                command = "next",
                description = "Следующая пара"
            };
            var bells = new BotCommand() {
                command = "bells",
                description = "Звонки"
            };
            var bus = new BotCommand() {
                command = "bus",
                description = "Ближайшие автобусы"
            };
            var settings = new BotCommand() {
                command = "settings",
                description = "Настройки"
            };
            var help = new BotCommand() {
                command = "help",
                description = "Показать помощь"
            };
            
            yield bot.send(new SetMyCommands() {
                commands = { day, tomorrow, rasp, raspnext, next, bells, bus, help },
                scope = new BotCommandScopeDefault()
            });
            yield bot.send(new SetMyCommands() {
                commands = { day, tomorrow, rasp, raspnext, next, bells, bus, settings, help },
                scope = new BotCommandScopeAllPrivateChats()
            });
            yield bot.send(new SetMyCommands() {
                commands = { day, tomorrow, rasp, raspnext, next, bells, bus, settings, help },
                scope = new BotCommandScopeAllChatAdministrators()
            });
        }
    }
}
