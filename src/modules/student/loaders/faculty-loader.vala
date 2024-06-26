using Gee;

namespace Student {
    
    public class FacultyLoader {
        public ArrayList<Faculty> faculties;
        
        public async void load_faculties(bool sync = false) {
            var groups_file = File.new_for_path(".cache/TelegramBots/BarsuRaspBot/faculties.json");
            var new_faculties = new ArrayList<Faculty>();
            
            if (!sync && groups_file.query_exists()) {
                try {
                    var stream = yield groups_file.open_readwrite_async();
                    var parser = new Json.Parser();
                    
                    yield parser.load_from_stream_async(stream.input_stream);
                    
                    var root = parser.get_root().get_object();
                    
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
                        
                        new_faculties.add(new Faculty(faculty_object.get_string_member("name"), specialties));
                    }
                    
                    faculties = new_faculties;
                } catch (Error error) {
                    warning("Error while reading faculties: %s\n", error.message);
                }
            } else {
                try {
                    var msg = new Soup.Message("GET", "https://rasp.barsu.by/stud.php");
                    var groups_page = yield session.send_and_read_async(msg, Soup.MessagePriority.NORMAL, null);
                    
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
                        
                        new_faculties.add(new Faculty(faculty_name, specialties));
                    }
                    
                    faculties = new_faculties;
                    yield save_faculties();
                } catch (Error error) {
                    warning("Error while loading faculties: %s\n", error.message);
                }
            }
        }
        
        
        public async void save_faculties() {
            try {
                var builder = new Json.Builder();
                builder.begin_object();
                
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
    }
}
