namespace BarsuTimetable {
    
    public class Lesson {
        public Sublesson[] sublessons;
        public string time;
        public bool replaced;
        public bool empty {
            get {
                return sublessons.length == 0;
            }
        }
        
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
            
            for (var i = 0; i < sublessons.length; i++) {
                var sublesson = sublessons[i];
                
                str += @"ℹ️ *$(sublesson.name)* _$(sublesson.type)_";
                if (sublesson.subgroup != null)
                    str += @" - $(sublesson.subgroup)";
                str += "\n";
                str += @"👤️ $(sublesson.teacher)";
                if (sublesson.place != null)
                    str += @" 🏨️ $(sublesson.place)";
                str += "\n";
            }
            
            return str;
        }
        
        public class Sublesson {
            public string name;
            public string type;
            public string? place;
            public string teacher;
            public string? subgroup;
        }
    }
}
