namespace BarsuTimetable {
    
    public class DaySchedule {
        public DateTime last_fetch;
        
        public string date;
        public string day_of_week;
        public string week;
        public Lesson[] lessons;
        public int number_of_lessons {
            get {
                int number = 0;
                
                foreach (var lesson in lessons) {
                    if (!lesson.empty) number++;
                }
                
                return number;
            }
        }
        
        public Lesson? get_next_lesson(DateTime time) {
            Lesson found = null;
            
            foreach (var lesson in lessons) {
                if (time.get_hour() < lesson.get_end_hour() && !lesson.empty) {
                    found = lesson;
                    
                    break;
                } else if (time.get_hour() == lesson.get_end_hour() && time.get_minute() < lesson.get_end_minute() && !lesson.empty) {
                    found = lesson;
                    
                    break;
                }
            }
            
            return found;
        }
        
        public string to_string() {
            var str = @"🗓️ Дата: *$(day_of_week) $(date)*\n\n";
            
            foreach (var lesson in lessons) {
                if (lesson.empty)
                    continue;
                
                str += lesson.to_string();
                str += "\n";
            }
            
            return str;
        }
    }
}
