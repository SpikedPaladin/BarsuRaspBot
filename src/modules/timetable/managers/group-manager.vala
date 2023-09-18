namespace BarsuTimetable {
    
    public class GroupManager {
        private GroupLoader loader = new GroupLoader();
        
        public GroupManager() {
            loader.load_faculties.begin();
        }
        
        public async bool sync() {
            return yield loader.sync_faculties();
        }
        
        public string get_last_fetch() {
            return loader.last_fetch;
        }
        
        public string? parse_group(string query) {
            foreach (var faculty in loader.faculties)
                foreach (var speciality in faculty.specialties)
                    foreach (var group in speciality.groups)
                        if (group.down() == query.down().replace(" ", "").replace("-", ""))
                            return group;
            
            return null;
        }
        
        public string get_random_group() {
            var faculty = loader.faculties.get(Random.int_range(0, loader.faculties.size));
            var speciality = faculty.specialties[Random.int_range(0, faculty.specialties.length)];
            
            return speciality.groups[Random.int_range(0, speciality.groups.length)];
        }
    }
}
