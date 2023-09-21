using Telegram;
using Gee;

namespace BarsuTimetable {
    
    public class ConfigManager {
        private ConfigLoader loader = new ConfigLoader();
        
        public async void load() {
            yield loader.load_configs();
        }
        
        public ArrayList<Config> get_users() {
            return loader.users;
        }
        
        public ArrayList<Config> get_chats() {
            return loader.chats;
        }
        
        public void remove_config(int64 id, bool is_chat) {
            var array = is_chat ? loader.chats : loader.users;
            
            var config = array.first_match((config) => {
                return config.id == id;
            });
            
            array.remove(config);
            loader.save_configs.begin();
        }
        
        public StartupState? get_user_state(int64 user_id) {
            var found_config = loader.users.first_match((config) => {
                return config.id == user_id;
            });
            
            if (found_config != null) {
                return found_config.state;
            }
            
            return null;
        }
        
        public void set_user_state(int64 user_id, StartupState? state) {
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
        
        public void set_user_type(int64 user_id, ConfigType type) {
            var found_config = loader.users.first_match((config) => {
                return config.id == user_id;
            });
            
            if (found_config != null) {
                found_config.type = type;
            } else {
                loader.users.add(new Config() {
                    id = user_id,
                    type = type
                });
            }
            
            loader.save_configs.begin();
        }
        
        public Config? find_user_config(int64 user_id) {
            var found_config = loader.users.first_match((config) => {
                return config.id == user_id;
            });
            
            if (found_config != null) {
                return found_config;
            }
            
            return null;
        }
        
        public string? find_user_group(int64 user_id) {
            var found_config = loader.users.first_match((config) => {
                return config.id == user_id;
            });
            
            if (found_config != null) {
                return found_config.group;
            }
            
            return null;
        }
        
        public void update_user_group(int64 user_id, string group) {
            var found_config = loader.users.first_match((config) => {
                return config.id == user_id;
            });
            
            if (found_config != null) {
                found_config.group = group;
            } else {
                var config = new Config() {
                    id = user_id,
                    group = group
                };
                
                loader.users.add(config);
            }
            
            loader.save_configs.begin();
        }
        
        public Config update_user_sub(int64 user_id, bool enabled) {
            var found_config = loader.users.first_match((config) => {
                return config.id == user_id;
            });
            
            found_config.subscribed = enabled;
            
            loader.save_configs.begin();
            
            return found_config;
        }
        
        public Config? find_chat_config(ChatId chat_id) {
            var found_config = loader.chats.first_match((config) => {
                return config.id == chat_id.id;
            });
            
            if (found_config != null) {
                return found_config;
            }
            
            return null;
        }
        
        public string? find_chat_group(ChatId chat_id) {
            var found_config = loader.chats.first_match((config) => {
                return config.id == chat_id.id;
            });
            
            if (found_config != null) {
                return found_config.group;
            }
            
            return null;
        }
        
        public void update_chat_group(ChatId chat_id, string group) {
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
        
        public Config update_chat_sub(ChatId chat_id, bool enabled) {
            var found_config = loader.chats.first_match((config) => {
                return config.id == chat_id.id;
            });
            
            found_config.subscribed = enabled;
            
            loader.save_configs.begin();
            
            return found_config;
        }
    }
}
