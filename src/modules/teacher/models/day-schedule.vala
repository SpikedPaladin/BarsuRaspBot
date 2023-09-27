namespace Teacher {
    
    public class DaySchedule {
        public string day;
        public string date;
        
        public Lesson[] lessons;
        
        public Lesson? get_next_lesson(DateTime time) {
            Lesson found = null;
            
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
}
