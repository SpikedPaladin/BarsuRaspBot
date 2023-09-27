using Barsu;
using DataStore;
using Telegram;
using Gee;

namespace Admin {
    
    public class AdminCommands {
        
        public async void ping(Message msg) {
            var id = int64.parse(msg.get_command_arguments());
            var chat = yield bot.get_chat(new ChatId(id));
            
            if (chat != null)
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = @"Попался гадёныш!\n@$(chat.username ?? "[Пиздюк](tg://user?id=$(chat.id))")"
                });
            else
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = @"Пидор забанил!"
                });
        }
        
        public async void remove(Message msg) {
            var id = int64.parse(msg.text);
            
            if (data.get_config(id) != null) {
                data.remove_config(id, false);
                
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = "Ебнул дауна!"
                });
            } else
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = "Повезло додику его конфига нет!"
                });
        }
        
        public async void group(Message msg) {
            var group = data.parse_group(msg.get_command_arguments());
            int count = 0;
            if (group != null) {
                var text = "Попались ебланчики:\n";
                foreach (var config in data.get_users()) {
                    if (config.group != group)
                        continue;
                    
                    text += @"[Пиздюк](tg://user?id=$(config.id)) `$(config.id)`\n";
                    count++;
                }
                
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = text + @"Всего пиздюков: $count"
                });
            } else
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = "Блять ну ты/я еблан пиздец"
                });
        }
        
        public async void stat(Message msg) {
            if (msg.get_command_arguments() == "teacher") {
                string text = "Преподы:\n";
                foreach (var config in data.get_users()) {
                    if (config.post != UserPost.TEACHER)
                        continue;
                    
                    text += @"[$(config.name)](tg://user?id=$(config.id)) `$(config.id)`\n";
                }
                
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    parse_mode = ParseMode.MARKDOWN,
                    text = text
                });
                
                return;
            }
            
            int sub_count = 0, registered = 0, changing = 0, start_selecting = 0, teachers = 0;
            
            foreach (var config in data.get_users()) {
                if (config.subscribed)
                    sub_count++;
                
                if (config.post != null && config.state != null)
                    changing++;
                
                if (config.post == null && config.state != null)
                    start_selecting++;
                
                if (config.post != null)
                    registered++;
                
                if (config.post == UserPost.TEACHER)
                    teachers++;
            }
            
            string text = @"👥️ Чатиксы: *$(data.get_chats().size)*\n";
            
            text += "\n👤️ Юзеры:\n";
            text += @"Всего: $(data.get_users().size) (*$registered*/$changing/$start_selecting)\n";
            text += @"Преподов: *$teachers*\n";
            text += @"Подсосы: $sub_count";
            
            yield bot.send(new SendMessage() {
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
            var response = yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                parse_mode = ParseMode.MARKDOWN,
                text = "*Группы синхронизируются...*"
            });
            var message_id = new Message(response.result.get_object()).message_id;
            
            yield data.sync();
            yield bot.send(new EditMessageText() {
                chat_id = msg.chat.id,
                message_id = message_id,
                parse_mode = ParseMode.MARKDOWN,
                text = "*Группы обновлены!*"
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
