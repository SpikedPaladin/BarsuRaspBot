using Telegram;

namespace BarsuTimetable {
    public TimetableManager timetable_manager;
    public BroadcastManager broadcast_manager;
    public ScheduleManager schedule_manager;
    public ConfigManager config_manager;
    public GroupManager group_manager;
    public ImageManager image_manager;
    
    public class TimetableModule {
        
        public TimetableModule() {
            timetable_manager = new TimetableManager();
            broadcast_manager = new BroadcastManager();
            schedule_manager = new ScheduleManager();
            config_manager = new ConfigManager();
            group_manager = new GroupManager();
            image_manager = new ImageManager();
            
            add_handlers();
        }
        
        public void add_handlers() {
            var inline_timetable = new InlineTimetable();
            bot.add_handler(new InlineQueryHandler("", query => inline_timetable.send_no_group.begin(query), query => config_manager.find_user_group(query.from.id) == null));
            bot.add_handler(new InlineQueryHandler("", query => inline_timetable.send_timetable.begin(query)));
            bot.add_handler(new InlineQueryHandler(null, query => inline_timetable.send_group_timetable.begin(query)));
            
            var chat_commands = new ChatCommands();
            bot.add_handler(new CommandHandler("start", msg => chat_commands.start_command.begin(msg), msg => msg.chat.type == Chat.Type.PRIVATE));
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
            
            var group_message = new GroupMessage();
            bot.add_handler(new MessageHandler(null, msg => group_message.private_message.begin(msg), msg => msg.chat.type == Chat.Type.PRIVATE));
            bot.add_handler(new MessageHandler(null, msg => group_message.chat_message.begin(msg), msg => bot.users_map.has_key(@"$(msg.from.id)") && bot.users_map.get(@"$(msg.from.id)") == "owner"));
            
            var button_action = new ButtonActions();
            bot.add_handler(new CallbackQueryHandler("cancel", query => button_action.cancel.begin(query)));
            bot.add_handler(new CallbackQueryHandler("enable_sub", query => button_action.enable_subscription.begin(query)));
            bot.add_handler(new CallbackQueryHandler("disable_sub", query => button_action.disable_subscription.begin(query)));
            bot.add_handler(new CallbackQueryHandler("change_group", query => button_action.change_group.begin(query)));
            bot.add_handler(new CallbackQueryHandler("select_group", query => button_action.select_group.begin(query)));
            bot.add_handler(new CallbackQueryHandler(null, query => button_action.send_timetable.begin(query), query => query.data.has_prefix("timetable")));
        }
    }
    
    
    public async void send_settings(ChatId chat_id, int64? user_id = null, int? message_id = null) {
        var config = user_id != null ? config_manager.find_user_config(user_id) : config_manager.find_chat_config(chat_id);
        
        if (message_id != null)
            yield bot.send(new EditMessageText() {
                chat_id = chat_id,
                message_id = message_id,
                parse_mode = ParseMode.MARKDOWN,
                text = settings_text(config),
                reply_markup = config.subscribed ? bot.disable_sub_keyboard : bot.enable_sub_keyboard
            });
        else
            yield bot.send(new SendMessage() {
                chat_id = chat_id,
                parse_mode = ParseMode.MARKDOWN,
                text = settings_text(config),
                reply_markup = config.subscribed ? bot.disable_sub_keyboard : bot.enable_sub_keyboard
            });
    }
    
    public async void send_start_finished(string group, ChatId chat_id) {
        yield bot.send(new SendMessage() {
            chat_id = chat_id,
            parse_mode = ParseMode.MARKDOWN,
            text = @"👥️ Ты выбрал группу: *$(group)*\n\n" +
                   "Расписание на сегодня - /day\n" +
                   "Расписание на завтра - /tomorrow\n" +
                   "Выбрать день недели - /rasp\n" +
                   "Выбрать день след. недели - /raspnext\n" +
                   "Расписание на эту неделю (Beta) - /week\n" +
                   "Расписание на след. неделю (Beta) - /weeknext\n" +
                   "Расписание звонков - /bells\n" +
                   "Показать помощь - /help\n\n" +
                   "⚙️ Изменить группу или включить уведомления - /settings\n\n" +
                   "Все команды кликабельны, а также доступны по кнопке 'Меню'\n\n" +
                   "Также бот поддерживает инлайн режим, в любом чате напиши: \n" +
                   "`@BarsuRaspBot `(с пробелом). " +
                   "Так можно быстро отправить расписание своему другу."
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
    
    public async void send_timetable_date(string day, string group, string date, CallbackQuery query) {
        var timetable = yield timetable_manager.get_timetable(group, date);
        
        yield bot.send(new EditMessageText() {
            chat_id = query.message.chat.id,
            message_id = query.message.message_id,
            parse_mode = ParseMode.MARKDOWN,
            text = @"👥️ Группа: *$(group)*\n" + timetable.to_string(day)
        });
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
    
    public InlineKeyboardMarkup? create_timetable_keyboard(Timetable? timetable, string group, string date) {
        if (timetable == null)
            return null;
        
        var keyboard = new InlineKeyboardMarkup();
        
        foreach (var day in timetable.days) {
            keyboard.add_button(new InlineKeyboardButton() {
                text = day.day_of_week,
                callback_data = @"timetable:$(day.day_of_week):$(group):$(date)"
            });
        }
        
        return keyboard;
    }
    
    public string settings_text(Config config) {
        return
            "Настройки бота:\n\n" +
            @"🔔️ Уведомления: *$(config.subscribed ? "ВКЛ" : "ОТКЛ")*\n" +
            @"👥️ Группа: *$(config.group)*";
    }
}
