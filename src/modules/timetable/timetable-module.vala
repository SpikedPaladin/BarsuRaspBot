using DataStore;
using Telegram;

namespace BarsuTimetable {
    public TimetableManager timetable_manager;
    public BroadcastManager broadcast_manager;
    public ScheduleManager schedule_manager;
    public GroupManager group_manager;
    public ImageManager image_manager;
    
    public class TimetableModule {
        
        public async void load() {
            timetable_manager = new TimetableManager();
            broadcast_manager = new BroadcastManager();
            schedule_manager = new ScheduleManager();
            group_manager = new GroupManager();
            image_manager = new ImageManager();
            
            yield group_manager.load();
            yield image_manager.load();
            
            add_handlers();
        }
        
        public void add_handlers() {
            var inline_timetable = new InlineTimetable();
            bot.add_handler(new InlineQueryHandler("", query => inline_timetable.send_no_group.begin(query), query => data.get_group(query.from.id) == null));
            bot.add_handler(new InlineQueryHandler("", query => inline_timetable.send_timetable.begin(query)));
            bot.add_handler(new InlineQueryHandler(null, query => inline_timetable.send_group_timetable.begin(query)));
            
            var chat_commands = new ChatCommands();
            bot.add_handler(new CommandHandler("day", msg => chat_commands.day_command.begin(msg)));
            bot.add_handler(new CommandHandler("tomorrow", msg => chat_commands.day_command.begin(msg)));
            bot.add_handler(new CommandHandler("rasp", msg => chat_commands.rasp_command.begin(msg)));
            bot.add_handler(new CommandHandler("raspnext", msg => chat_commands.rasp_command.begin(msg)));
            bot.add_handler(new CommandHandler("next", msg => chat_commands.next_command.begin(msg)));
            bot.add_handler(new CommandHandler("week", msg => chat_commands.week_command.begin(msg)));
            bot.add_handler(new CommandHandler("weeknext", msg => chat_commands.week_command.begin(msg)));
            bot.add_handler(new CommandHandler("bells", msg => chat_commands.bells_command.begin(msg)));
            bot.add_handler(new CommandHandler("settings", msg => chat_commands.settings_command.begin(msg)));
            bot.add_handler(new CommandHandler("help", msg => chat_commands.help_command.begin(msg)));
            
            var button_action = new ButtonActions();
            bot.add_handler(new CallbackQueryHandler("empty", query => button_action.empty.begin(query)));
            bot.add_handler(new CallbackQueryHandler("cancel", query => button_action.cancel.begin(query)));
            bot.add_handler(new CallbackQueryHandler("install", query => button_action.install.begin(query)));
            bot.add_handler(new CallbackQueryHandler("enable_sub", query => button_action.enable_subscription.begin(query)));
            bot.add_handler(new CallbackQueryHandler("disable_sub", query => button_action.disable_subscription.begin(query)));
            bot.add_handler(new CallbackQueryHandler("change_group", query => button_action.change_group.begin(query)));
            bot.add_handler(new CallbackQueryHandler(null, query => button_action.send_timetable.begin(query), query => query.data.has_prefix("timetable")));
            bot.add_handler(new CallbackQueryHandler(null, query => button_action.send_teacher.begin(query), query => query.data.has_prefix("teacher")));
        }
    }
    
    public async void send_settings(ChatId chat_id, int64? user_id = null, int? message_id = null) {
        var config = user_id != null ? data.get_config(user_id) : data.get_chat_config(chat_id);
        
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
    
    public async void send_teacher_keyboard(string name, string date, ChatId chat_id) {
        var timetable = yield timetable_manager.get_teacher(name, date);
        var keyboard = create_teacher_keyboard(timetable, name, date);
        
        yield bot.send(new SendMessage() {
            chat_id = chat_id,
            parse_mode = ParseMode.MARKDOWN,
            text = keyboard == null ? "😿️ Расписания пока что нет :(" :
            @"🧑‍🏫️ Преподаватель: *$(name)*\n\n" +
            "🗓️ Выберите день недели:",
            reply_markup = keyboard
        });
    }
    
    public async void send_timetable_keyboard(string group, string date, ChatId chat_id) {
        var timetable = yield timetable_manager.get_timetable(group, date);
        var keyboard = create_timetable_keyboard(timetable, group, date);
        
        yield bot.send(new SendMessage() {
            chat_id = chat_id,
            parse_mode = ParseMode.MARKDOWN,
            text = keyboard == null ? "😿️ Расписания пока что нет :(" :
            @"👥️ Группа: *$(group)*\n\n" +
            "🗓️ Выбери день недели:",
            reply_markup = keyboard
        });
    }
    
    public async void send_teacher_date(string day, string name, string date, CallbackQuery query) {
        var timetable = yield timetable_manager.get_teacher(name, date);
        var keyboard = create_teacher_keyboard(timetable, name, date, day);
        
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
    
    public InlineKeyboardMarkup? create_teacher_keyboard(TeacherTimetable? timetable, string group, string date, string? skip_button = null) {
        if (timetable == null)
            return null;
        
        var keyboard = new InlineKeyboardMarkup();
        
        foreach (var day in timetable.days) {
            keyboard.add_button(new InlineKeyboardButton() {
                text = skip_button == day.day ? @"($(day.day))" : day.day,
                callback_data = skip_button == day.day ? "empty" : @"teacher:$(day.day):$(group):$(date)"
            });
        }
        
        return keyboard;
    }
    
    public InlineKeyboardMarkup? create_timetable_keyboard(Timetable? timetable, string group, string date, string? skip_button = null) {
        if (timetable == null)
            return null;
        
        var keyboard = new InlineKeyboardMarkup();
        
        foreach (var day in timetable.days) {
            keyboard.add_button(new InlineKeyboardButton() {
                text = skip_button == day.day_of_week ? @"($(day.day_of_week))" : day.day_of_week,
                callback_data = skip_button == day.day_of_week ? "empty" : @"timetable:$(day.day_of_week):$(group):$(date)"
            });
        }
        
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
