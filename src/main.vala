using BarsuTimetable;
using Setup;
using Admin;
using Bus;

public const int64 BOSS_ID = 841497640;

public ModuleLoader module_loader;
public Soup.Session session;
public BarsuRaspBot bot;

void main() {
    Intl.setlocale(LocaleCategory.ALL, "");
    Xml.set_generic_error_func(null, () => {});
    Keyboards.load();
    
    // Session for loading from web
    session = new Soup.Session();
    
    // Initialize bot
    bot = new BarsuRaspBot();
    bot.token = Environment.get_variable("TOKEN") ?? "6197661615:AAHuoz7Z4FPwvAi3iaydDwuzfqUAryaWefo";
    bot.config.create_main_loop = false;
    bot.session.timeout = 15;
    bot.config.timeout = 10;
    
    // Initialize modules
    module_loader = new ModuleLoader();
    module_loader.load_modules.begin(() => {
        // Start bot
        bot.start();
    });
    
    new MainLoop().run();
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
