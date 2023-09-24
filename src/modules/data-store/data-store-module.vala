namespace DataStore {
    public DataManager data;
    
    public class DataStoreModule {
        
        public async void load() {
            data = new DataManager();
            
            yield data.load();
        }
    }
}
