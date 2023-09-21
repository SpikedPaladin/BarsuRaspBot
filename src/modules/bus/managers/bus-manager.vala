namespace Bus {
    
    public class BusManager {
        private BusLoader loader = new BusLoader();
        public bool loaded {
            get {
                return loader.buses.size > 0;
            }
        }
        
        public async void load() {
            loader.load_config.begin();
        }
        
        public BusInfo get_bus_info(int bus_number) {
            return loader.buses.get(bus_number - 1);
        }
    }
}
