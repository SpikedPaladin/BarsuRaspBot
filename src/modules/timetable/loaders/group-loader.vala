using Gee;

namespace BarsuTimetable {
    
    public class GroupLoader {
        public ArrayList<Department> departments = new ArrayList<Department>();
        public ArrayList<Faculty> faculties = new ArrayList<Faculty>();
        public string last_fetch;
        
        public async bool sync_faculties() {
            //var new_groups = yield load_faculties(true);
            
            
            //yield save_faculties();
            return false;
        }
        
        public async ArrayList<string>? load_faculties(bool to_array = false) {
            var groups_file = File.new_for_path(".cache/TelegramBots/BarsuRaspBot/faculties.json");
            
            if (!to_array && groups_file.query_exists()) {
                try {
                    var stream = yield groups_file.open_readwrite_async();
                    var parser = new Json.Parser();
                    
                    yield parser.load_from_stream_async(stream.input_stream);
                    
                    var root = parser.get_root().get_object();
                    
                    last_fetch = root.get_string_member("last-fetch");
                    
                    foreach (var faculty_element in root.get_array_member("faculties").get_elements()) {
                        var faculty_object = faculty_element.get_object();
                        Speciality[] specialties = {};
                        
                        foreach (var speciality_element in faculty_object.get_array_member("specialties").get_elements()) {
                            var speciality_object = speciality_element.get_object();
                            string[] groups = {};
                            
                            foreach (var group_element in speciality_object.get_array_member("groups").get_elements())
                                groups += group_element.get_string();
                            
                            specialties += new Speciality(speciality_object.get_string_member("name"), groups);
                        }
                        
                        faculties.add(new Faculty(faculty_object.get_string_member("name"), specialties));
                    }
                } catch (Error error) {
                    warning("Error while reading faculties: %s\n", error.message);
                }
            } else {
                try {
                    var message = new Soup.Message("GET", "https://rasp.barsu.by/stud.php");
                    var groups_page = yield session.send_and_read_async(message, Soup.MessagePriority.NORMAL, null);
                    
                    var doc = new GXml.XHtmlDocument.from_string((string) groups_page.get_data());
                    var faculty_form = doc.get_element_by_id("faculty");
                    var speciality_form = doc.get_element_by_id("speciality");
                    var groups_form = doc.get_element_by_id("groups");
                    
                    foreach (var faculty_element in faculty_form.get_elements_by_tag_name("option").to_array()) {
                        var faculty_name = faculty_element.get_attribute("value");
                        
                        if (faculty_name == "selectcard")
                            continue;
                        
                        Speciality[] specialties = {};
                        foreach (var speciality_element in speciality_form.get_elements_by_tag_name("option").to_array()) {
                            var speciality_name = speciality_element.get_attribute("value");
                            
                            if (speciality_name == "selectcard" || speciality_element.get_attribute("class") != faculty_name)
                                continue;
                            
                            string[] groups = {};
                            foreach (var group_element in groups_form.get_elements_by_tag_name("option").to_array()) {
                                var group = group_element.get_attribute("value");
                                
                                if (group == "selectcard" || group_element.get_attribute("class") != speciality_name)
                                    continue;
                                
                                groups += group;
                            }
                            
                            specialties += new Speciality(speciality_name, groups);
                        }
                        
                        faculties.add(new Faculty(faculty_name, specialties));
                    }
                    
                    last_fetch = new DateTime.now().to_string();
                    
                    yield save_faculties();
                } catch (Error error) {
                    warning("Error while loading faculties: %s\n", error.message);
                }
            }
            
            return null;
        }
        
