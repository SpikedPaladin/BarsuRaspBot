namespace BarsuTimetable {
    
    public class TeacherSchedule {
        public string day;
        public string date;
        
        public TeacherLesson[] lessons;
        
        public TeacherLesson? get_next_lesson(DateTime time) {
            TeacherLesson found = null;
            
            foreach (var lesson in lessons) {
                if (time.get_hour() < lesson.get_end_hour() && !(lesson.name == null)) {
                    found = lesson;
                    
                    break;
                } else if (time.get_hour() == lesson.get_end_hour() && time.get_minute() < lesson.get_end_minute() && !(lesson.name == null)) {
                    found = lesson;
                    
                    break;
                }
            }
            
            return found;
        }
        
        public string to_string() {
            var str = @"🗓️ Дата: *$(day) $(date)*\n\n";
            
            foreach (var lesson in lessons) {
                if (lesson.name == null)
                    continue;
                
                str += lesson.to_string();
                str += "\n";
            }
            
            return str;
        }
    }
    
    public class TeacherLesson {
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
