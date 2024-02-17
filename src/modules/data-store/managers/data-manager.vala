using Telegram;
using Gee;

namespace DataStore {
    
    public class DataManager {
        private bool save_scheduled;
        
        private DataLoader loader = new DataLoader();
        private Student.FacultyLoader faculty_loader = new Student.FacultyLoader();
        private Teacher.DepartmentLoader department_loader = new Teacher.DepartmentLoader();
        
        public string? apk_version { get { return loader.apk_version; } }
        public string? apk_file_id { get { return loader.apk_file_id; } }
        
        public void schedule_save() {
            if (save_scheduled)
                return;
            
            save_scheduled = true;
            
            GLib.Timeout.add_seconds(60, () => {
                save();
                return false;
            });
        }
        
        public void save() {
            loader.save_configs.begin();
            save_scheduled = false;
        }
        
        public async void load() {
            yield faculty_loader.load_faculties();
            yield department_loader.load_departments();
            yield loader.load_configs();
        }
        
        public void set_apk(string file_id, string version) {
            loader.apk_file_id = file_id;
            loader.apk_version = version;
            loader.save_configs.begin();
        }
        
        public ArrayList<Teacher.Department> get_departments() {
            return department_loader.departments;
        }
        
        public ArrayList<Student.Faculty> get_faculties() {
            return faculty_loader.faculties;
        }
        
        public async void sync() {
            yield faculty_loader.load_faculties(true);
            yield department_loader.load_departments(true);
        }
        
        public string? parse_group(string? query) {
            if (query == null)
                return null;
            
            foreach (var faculty in faculty_loader.faculties)
                foreach (var speciality in faculty.specialties)
                    foreach (var group in speciality.groups)
                        if (group.down() == query.down().replace(" ", "").replace("-", ""))
                            return group;
            
            return null;
        }
        
        public Teacher.Department? parse_department(string query) {
            return department_loader.departments.first_match((department) => {
                return department.name == query;
            });
        }
        
        public string? parse_name(string query) {
            foreach (var department in department_loader.departments)
                foreach (var name in department.teachers)
                    if (name.down() == query.down())
                        return name;
            
            return null;
        }
        
        public Student.Faculty? parse_faculty(string query) {
            return faculty_loader.faculties.first_match((faculty) => {
                return faculty.name == query;
            });
        }
        
        public Student.Speciality? parse_speciality(string query) {
            foreach (var faculty in faculty_loader.faculties)
                foreach (var speciality in faculty.specialties)
                    if (speciality.name == query)
                        return speciality;
            
            return null;
        }
        
        public string get_random_group() {
            var faculty = faculty_loader.faculties.get(Random.int_range(0, faculty_loader.faculties.size));
            var speciality = faculty.specialties[Random.int_range(0, faculty.specialties.length)];
            
            return speciality.groups[Random.int_range(0, speciality.groups.length)];
        }
        
        public ConcurrentList<Config> get_users() {
            return loader.users;
        }
        
        public ConcurrentList<Config> get_chats() {
            return loader.chats;
        }
        
        public void remove_config(int64 id, bool is_chat = false) {
            var array = is_chat ? loader.chats : loader.users;
            
            var config = array.first_match((config) => {
                return config.id == id;
            });
            
            array.remove(config);
            loader.save_configs.begin();
        }
        
        public Config? get_config(int64 user_id, bool create_config = true) {
            var found_config = loader.users.first_match((config) => {
                return config.id == user_id;
            });
            
            if (found_config != null) {
                return found_config;
            }
            
            if (!create_config)
                return null;
            
            var config = new Config.empty(user_id);
            loader.users.add(config);
            save();
            
            return config;
        }
        
        public Config? get_chat_config(ChatId chat_id) {
            var found_config = loader.chats.first_match((config) => {
                return config.id == chat_id.id;
            });
            
            if (found_config != null) {
                return found_config;
            }
            
            return null;
        }
    }
}
