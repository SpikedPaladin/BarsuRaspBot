namespace BarsuTimetable {
    
    public class GroupManager {
        private GroupLoader loader = new GroupLoader();
        
        public GroupManager() {
            loader.load_faculties.begin();
            loader.load_departments.begin();
        }
        
        public Gee.ArrayList<Department> get_departments() {
            return loader.departments;
        }
        
        public Gee.ArrayList<Faculty> get_faculties() {
            return loader.faculties;
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
        
        public Department? parse_department(string query) {
            return loader.departments.first_match((department) => {
                return department.name == query;
            });
        }
        
        public string? parse_name(string query) {
            foreach (var department in loader.departments)
                foreach (var name in department.teachers)
                    if (name.down() == query.down())
                        return name;
            
            return null;
        }
        
        public Faculty? parse_faculty(string query) {
            return loader.faculties.first_match((faculty) => {
                return faculty.name == query;
            });
        }
        
        public Speciality? parse_speciality(string query) {
            foreach (var faculty in loader.faculties)
                foreach (var speciality in faculty.specialties)
                    if (speciality.name == query)
                        return speciality;
            
            return null;
        }
        
        public string get_random_group() {
            var faculty = loader.faculties.get(Random.int_range(0, loader.faculties.size));
            var speciality = faculty.specialties[Random.int_range(0, faculty.specialties.length)];
            
            return speciality.groups[Random.int_range(0, speciality.groups.length)];
        }
    }
}