        public async void load_departments() {
            var groups_file = File.new_for_path(".cache/TelegramBots/BarsuRaspBot/departments.json");
            
            if (groups_file.query_exists() && false) {
                try {
                    var stream = yield groups_file.open_readwrite_async();
                    var parser = new Json.Parser();
                    
                    yield parser.load_from_stream_async(stream.input_stream);
                    
                    var root = parser.get_root().get_object();
                    
                    last_fetch = root.get_string_member("last-fetch");
                    
                    foreach (var faculty_element in root.get_array_member("faculties").get_elements()) {
                        var faculty_object = faculty_element.get_object();
                        Speciality[] specialties = {};
                        
                        foreach (var speciality_element in faculty_object.get_array_member("specialties").get_elements()) {
                            var speciality_object = speciality_element.get_object();
                            string[] groups = {};
                            
                            foreach (var group_element in speciality_object.get_array_member("groups").get_elements())
                                groups += group_element.get_string();
                            
                            specialties += new Speciality(speciality_object.get_string_member("name"), groups);
                        }
                        
                        faculties.add(new Faculty(faculty_object.get_string_member("name"), specialties));
                    }
                } catch (Error error) {
                    warning("Error while reading faculties: %s\n", error.message);
                }
            } else {
                try {
                    var message = new Soup.Message("GET", "https://rasp.barsu.by/teach.php");
                    var groups_page = yield session.send_and_read_async(message, Soup.MessagePriority.NORMAL, null);
                    
                    var doc = new GXml.XHtmlDocument.from_string((string) groups_page.get_data());
                    var department_form = doc.get_element_by_id("kafedra");
                    var teacher_form = doc.get_element_by_id("teacher");
                    
                    foreach (var department_element in department_form.get_elements_by_tag_name("option").to_array()) {
                        var department_name = department_element.get_attribute("value");
                        
                        if (department_name == "selectcard" || department_name == "")
                            continue;
                        
                        if (department_name.strip() == "")
                            department_name = "Без кафедры";
                        
                        string[] teachers = {};
                        foreach (var teacher_element in teacher_form.get_elements_by_tag_name("option").to_array()) {
                            var teacher_name = teacher_element.get_attribute("value");
                            var teacher_department = teacher_element.get_attribute("class");
                            
                            if (teacher_department == null || teacher_department.strip() == "")
                                teacher_department = "Без кафедры";
                            
                            if (teacher_name == "selectcard" || teacher_name == "" || teacher_department != department_name)
                                continue;
                            
                            teachers += teacher_name;
                        }
                        
                        departments.add(new Department(department_name, teachers));
                    }
                    
                    yield save_departments();
                } catch (Error error) {
                    warning("Error while loading departments: %s\n", error.message);
                }
            }
        }
        
        public async void save_faculties() {
            try {
                var builder = new Json.Builder();
                builder.begin_object();
                
                builder.set_member_name("last-fetch");
                builder.add_string_value(last_fetch);
                
                builder.set_member_name("faculties");
                builder.begin_array();
                foreach (var faculty in faculties) {
                    builder.begin_object();
                    
                    builder.set_member_name("name");
                    builder.add_string_value(faculty.name);
                    
                    builder.set_member_name("specialties");
                    builder.begin_array();
                    foreach (var speciality in faculty.specialties) {
                        builder.begin_object();
                        
                        builder.set_member_name("name");
                        builder.add_string_value(speciality.name);
                        
                        builder.set_member_name("groups");
                        builder.begin_array();
                        foreach (var group in speciality.groups)
                            builder.add_string_value(group);
                        builder.end_array();
                        
                        builder.end_object();
                    }
                    builder.end_array();
                    
                    builder.end_object();
                }
                builder.end_array();
                builder.end_object();
                
                FileUtil.save_json(builder.get_root(), ".cache/TelegramBots/BarsuRaspBot/faculties.json");
            } catch (Error error) {
                warning("Error while saving faculties: %s\n", error.message);
            }
        }
        
        public async void save_departments() {
            try {
                var builder = new Json.Builder();
                builder.begin_object();
                
                builder.set_member_name("last-fetch");
                builder.add_string_value(last_fetch);
                
                builder.set_member_name("departments");
                builder.begin_array();
                foreach (var department in departments) {
                    builder.begin_object();
                    
                    builder.set_member_name("name");
                    builder.add_string_value(department.name);
                    
                    builder.set_member_name("teachers");
                    builder.begin_array();
                    foreach (var teacher in department.teachers) {
                        builder.add_string_value(teacher);
                    }
                    builder.end_array();
                    
                    builder.end_object();
                }
                builder.end_array();
                builder.end_object();
                
                FileUtil.save_json(builder.get_root(), ".cache/TelegramBots/BarsuRaspBot/departments.json");
            } catch (Error error) {
                warning("Error while saving faculties: %s\n", error.message);
            }
        }
    }
}
