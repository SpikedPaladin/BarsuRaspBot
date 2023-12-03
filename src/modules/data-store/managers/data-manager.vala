using Telegram;
using Gee;

namespace DataStore {
    
    public class DataManager {
        private DataLoader loader = new DataLoader();
        private Student.FacultyLoader faculty_loader = new Student.FacultyLoader();
        private Teacher.DepartmentLoader department_loader = new Teacher.DepartmentLoader();
        
        public async void load() {
            yield faculty_loader.load_faculties();
            yield department_loader.load_departments();
            yield loader.load_configs();
        }
        
        public string? get_apk_file_id() {
            return loader.apk_file_id;
        }
        
        public void set_apk_file_id(string file_id) {
            loader.apk_file_id = file_id;
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
        
        public void create_config(int64 user_id) {
            loader.users.add(new Config() { id = user_id });
            loader.save_configs.begin();
        }
        
        public void remove_config(int64 id, bool is_chat = false) {
            var array = is_chat ? loader.chats : loader.users;
            
            var config = array.first_match((config) => {
                return config.id == id;
            });
            
            array.remove(config);
            loader.save_configs.begin();
        }
        
        public UserState? get_state(int64 user_id) {
            var found_config = loader.users.first_match((config) => {
                return config.id == user_id;
            });
            
            if (found_config != null) {
                return found_config.state;
            }
            
            return null;
        }
        
        public void set_state(int64 user_id, UserState? state) {
            var found_config = loader.users.first_match((config) => {
                return config.id == user_id;
            });
            
            if (found_config != null)
                found_config.state = state;
            else
                Util.log(@"(set_state) Not found user config ($user_id)", Util.LogLevel.WARNING);
            
            loader.save_configs.begin();
        }
        
        public UserPost? get_post(int64 user_id) {
            var found_config = loader.users.first_match((config) => {
                return config.id == user_id;
            });
            
            if (found_config != null) {
                return found_config.post;
            }
            
            return null;
        }
        
        public void set_post(int64 user_id, UserPost post) {
            var found_config = loader.users.first_match((config) => {
                return config.id == user_id;
            });
            
            if (found_config != null)
                found_config.post = post;
            else
                Util.log(@"(set_post) Not found user config ($user_id)", Util.LogLevel.WARNING);
            
            loader.save_configs.begin();
        }
        
        public Config? get_config(int64 user_id) {
            var found_config = loader.users.first_match((config) => {
                return config.id == user_id;
            });
            
            if (found_config != null) {
                return found_config;
            }
            
            return null;
        }
        
        public string? get_group(int64 user_id) {
            var found_config = loader.users.first_match((config) => {
                return config.id == user_id;
            });
            
            if (found_config != null) {
                return found_config.group;
            }
            
            return null;
        }
        
        public void set_group(int64 user_id, string group) {
            var found_config = loader.users.first_match((config) => {
                return config.id == user_id;
            });
            
            if (found_config != null)
                found_config.group = group;
            else
                Util.log(@"(set_group) Not found user config ($user_id)", Util.LogLevel.WARNING);
            
            loader.save_configs.begin();
        }
        
        public Config set_subscription(int64 user_id, bool enabled) {
            var found_config = loader.users.first_match((config) => {
                return config.id == user_id;
            });
            
            found_config.subscribed = enabled;
            
            loader.save_configs.begin();
            
            return found_config;
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
        
        public string? get_chat_group(ChatId chat_id) {
            var found_config = loader.chats.first_match((config) => {
                return config.id == chat_id.id;
            });
            
            if (found_config != null) {
                return found_config.group;
            }
            
            return null;
        }
        
        public void set_chat_group(ChatId chat_id, string group) {
            var found_config = loader.chats.first_match((config) => {
                return config.id == chat_id.id;
            });
            
            if (found_config != null) {
                found_config.group = group;
            } else {
                var config = new Config() {
                    id = chat_id.id,
                    group = group
                };
                
                loader.chats.add(config);
            }
            
            loader.save_configs.begin();
        }
        
        public Config set_chat_subscription(ChatId chat_id, bool enabled) {
            var found_config = loader.chats.first_match((config) => {
                return config.id == chat_id.id;
            });
            
            found_config.subscribed = enabled;
            
            loader.save_configs.begin();
            
            return found_config;
        }
    }
}
