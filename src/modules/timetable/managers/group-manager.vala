namespace BarsuTimetable {
    
    public class GroupManager {
        private GroupLoader loader = new GroupLoader();
        
        public GroupManager() {
            loader.load_groups.begin();
        }
        
        public async bool sync() {
            return yield loader.sync_groups();
        }
        
        public string get_last_fetch() {
            return loader.last_fetch;
        }
        
        public string? parse_group(string group) {
            var group_index = loader.groups.index_of(group.replace(" ", "").replace("-", ""));
            
            if (group_index > -1) {
                return loader.groups.get(group_index);
            }
            return null;
        }
        
        public string get_random_group() {
            return loader.groups.get(Random.int_range(0, loader.groups.size));
        }
    }
}
