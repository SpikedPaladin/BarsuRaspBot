using Barsu;
using DataStore;
using Telegram;
using Gee;

namespace Admin {
    
    public class AdminCommands {
        
        public async void update_apk(Message msg) {
            if (msg.reply_to_message != null) {
                var file_id = msg.reply_to_message.document.file_id;
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = @"Бля новый айди: `$(file_id)`"
                });
                
                data.set_apk_file_id(file_id);
            }
        }
        
        public async void bypass(Message msg) {
            if (msg.get_command_arguments() != null) {
                yield send_timetable_keyboard(msg.get_command_arguments(), get_current_week().format("%F"), msg.chat.id);
            } else {
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = "Мы ебланы"
                });
            }
        }
        
        public async void find(Message msg) {
            int64 id;
            
            if (msg.reply_to_message != null && msg.reply_to_message.forward_from != null) {
                id = msg.reply_to_message.forward_from.id;
            } else if (msg.get_command_arguments() != null) {
                id = int64.parse(msg.get_command_arguments());
            } else {
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = "Бля буду, ты вообще ебобо. Нужен айди в аргумент или реплай на сообщения додика для взлома его жопы."
                });
                return;
            }
            var chat = yield bot.get_chat(new ChatId(id));
            
            if (chat != null) {
                string user_group = "Во еблан, без группы";
                foreach (var config in data.get_users()) {
                    if (config.id == id)
                        if (config.group != null || config.name != null)
                            user_group = config.group ?? config.name;
                }
                
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    parse_mode = ParseMode.HTML,
                    text = @"Попался гадёныш!\n$(yield mention(id))\nГруппа/Препод: $user_group"
                });
            } else
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
                var text = @"Попались ебланчики из $(group):\n";
                foreach (var config in data.get_users()) {
                    if (config.group != group)
                        continue;
                    
                    text += yield mention(config.id);
                    text += "\n";
                    count++;
                }
                
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    parse_mode = ParseMode.HTML,
                    text = text + @"Всего пиздюков: $count"
                });
            } else
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = "Блять ну ты еблан пиздец"
                });
        }
        
        public async void stat(Message msg) {
            if (msg.get_command_arguments() == "teacher") {
                string text = "Преподы:\n";
                foreach (var config in data.get_users()) {
                    if (config.post != UserPost.TEACHER)
                        continue;
                    
                    text += @"$(config.name) ";
                    text += yield mention(config.id);
                    text += "\n";
                }
                
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    parse_mode = ParseMode.HTML,
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
        
        public async void backup(Message msg) {
            var file = File.new_for_path(@".cache/TelegramBots/BarsuRaspBot/$(msg.get_command_arguments()).json");
            
            if (file.query_exists()) {
                yield bot.send(new SendChatAction() {
                    chat_id = msg.chat.id,
                    action = ChatAction.UPLOAD_DOCUMENT
                });
                yield bot.send(new SendDocument() {
                    chat_id = msg.chat.id,
                    document = @"file://$(file.get_path())"
                });
            } else
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = "Ты/я балбес!"
                });
        }
        
        public async void broadcast(Message msg) {
            if (msg.reply_to_message == null) {
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = "⚠️ Додик ебаный... Нужно отправлять ответом на сообщение"
                });
                
                return;
            }
            
            ReplyMarkup? reply_markup = null;
            if (msg.get_command_arguments() == "apk")
                reply_markup = Keyboards.apk_keyboard;
            
            yield broadcast_manager.send_broadcast(msg.chat.id, msg.reply_to_message.message_id, reply_markup);
        }
        
        public async void sync(Message msg) {
            var response = yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                text = "*Группы синхронизируются...*"
            });
            var message_id = new Message(response.result.get_object()).message_id;
            
            yield data.sync();
            yield bot.send(new EditMessageText() {
                chat_id = msg.chat.id,
                message_id = message_id,
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
            var apk = new BotCommand() {
                command = "apk",
                description = "Приложение для расписания"
            };
            
            yield bot.send(new SetMyCommands() {
                commands = { day, tomorrow, rasp, raspnext, next, bells, bus, help, apk },
                scope = new BotCommandScopeDefault()
            });
            yield bot.send(new SetMyCommands() {
                commands = { day, tomorrow, rasp, raspnext, next, bells, bus, settings, help, apk },
                scope = new BotCommandScopeAllPrivateChats()
            });
            yield bot.send(new SetMyCommands() {
                commands = { day, tomorrow, rasp, raspnext, next, bells, bus, settings, help, apk },
                scope = new BotCommandScopeAllChatAdministrators()
            });
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
}
