using Barsu;
using Setup;
using Admin;
using Bus;

public const int64 BOSS_ID = 841497640;
public const int64 SENSE_OF_LIFE = 6608750361;

public ModuleLoader module_loader;
public Soup.Session session;
public BarsuRaspBot bot;

void main() {
    Intl.setlocale(LocaleCategory.ALL, "");
    Xml.set_generic_error_func(null, () => {});
    Keyboards.load();
    
    Telegram.DEFAULT_PARSE_MODE = Telegram.ParseMode.MARKDOWN;
    
    // Session for loading from web
    session = new Soup.Session();
    
    // Initialize bot
    bot = new BarsuRaspBot();
    bot.token = Environment.get_variable("TOKEN") ?? "6197661615:AAHuoz7Z4FPwvAi3iaydDwuzfqUAryaWefo";
    bot.config.create_main_loop = false;
    
    // Initialize modules
    module_loader = new ModuleLoader();
    module_loader.load_modules.begin(() => {
        // Start bot
        bot.start();
    });
    
    new MainLoop().run();
}

public DataStore.Config get_config(int64 id) {
    return DataStore.data.get_config(id);
}

public DataStore.Config? get_chat_config(Telegram.ChatId id) {
    return DataStore.data.get_chat_config(id);
}

private void send_alert(string id, string text) {
    bot.send.begin(new Telegram.AnswerCallbackQuery() {
        callback_query_id = id,
        show_alert = true,
        text = text
    });
}

public DateTime get_current_week() {
    var time = new DateTime.now();
    var current_week = time.add_days(-time.get_day_of_week() + 1);
    
    if (time.get_day_of_week() == 6 && time.get_hour() > 20)
        return current_week.add_weeks(1);
    else if (time.get_day_of_week() > 6)
        return current_week.add_weeks(1);
    
    return current_week;
}

public DateTime get_next_week() {
    return get_current_week().add_weeks(1);
}
