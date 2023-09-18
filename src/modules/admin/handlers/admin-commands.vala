using BarsuTimetable;
using Telegram;
using Gee;

namespace Admin {
    
    public class AdminCommands {
        
        public async void stat_command(Message msg) {
            int sub_count = 0;
            
            HashMap<string, int> chats = new HashMap<string, int>();
            foreach (var config in config_manager.get_chats()) {
                if (chats.has_key(config.group))
                    chats.set(config.group, chats.get(config.group) + 1);
                else
                    chats.set(config.group, 1);
            }
            
            HashMap<string, int> users = new HashMap<string, int>();
            foreach (var config in config_manager.get_users()) {
                if (config.subscribed)
                    sub_count++;
                
                if (users.has_key(config.group))
                    users.set(config.group, users.get(config.group) + 1);
                else
                    users.set(config.group, 1);
            }
            
            int count = 0;
            string text = "Группы:\n";
            foreach (var chat in chats) {
                text += @"$(chat.key) - $(chat.value)\n";
                count += chat.value;
            }
            text += @"Всего: $count\n";
            
            text += "\nПользователи:\n";
            count = 0;
            
            foreach (var user in users) {
                text += @"$(user.key) - $(user.value)\n";
                count += user.value;
            }
            text += @"Всего: $count\n";
            text += @"Подписано: $sub_count";
            
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                text = text
            });
        }
        
        public async void broadcast_command(Message msg) {
            yield broadcast_manager.send_broadcast(msg.get_command_arguments(), false);
        }
        
        public async void sync_command(Message msg) {
            var last_fetch = group_manager.get_last_fetch();
            var response = yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                text = "*Группы синхронизируются...*\n\n" +
                       @"Последнее обновление: $last_fetch"
            });
            var message_id = new Message(response.result.get_object()).message_id;
            
            var updated = yield group_manager.sync();
            
            if (updated) {
                yield bot.send(new EditMessageText() {
                    chat_id = msg.chat.id,
                    message_id = message_id,
                    text = "Группы обновлены!" +
                          @"Последнее обновление: $last_fetch"
                });
            } else {
                yield bot.send(new EditMessageText() {
                    chat_id = msg.chat.id,
                    message_id = message_id,
                    text = "Обновление не требуется!" +
                          @"Последнее обновление: $last_fetch"
                });
            }
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
                description = "Выбрать день"
            };
            var raspnext = new BotCommand() {
                command = "raspnext",
                description = "Выбрать день (след. неделя)"
            };
            var next = new BotCommand() {
                command = "next",
                description = "Следующая пара"
            };
            var week = new BotCommand() {
                command = "week",
                description = "На эту неделю"
            };
            var weeknext = new BotCommand() {
                command = "weeknext",
                description = "На след. неделю"
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
                commands = { day, tomorrow, rasp, raspnext, next, week, weeknext, bells, bus, help },
                scope = new BotCommandScopeDefault()
            });
            yield bot.send(new SetMyCommands() {
                commands = { day, tomorrow, rasp, raspnext, next, week, weeknext, bells, bus, settings, help },
                scope = new BotCommandScopeAllPrivateChats()
            });
            yield bot.send(new SetMyCommands() {
                commands = { day, tomorrow, rasp, raspnext, next, week, weeknext, bells, bus, settings, help },
                scope = new BotCommandScopeAllChatAdministrators()
            });
        }
    }
}
