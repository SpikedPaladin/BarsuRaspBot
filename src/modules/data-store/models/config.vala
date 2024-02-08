namespace DataStore {
    
    public class Config {
        private UserState? _state;
        private UserPost? _post;
        private int64 _id;
        private string? _name;
        private string? _group;
        private bool _subscribed;
        
        public UserState? state {
            get { return _state; }
            set {
                _state = value;
                data.schedule_save();
            }
        }
        public UserPost? post {
            get { return _post; }
            set {
                _post = value;
                data.schedule_save();
            }
        }
        public int64 id {
            get { return _id; }
            set {
                _id = value;
                data.schedule_save();
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
            UserPost? post,
            string? name,
            string? group,
            bool subscribed
        ) {
            _id = id;
            _state = state;
            _post = post;
            _name = name;
            _group = group;
            _subscribed = subscribed;
        }
    }
}
