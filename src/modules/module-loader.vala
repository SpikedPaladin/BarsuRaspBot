using Barsu;
using DataStore;
using Telegram;
using Setup;
using Admin;
using Bus;

public DataStoreModule data_store_module;
public BarsuModule barsu_module;
public AdminModule admin_module;
public SetupModule setup_module;
public BusModule bus_module;

public class ModuleLoader {
    
    public async void load_modules() {
        data_store_module = new DataStoreModule();
        barsu_module = new BarsuModule();
        admin_module = new AdminModule();
        setup_module = new SetupModule();
        bus_module = new BusModule();
        
        Util.log(@"Loading modules...");
        yield bus_module.load();
        yield data_store_module.load();
        yield barsu_module.load();
        yield admin_module.load();
        yield setup_module.load();
        Util.log(@"Modules loaded!");
    }
}
