using Telegram;
using Gee;

namespace DataStore {
    
    public class DataManager {
        private DataLoader loader = new DataLoader();
        
        public async void load() {
            yield loader.load_configs();
        }
        
        public ArrayList<Config> get_users() {
            return loader.users;
        }
        
        public ArrayList<Config> get_chats() {
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
            
            if (found_config != null) {
                found_config.state = state;
            } else {
                loader.users.add(new Config() {
                    id = user_id,
                    state = state
                });
            }
            
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
