using DataStore;
using Telegram;

namespace Barsu {
    public TimetableManager timetable_manager;
    public BroadcastManager broadcast_manager;
    public ScheduleManager schedule_manager;
    public ImageManager image_manager;
    
    public class BarsuModule {
        
        public async void load() {
            timetable_manager = new TimetableManager();
            broadcast_manager = new BroadcastManager();
            schedule_manager = new ScheduleManager();
            image_manager = new ImageManager();
            
            add_handlers();
        }
        
        public void add_handlers() {
            var inline_timetable = new InlineTimetable();
            bot.add_handler(new InlineQueryHandler("", query => inline_timetable.send_no_group.begin(query), query => get_config(query.from.id).group == null));
            bot.add_handler(new InlineQueryHandler("", query => inline_timetable.send_timetable.begin(query)));
            bot.add_handler(new InlineQueryHandler(null, query => inline_timetable.send_group_timetable.begin(query)));
            
            bot.add_handler(new CommandHandler("apk", msg => apk_command.begin(msg)));
            bot.add_handler(new CommandHandler("day", msg => day_command.begin(msg)));
            bot.add_handler(new MessageHandler("▶️ Сегодня", msg => day_command.begin(msg)));
            bot.add_handler(new CommandHandler("tomorrow", msg => day_command.begin(msg)));
            bot.add_handler(new MessageHandler("⏭️ Завтра", msg => day_command.begin(msg)));
            bot.add_handler(new CommandHandler("rasp", msg => rasp_command.begin(msg)));
            bot.add_handler(new MessageHandler("🗓️ Эта неделя", msg => rasp_command.begin(msg)));
            bot.add_handler(new MessageHandler("🗓️ На неделю", msg => rasp_command.begin(msg)));
            bot.add_handler(new CommandHandler("raspnext", msg => rasp_command.begin(msg)));
            bot.add_handler(new MessageHandler("🗓️ След. неделя", msg => rasp_command.begin(msg)));
            bot.add_handler(new CommandHandler("next", msg => next_command.begin(msg)));
            bot.add_handler(new MessageHandler("⏩️ След. пара", msg => next_command.begin(msg)));
            bot.add_handler(new CommandHandler("bells", msg => bells_command.begin(msg)));
            bot.add_handler(new MessageHandler("🔔️ Звонки", msg => bells_command.begin(msg)));
            bot.add_handler(new CommandHandler("settings", msg => settings_command.begin(msg)));
            bot.add_handler(new MessageHandler("⚙️ Настройки", msg => settings_command.begin(msg)));
            bot.add_handler(new CommandHandler("help", msg => help_command.begin(msg)));
            
            var button_action = new ButtonActions();
            bot.add_handler(new CallbackQueryHandler("empty", query => button_action.empty.begin(query)));
            bot.add_handler(new CallbackQueryHandler("get_app", query => button_action.get_app.begin(query)));
            bot.add_handler(new CallbackQueryHandler("get_apk", query => button_action.get_apk.begin(query)));
            bot.add_handler(new CallbackQueryHandler("cancel", query => button_action.cancel.begin(query)));
            bot.add_handler(new CallbackQueryHandler("install", query => button_action.install.begin(query)));
            bot.add_handler(new CallbackQueryHandler("enable_sub", query => button_action.enable_subscription.begin(query)));
            bot.add_handler(new CallbackQueryHandler("disable_sub", query => button_action.disable_subscription.begin(query)));
            bot.add_handler(new CallbackQueryHandler("change_group", query => button_action.change_group.begin(query)));
            bot.add_handler(new CallbackQueryHandler(null, query => button_action.send_timetable.begin(query), query => query.data.has_prefix("timetable")));
            bot.add_handler(new CallbackQueryHandler(null, query => button_action.send_teacher.begin(query), query => query.data.has_prefix("teacher")));
            
            bot.add_handler(new CallbackQueryHandler(null, 
                query => {
                    var parts = query.data.split(":");
                    
                    if (parts[1] == "group")
                        send_timetable_keyboard.begin(parts[2], get_current_week().format("%F"), query.message.chat.id, query.message.message_id);
                    else
                        send_teacher_keyboard.begin(parts[2], get_current_week().format("%F"), query.message.chat.id, query.message.message_id);
                },
                query => query.data.has_prefix("search")
            ));
            
            bot.add_handler(new MessageHandler("",
                msg => {
                    if (msg.text.char_count() == 1 || msg.text.char_count() > 20)
                        return;
                    
                    var text = "🔍️ *Поиск*:\n\n";
                    text += @"Твой запрос: \"`$(msg.text)`\"";
                    
                    var keyboard = search_keyboard(msg.text);
                    
                    if (keyboard == null)
                        text += "\nПо этому запросу ничего не найдено";
                    else
                        text += "\nВот что я нашел по этому запросу:";
                    
                    bot.send.begin(new SendPhoto() {
                        chat_id = msg.chat.id,
                        reply_markup = keyboard,
                        photo = "https://i.ibb.co/3BJKb3b/search-brb.png",
                        caption = text
                    });
                },
                msg => get_config(msg.from.id).state == null
            ));
        }
    }
    
