using Gee;

namespace DataStore {
    
    public class DataLoader {
        public ConcurrentList<Config> users = new ConcurrentList<Config>();
        public ConcurrentList<Config> chats = new ConcurrentList<Config>();
        public string apk_file_id = null;
        public string apk_version = null;
        
        public async void load_configs() {
            var file = File.new_for_path(".cache/TelegramBots/BarsuRaspBot/configs.json");
            
            if (file.query_exists()) {
                try {
                    var stream = yield file.open_readwrite_async();
                    var parser = new Json.Parser();
                    
                    yield parser.load_from_stream_async(stream.input_stream);
                    
                    var obj = parser.get_root().get_object();
                    
                    if (obj.has_member("apk"))
                        apk_file_id = obj.get_string_member("apk");
                    
                    if (obj.has_member("apk_version"))
                        apk_version = obj.get_string_member("apk_version");
                    
                    foreach (var element in obj.get_array_member("users")?.get_elements()) {
                        var user = element.get_object();
                        UserState? state = null;
                        UserPost? post = null;
                        string? group = null;
                        string? name = null;
                        
                        if (user.has_member("state"))
                            state = UserState.parse(user.get_string_member("state"));
                        
                        if (user.has_member("post"))
                            post = UserPost.parse(user.get_string_member("post"));
                        
                        if (user.has_member("group"))
                            group = user.get_string_member("group");
                        
                        if (user.has_member("name"))
                            name = user.get_string_member("name");
                        
                        users.add(
                            new Config.load(
                                user.get_int_member("id"),
                                state,
                                post,
                                name,
                                group,
                                user.get_boolean_member("subscribed")
                            )
                        );
                    }
                    
                    foreach (var element in obj.get_array_member("chats")?.get_elements()) {
                        var chat = element.get_object();
                        
                        chats.add(
                            new Config.load(
                                chat.get_int_member("id"),
                                null, null, null,
                                chat.get_string_member("group"),
                                chat.get_boolean_member("subscribed")
                            )
                        );
                    }
                } catch (Error error) {
                    warning("Error while reading configs: %s\n", error.message);
                }
            }
        }
        
        public async void save_configs() {
            try {
                var builder = new Json.Builder();
                builder.begin_object();
                
                if (apk_file_id != null) {
                    builder.set_member_name("apk");
                    builder.add_string_value(apk_file_id);
                }
                
                if (apk_version != null) {
                    builder.set_member_name("apk_version");
                    builder.add_string_value(apk_version);
                }
                
                builder.set_member_name("users");
                builder.begin_array();
                foreach (var user in users.to_array()) {
                    builder.begin_object();
                    
                    builder.set_member_name("id");
                    builder.add_int_value(user.id);
                    
                    if (user.state != null) {
                        builder.set_member_name("state");
                        builder.add_string_value(user.state.to_string());
                    }
                    
                    if (user.post != null) {
                        builder.set_member_name("post");
                        builder.add_string_value(user.post.to_string());
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
                
                FileUtil.save_json(builder.get_root(), ".cache/TelegramBots/BarsuRaspBot/configs.json");
            } catch (Error error) {
                warning("Error while saving configs: %s\n", error.message);
            }
        }
    }
}
