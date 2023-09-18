using Gee;

namespace BarsuTimetable {
    
    public class GroupLoader {
        public ArrayList<string> groups = new ArrayList<string>((a, b) => a.down() == b.down());
        public string last_fetch;
        
        public async bool sync_groups() {
            var new_groups = yield load_groups(true);
            
            if (groups.size == new_groups.size) {
                bool equal = true;
                for (int i = 0; i < groups.size; i++) {
                    if (groups.get(i) != new_groups.get(i)) {
                        equal = false;
                        break;
                    }
                }
                
                if (equal)
                    return false;
            }
            
            groups = new_groups;
            
            yield save_groups();
            return true;
        }
        
        public async ArrayList<string>? load_groups(bool to_array = false) {
            var groups_file = File.new_for_path(".cache/TelegramBots/BarsuRaspBot/groups.json");
            
            if (!to_array && groups_file.query_exists()) {
                try {
                    var stream = yield groups_file.open_readwrite_async();
                    var parser = new Json.Parser();
                    
                    yield parser.load_from_stream_async(stream.input_stream);
                    
                    var obj = parser.get_root().get_object();
                    
                    last_fetch = obj.get_string_member("last-fetch");
                    
                    foreach (var element in obj.get_array_member("groups").get_elements())
                        groups.add(element.get_string());
                } catch (Error error) {
                    warning("Error while reading groups: %s\n", error.message);
                }
            } else {
                try {
                    var message = new Soup.Message("GET", "https://rasp.barsu.by/stud.php");
                    var groups_page = yield session.send_and_read_async(message, Soup.MessagePriority.NORMAL, null);
                    
                    var doc = new GXml.XHtmlDocument.from_string((string) groups_page.get_data());
                    var groups_element = doc.get_element_by_id("groups");
                    ArrayList<string>? array = null;
                    if (to_array)
                        array = new ArrayList<string>((a, b) => a.down() == b.down());
                    
                    foreach (var group in groups_element.get_elements_by_tag_name("option").to_array()) {
                        var group_name = group.get_attribute("value");
                        
                        // Skip first
                        if (group_name == "selectcard")
                            continue;
                        
                        if (to_array) {
                            array.add(group_name);
                            
                            continue;
                        }
                        
                        groups.add(group_name);
                    }
                    
                    if (to_array)
                        return array;
                    
                    last_fetch = new DateTime.now().to_string();
                    
                    yield save_groups();
                } catch (Error error) {
                    warning("Error while loading groups: %s\n", error.message);
                }
            }
            
            return null;
        }
        
        public async void save_groups() {
            try {
                var groups_file = File.new_for_path(".cache/TelegramBots/BarsuRaspBot/groups.json");
                var builder = new Json.Builder();
                builder.begin_object();
                
                builder.set_member_name("last-fetch");
                builder.add_string_value(last_fetch);
                
                builder.set_member_name("groups");
                builder.begin_array();
                foreach (var group in groups) {
                    builder.add_string_value(group);
                }
                builder.end_array();
                builder.end_object();
                
                var generator = new Json.Generator();
                
                generator.set_root(builder.get_root());
                generator.to_file(groups_file.get_path());
            } catch (Error error) {
                warning("Error while saving groups: %s\n", error.message);
            }
        }
    }
}
