namespace DataStore {
    
    public class Config {
        private int64 _id;
        private UserState? _state;
        private SelectedTheme _selectedTheme = SelectedTheme.CLASSIC;
        private ImageTheme _theme = new ClassicTheme();
        private string? _name;
        private string? _group;
        private bool _subscribed;
        
        public int64 id {
            get { return _id; }
            set {
                _id = value;
                data.schedule_save();
            }
        }
        public UserState? state {
            get { return _state; }
            set {
                _state = value;
                data.schedule_save();
            }
        }
        public SelectedTheme selectedTheme {
            get { return _selectedTheme; }
            set {
                _selectedTheme = value;
                _theme = value.get_theme();
                data.schedule_save();
            }
        }
        public weak ImageTheme theme {
            get { return _theme; }
        }
        public UserPost? post {
            get {
                if (name != null)
                    return UserPost.TEACHER;
                if (group != null)
                    return UserPost.STUDENT;
                return null;
            }
        }
        public string? name {
            get { return _name; }
            set {
                _name = value;
                data.schedule_save();
            }
        }
        public string? group {
            get { return _group; }
            set {
                _group = value;
                data.schedule_save();
            }
        }
        public bool subscribed {
            get { return _subscribed; }
            set {
                _subscribed = value;
                data.schedule_save();
            }
        }
        
        public Config.empty(int64 id) {
            _id = id;
        }
        
        public Config.load(
            int64 id,
            UserState? state,
            SelectedTheme? selectedTheme,
            string? name,
            string? group,
            bool subscribed
        ) {
            _id = id;
            _state = state;
            _selectedTheme = selectedTheme ?? SelectedTheme.CLASSIC;
            _name = name;
            _group = group;
            _subscribed = subscribed;
            
            _theme = _selectedTheme.get_theme();
        }
        
        public string to_string() {
            var str = "Настройки бота:\n\n";
            str += @"🔔️ Уведомления: *$(subscribed ? "ВКЛ" : "ОТКЛ")*\n";
            str += @"🎨️ Тема: *$(selectedTheme.to_localized_string())*\n";
            
            if (post == UserPost.TEACHER)
                str += @"🧑‍🏫️ Преподаватель: *$(name)*";
            else
                str += @"👥️ Группа: *$(group)*";
            
            return str;
        }
    }
}