    public InlineKeyboardMarkup? search_keyboard(string query) {
        var keyboard = new InlineKeyboardMarkup();
        bool found = false;
        
        foreach (var faculty in data.get_faculties())
            foreach (var speciality in faculty.specialties)
                foreach (var group in speciality.groups)
                    if (group.down().has_prefix(query.down())) {
                        found = true;
                        if (keyboard.inline_keyboard.last()?.data?.length() == 2)
                            keyboard.new_row();
                        keyboard.add_button(new InlineKeyboardButton() { text = group, callback_data = @"search:group:$group" });
                    }
        
        foreach (var department in data.get_departments())
            foreach (var teacher in department.teachers)
                if (teacher.down().has_prefix(query.down())) {
                    found = true;
                    if (keyboard.inline_keyboard.length() > 0)
                        keyboard.new_row();
                    
                    keyboard.add_button(new InlineKeyboardButton() { text = @"$teacher - $(department.name)", callback_data = @"search:teacher:$teacher" });
                }
        
        if (found)
            return keyboard;
        
        return null;
    }
    
    public async void send_settings(ChatId chat_id, int64? user_id = null, int? message_id = null) {
        var config = user_id != null ? get_config(user_id) : get_chat_config(chat_id);
        
        if (config.post == null)
            return;
        
        if (message_id != null)
            yield bot.send(new EditMessageText() {
                chat_id = chat_id,
                message_id = message_id,
                parse_mode = ParseMode.MARKDOWN,
                text = settings_text(config),
                reply_markup = config.subscribed ? Keyboards.disable_sub_keyboard : Keyboards.enable_sub_keyboard
            });
        else
            yield bot.send(new SendMessage() {
                chat_id = chat_id,
                parse_mode = ParseMode.MARKDOWN,
                text = settings_text(config),
                reply_markup = config.subscribed ? Keyboards.disable_sub_keyboard : Keyboards.enable_sub_keyboard
            });
    }
    
    public async void send_teacher_keyboard(string name, string date, ChatId chat_id, int? message_id = null) {
        var timetable = yield timetable_manager.get_teacher(name, date);
        var keyboard = create_teacher_keyboard(timetable, name, date, null, true);
        
        if (message_id != null)
            yield bot.send(new EditMessageMedia() {
                chat_id = chat_id,
                message_id = message_id,
                media = new InputMediaPhoto() {
                    media = "https://i.ibb.co/8bTMMr9/timetable-brb.png",
                    caption = keyboard == null ? "😿️ Расписания пока что нет :(" :
                    @"🧑‍🏫️ Преподаватель: *$(name)*\n\n" +
                    "🗓️ Выберите день недели:"
                },
                reply_markup = keyboard
            });
        else
            yield bot.send(new SendPhoto() {
                chat_id = chat_id,
                photo = "https://i.ibb.co/8bTMMr9/timetable-brb.png",
                caption = keyboard == null ? "😿️ Расписания пока что нет :(" :
                @"🧑‍🏫️ Преподаватель: *$(name)*\n\n" +
                "🗓️ Выберите день недели:",
                reply_markup = keyboard
            });
    }
    
    public async void send_timetable_keyboard(string group, string date, ChatId chat_id, int? message_id = null) {
        var timetable = yield timetable_manager.get_timetable(group, date);
        var keyboard = create_timetable_keyboard(timetable, group, date, null, true);
        
        if (message_id != null)
            yield bot.send(new EditMessageMedia() {
                chat_id = chat_id,
                message_id = message_id,
                media = new InputMediaPhoto() {
                    media = "https://i.ibb.co/8bTMMr9/timetable-brb.png",
                    caption = keyboard == null ? "😿️ Расписания пока что нет :(" :
                    @"👥️ Группа: *$(group)*\n\n" +
                    "🗓️ Выбери день недели:"
                },
                reply_markup = keyboard
            });
        else
            yield bot.send(new SendPhoto() {
                chat_id = chat_id,
                photo = "https://i.ibb.co/8bTMMr9/timetable-brb.png",
                caption = keyboard == null ? "😿️ Расписания пока что нет :(" :
                @"👥️ Группа: *$(group)*\n\n" +
                "🗓️ Выбери день недели:",
                reply_markup = keyboard
            });
    }
    
    public async void send_teacher_date(string day, string name, string date, CallbackQuery query) {
        var timetable = yield timetable_manager.get_teacher(name, date);
        var keyboard = create_teacher_keyboard(timetable, name, date, day);
        
        if (query.message is Message && ((Message) query.message).photo != null) {
            yield bot.send(new DeleteMessage() {
                chat_id = query.message.chat.id,
                message_id = query.message.message_id,
            });
            
            yield bot.send(new SendMessage() {
                chat_id = query.message.chat.id,
                reply_markup = keyboard,
                text = @"🧑‍🏫️ Преподаватель: *$(name)*\n" + timetable.to_string(day)
            });
            
            return;
        }
        
        yield bot.send(new EditMessageText() {
            chat_id = query.message.chat.id,
            message_id = query.message.message_id,
            parse_mode = ParseMode.MARKDOWN,
            reply_markup = keyboard,
            text = @"🧑‍🏫️ Преподаватель: *$(name)*\n" + timetable.to_string(day)
        });
    }
    
