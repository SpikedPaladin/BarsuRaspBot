using Gee;

namespace Teacher {
    
    public class DepartmentLoader {
        public ArrayList<Department> departments;
        
        public async void load_departments(bool sync = false) {
            var groups_file = File.new_for_path(".cache/TelegramBots/BarsuRaspBot/departments.json");
            var new_departments = new ArrayList<Department>();
            
            if (!sync && groups_file.query_exists()) {
                try {
                    var stream = yield groups_file.open_readwrite_async();
                    var parser = new Json.Parser();
                    
                    yield parser.load_from_stream_async(stream.input_stream);
                    
                    var root = parser.get_root().get_object();
                    
                    foreach (var department_element in root.get_array_member("departments").get_elements()) {
                        var department_object = department_element.get_object();
                        string[] teachers = {};
                        
                        foreach (var teacher_element in department_object.get_array_member("teachers").get_elements())
                            teachers += teacher_element.get_string();
                        
                        new_departments.add(new Department(department_object.get_string_member("name"), teachers));
                    }
                    
                    departments = new_departments;
                } catch (Error error) {
                    warning("Error while reading faculties: %s\n", error.message);
                }
            } else {
                try {
                    var msg = new Soup.Message("GET", "https://rasp.barsu.by/teach.php");
                    var teachers_page = yield session.send_and_read_async(msg, Soup.MessagePriority.NORMAL, null);
                    
                    var doc = new GXml.XHtmlDocument.from_string((string) teachers_page.get_data());
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
                        
                        new_departments.add(new Department(department_name, teachers));
                    }
                    
                    departments = new_departments;
                    yield save_departments();
                } catch (Error error) {
                    warning("Error while loading departments: %s\n", error.message);
                }
            }
        }
        
        public async void save_departments() {
            try {
                var builder = new Json.Builder();
                builder.begin_object();
                
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
