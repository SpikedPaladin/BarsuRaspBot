namespace Teacher {
    
    public class Lesson {
        public string time;
        public string? name;
        public string? type;
        public string? groups;
        public string? place;
        public bool replaced;
        
        public int get_end_hour() {
            return int.parse(time.split("-")[0].split(".")[0]);
        }
        
        public int get_end_minute() {
            return int.parse(time.split("-")[0].split(".")[1]);
        }
        
        public string to_string() {
            var str = "";
            
            str += @"🕓️ *$(time)*";
            if (replaced)
                str += " 🔄️";
            str += "\n";
            
            str += @"ℹ️ *$(name)* _$(type)_\n";
            str += @"👥️ $(groups)\n🏨️ $(place)\n";
            
            return str;
        }
    }
}