    public async void send_timetable_date(string day, string group, string date, CallbackQuery query) {
        var timetable = yield timetable_manager.get_timetable(group, date);
        var keyboard = create_timetable_keyboard(timetable, group, date, day);
        
        if (query.message is Message && ((Message) query.message).photo != null) {
            yield bot.send(new DeleteMessage() {
                chat_id = query.message.chat.id,
                message_id = query.message.message_id,
            });
            
            yield bot.send(new SendMessage() {
                chat_id = query.message.chat.id,
                reply_markup = keyboard,
                text = @"👥️ Группа: *$(group)*\n" + timetable.to_string(day)
            });
            
            return;
        }
        
        yield bot.send(new EditMessageText() {
            chat_id = query.message.chat.id,
            message_id = query.message.message_id,
            parse_mode = ParseMode.MARKDOWN,
            reply_markup = keyboard,
            text = @"👥️ Группа: *$(group)*\n" + timetable.to_string(day)
        });
    }
    
    public async void send_next_teacher(string name, ChatId chat_id, bool send_empty = true) {
        var timetable = yield timetable_manager.get_teacher(name, get_current_week().format("%F"));
        var time = new DateTime.now();
        var day = timetable?.get_day_schedule(time);
        
        if (day != null) {
            var lesson = day.get_next_lesson(time);
            
            if (lesson != null)
                yield bot.send(new SendMessage() {
                    chat_id = chat_id,
                    parse_mode = ParseMode.MARKDOWN,
                    text = "⏭️ Следующее занятие:\n\n" + lesson.to_string()
                });
            else if (send_empty)
                yield bot.send(new SendMessage() {
                    chat_id = chat_id,
                    parse_mode = ParseMode.MARKDOWN,
                    text = "🎉️ На сегодня занятий больше нет!"
                });
        } else if (send_empty) {
            yield bot.send(new SendMessage() {
                chat_id = chat_id,
                text = "🎉️ Сегодня занятий нет!"
            });
        }
    }
    
    public async void send_next_lesson(string group, ChatId chat_id, bool send_empty = true) {
        var timetable = yield timetable_manager.get_timetable(group, get_current_week().format("%F"));
        var time = new DateTime.now();
        var day = timetable?.get_day_schedule(time);
        
        if (day != null) {
            var lesson = day.get_next_lesson(time);
            
            if (lesson != null)
                yield bot.send(new SendMessage() {
                    chat_id = chat_id,
                    parse_mode = ParseMode.MARKDOWN,
                    text = "⏭️ Следующая пара:\n\n" + lesson.to_string()
                });
            else if (send_empty)
                yield bot.send(new SendMessage() {
                    chat_id = chat_id,
                    parse_mode = ParseMode.MARKDOWN,
                    text = "🎉️ На сегодня пар больше нет!"
                });
        } else if (send_empty) {
            yield bot.send(new SendMessage() {
                chat_id = chat_id,
                text = "🎉️ Сегодня пар нет!"
            });
        }
    }
    
    public InlineKeyboardMarkup? create_teacher_keyboard(Teacher.Timetable? timetable, string group, string date, string? skip_button = null, bool week = false) {
        if (timetable == null)
            return null;
        
        var keyboard = new InlineKeyboardMarkup();
        
        foreach (var day in timetable.days) {
            keyboard.add_button(new InlineKeyboardButton() {
                text = skip_button == day.day ? @"($(day.day))" : day.day,
                callback_data = skip_button == day.day ? "empty" : @"teacher:$(day.day):$group:$date"
            });
        }
        
        if (week)
            keyboard.new_row().add_button(new InlineKeyboardButton() { text = "🖼️ Вся неделя", callback_data = @"teacher:$group:$date" });
        
        return keyboard;
    }
    
    public InlineKeyboardMarkup? create_timetable_keyboard(Student.Timetable? timetable, string group, string date, string? skip_button = null, bool week = false) {
        if (timetable == null)
            return null;
        
        var keyboard = new InlineKeyboardMarkup();
        
        foreach (var day in timetable.days) {
            keyboard.add_button(new InlineKeyboardButton() {
                text = skip_button == day.day_of_week ? @"($(day.day_of_week))" : day.day_of_week,
                callback_data = skip_button == day.day_of_week ? "empty" : @"timetable:$(day.day_of_week):$group:$date"
            });
        }
        
        if (week)
            keyboard.new_row().add_button(new InlineKeyboardButton() { text = "🖼️ Вся неделя", callback_data = @"timetable:$group:$date" });
        
        return keyboard;
    }
    
    public string settings_text(Config config) {
        var str = "Настройки бота:\n\n";
        str += @"🔔️ Уведомления: *$(config.subscribed ? "ВКЛ" : "ОТКЛ")*\n";
        
        if (config.post == UserPost.TEACHER) {
            str += @"🧑‍🏫️ Преподаватель: *$(config.name)*";
        } else
            str += @"👥️ Группа: *$(config.group)*";
        
        return str;
    }
}
