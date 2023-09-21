using BarsuTimetable;
using Telegram;
using Setup;
using Admin;
using Bus;

public TimetableModule timetable_module;
public AdminModule admin_module;
public SetupModule setup_module;
public BusModule bus_module;

public class ModuleLoader {
    
    public async void load_modules() {
        timetable_module = new TimetableModule();
        admin_module = new AdminModule();
        setup_module = new SetupModule();
        bus_module = new BusModule();
        
        Util.log(@"Loading modules...");
        yield timetable_module.load();
        yield admin_module.load();
        yield setup_module.load();
        yield bus_module.load();
        Util.log(@"Modules loaded!");
    }
}
