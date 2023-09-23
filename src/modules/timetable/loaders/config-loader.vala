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
                        var config = new Config() {
                            id = user.get_int_member("id"),
                            subscribed = user.get_boolean_member("subscribed")
                        };
                        
                        if (user.has_member("state"))
                            config.state = SetupState.parse(user.get_string_member("state"));
                        
                        if (user.has_member("type"))
                            config.type = ConfigType.parse(user.get_string_member("type"));
                        
                        if (user.has_member("group"))
                            config.group = user.get_string_member("group");
                        
                        if (user.has_member("name"))
                            config.name = user.get_string_member("name");
                        
                        users.add(config);
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
                    
                    if (user.state != null) {
                        builder.set_member_name("state");
                        builder.add_string_value(user.state.to_string());
                    }
                    
                    if (user.type != null) {
                        builder.set_member_name("type");
                        builder.add_string_value(user.type.to_string());
                    }
                    
                    if (user.group != null) {
                        builder.set_member_name("group");
                        builder.add_string_value(user.group);
                    }
                    
                    if (user.name != null) {
                        builder.set_member_name("name");
                        builder.add_string_value(user.name);
                    }
                    
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
        public SetupState? state;
        public ConfigType? type;
        public int64 id;
        public string? name;
        public string? group;
        public bool subscribed;
    }
    
    public enum ConfigType {
        TEACHER,
        STUDENT;
        
        public static ConfigType? parse(string type) {
            switch (type) {
                case "teacher":
                    return TEACHER;
                default:
                    return STUDENT;
            }
        }
        
        public string to_string() {
            switch (this) {
                case TEACHER:
                    return "teacher";
                default:
                    return "student";
            }
        }
    }
    
    public enum SetupState {
        // used /start command
        POST,
        // Chosed teacher
        DEPARTMENT,
        // Chosed department
        NAME,
        // Chosed student
        FACULTY,
        // Chosed faculty
        SPECIALITY,
        // Chosed speciality
        GROUP;
        
        public static SetupState? parse(string type) {
            switch (type) {
                case "department":
                    return DEPARTMENT;
                case "name":
                    return NAME;
                case "faculty":
                    return FACULTY;
                case "speciality":
                    return SPECIALITY;
                case "group":
                    return GROUP;
                default:
                    return POST;
            }
        }
        
        public string to_string() {
            switch (this) {
                case DEPARTMENT:
                    return "department";
                case NAME:
                    return "name";
                case FACULTY:
                    return "faculty";
                case SPECIALITY:
                    return "speciality";
                case GROUP:
                    return "group";
                default:
                    return "post";
            }
        }
    }
}
