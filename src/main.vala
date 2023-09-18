using BarsuTimetable;
using Admin;
using Bus;

public const int64 BOSS_ID = 841497640;

public Soup.Session session;
public BarsuRaspBot bot;

public TimetableModule timetable_module;
public AdminModule admin_module;
public BusModule bus_module;

void main() {
    Intl.setlocale(LocaleCategory.ALL, "");
    Xml.set_generic_error_func(null, () => {});
    
    // Session for loading from web
    session = new Soup.Session();
    
    // Initialize bot
    bot = new BarsuRaspBot();
    
    // Initialize modules
    timetable_module = new TimetableModule();
    admin_module = new AdminModule();
    bus_module = new BusModule();
    
    // Start bot
    bot.start();
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
