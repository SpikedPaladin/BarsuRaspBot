using Gee;

namespace BarsuTimetable {
    
    public class ConfigLoader {
        public ArrayList<Config> users = new ArrayList<Config>();
        public ArrayList<Config> chats = new ArrayList<Config>();
        
        public async void load_configs() {
            var file = File.new_for_path(".cache/TelegramBots/BarsuRaspBot/configs.json");
            
            if (file.query_exists()) {
                try {
                    var stream = yield file.open_readwrite_async();
                    var parser = new Json.Parser();
                    
                    yield parser.load_from_stream_async(stream.input_stream);
                    
                    var obj = parser.get_root().get_object();
                    
                    foreach (var element in obj.get_array_member("users")?.get_elements()) {
                        var user = element.get_object();
                        
                        users.add(new Config() {
                            id = user.get_int_member("id"),
                            group = user.get_string_member("group"),
                            subscribed = user.get_boolean_member("subscribed")
                        });
                    }
                    
                    foreach (var element in obj.get_array_member("chats")?.get_elements()) {
                        var chat = element.get_object();
                        
                        chats.add(new Config() {
                            id = chat.get_int_member("id"),
                            group = chat.get_string_member("group"),
                            subscribed = chat.get_boolean_member("subscribed")
                        });
                    }
                } catch (Error error) {
                    warning("Error while reading configs: %s\n", error.message);
                }
            }
        }
        
        public async void save_configs() {
            var file = File.new_for_path(".cache/TelegramBots/BarsuRaspBot/configs.json");
            
            try {
                var builder = new Json.Builder();
                builder.begin_object();
                
                builder.set_member_name("users");
                builder.begin_array();
                foreach (var user in users) {
                    builder.begin_object();
                    
                    builder.set_member_name("id");
                    builder.add_int_value(user.id);
                    
                    builder.set_member_name("group");
                    builder.add_string_value(user.group);
                    
                    builder.set_member_name("subscribed");
                    builder.add_boolean_value(user.subscribed);
                    
                    builder.end_object();
                }
                builder.end_array();
                
                builder.set_member_name("chats");
                builder.begin_array();
                foreach (var chat in chats) {
                    builder.begin_object();
                    
                    builder.set_member_name("id");
                    builder.add_int_value(chat.id);
                    
                    builder.set_member_name("group");
                    builder.add_string_value(chat.group);
                    
                    builder.set_member_name("subscribed");
                    builder.add_boolean_value(chat.subscribed);
                    
                    builder.end_object();
                }
                builder.end_array();
                
                builder.end_object();
                
                var generator = new Json.Generator();
                
                generator.set_root(builder.get_root());
                generator.to_file(file.get_path());
            } catch (Error error) {
                warning("Error while saving configs: %s\n", error.message);
            }
        }
    }

    public class Config {
        public int64 id;
        public string group;
        public bool subscribed;
    }
}
